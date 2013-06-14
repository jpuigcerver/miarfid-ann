rng(0)
level80 = LoadData('corpus/level80.norm');
level90 = LoadData('corpus/level90.norm');

targetSeries80 = tonndata(level80, false,false);
targetSeries90 = tonndata(level90, false, false);

% Create a Nonlinear Autoregressive Network
feedbackDelays = 1;
hiddenLayerSize = [50];
net = layrecnet(feedbackDelays, hiddenLayerSize);
view(net)

% Choose Feedback Pre/Post-Processing Functions
% Settings for feedback input are automatically applied to feedback output
% For a list of all processing functions type: help nnprocess
%net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
[inputs80,inputStates80,layerStates80,targets80] = ...
    preparets(net, {targetSeries80{1:end-1}}, {targetSeries80{2:end}});

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
net.divideFcn = 'divideblock';  % Divide data randomly
net.divideMode = 'time';  % Divide up every value
net.divideParam.trainRatio = 0.8;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0;

% Choose a Training Function
% For a list of all training functions type: help nntrain
net.trainFcn = 'traingdx';  % Levenberg-Marquardt
%net.trainFcn = 'trainbfg';  % BFGS
%net.trainFcn = 'traingdx';
net.trainParam.max_fail = 10;

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse';  % Mean squared error

% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate','plotresponse', ...
  'ploterrcorr', 'plotinerrcorr'};

%inputs80 = {0, targetSeries80{1:end-1}};
%inputStates80 = num2cell(zeros(1, 23));
%layerStates80 = cell(2,0);

% Train the Network
tic;
[net,tr] = train(net,inputs80,targets80,inputStates80,layerStates80, 'useParallel', 'yes');
toc

% Test the Network
[outputs80, inputStates80_2, layerStates80_2] = ...
    sim(net,inputs80,inputStates80,layerStates80);
errors80 = gsubtract(targets80,outputs80);

%[inputs90,inputStates90,layerStates90,targets90] = ...
%   preparets(net,{},{},targetSeries90);
%inputs90 = {targetSeries80{end}, targetSeries90{1:end-1}};
%targets90 = targetSeries90;
%outputs90 = sim(net, inputs90, inputStates80_2, layerStates80_2);
%errors90 = gsubtract(targets90,outputs90);

% Recalculate Training, Validation and Test Performance
trainTargets = gmultiply(targets80,tr.trainMask);
valTargets = gmultiply(targets80,tr.valMask);
%testTargets = gmultiply(targets,tr.testMask);
trainPerformance = perform(net,trainTargets,outputs80)
valPerformance = perform(net,valTargets,outputs80)
%testPerformance = perform(net,targets90,outputs90)


% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, plotresponse(targets,outputs)
%figure, ploterrcorr(errors)
%figure, plotinerrcorr(inputs,errors)

% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.
% netc = closeloop(net);
% [xc,xic,aic,tc] = preparets(netc,{},{},targetSeries);
% yc = netc(xc,xic,aic);
% perfc = perform(net,tc,yc)

% Early Prediction Network
% For some applications it helps to get the prediction a timestep early.
% The original network returns predicted y(t+1) at the same time it is given y(t+1).
% For some applications such as decision making, it would help to have predicted
% y(t+1) once y(t) is available, but before the actual y(t+1) occurs.
% The network can be made to return its output a timestep early by removing one delay
% so that its minimal tap delay is now 0 instead of 1.  The new network returns the
% same outputs as the original network, but outputs are shifted left one timestep.
% nets = removedelay(net);
% [xs,xis,ais,ts] = preparets(nets,{},{},targetSeries);
% ys = nets(xs,xis,ais);
% closedLoopPerformance = perform(net,tc,yc)