rng(0)
level80 = LoadData('corpus/level80.norm');
level90 = LoadData('corpus/level90.norm');

targetSeries80 = tonndata(level80, false,false);
targetSeries90 = tonndata(level90, false, false);

hiddenLayerSize = 50;
net = feedforwardnet(hiddenLayerSize);
%view(net)

[inputs80,inputStates80,layerStates80,targets80] = ...
    preparets(net, {targetSeries80{1:end-1}}, {targetSeries80{2:end}});


net.divideFcn = 'divideblock';  % Divide data randomly
net.divideMode = 'time';  % Divide up every value
net.divideParam.trainRatio = 0.8;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0;

net.trainFcn = 'trainlm';  % Levenberg-Marquardt
%net.trainFcn = 'trainbfg';  % BFGS
%net.trainFcn = 'traingdx';
net.trainParam.max_fail = 10;

net.performFcn = 'mse';  % Mean squared error
net.plotFcns = {'plotperform','plottrainstate','plotresponse', ...
  'ploterrcorr', 'plotinerrcorr'};

tic;
[net,tr] = train(net,inputs80,targets80,inputStates80,layerStates80, 'useParallel', 'yes');
toc

% Test the Network
outputs80 = sim(net,inputs80,inputStates80,layerStates80);
errors80 = gsubtract(targets80,outputs80);
trainTargets = gmultiply(targets80,tr.trainMask);
valTargets = gmultiply(targets80,tr.valMask);
trainPerformance = perform(net,trainTargets,outputs80)
valPerformance = perform(net,valTargets,outputs80)