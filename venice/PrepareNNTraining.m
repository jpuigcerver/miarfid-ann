function net = PrepareNNTraining( net )
%PREPARENNTRAINING Prepare NN training and val, data, training method,
% etc.
net.divideFcn = 'divideblock';
net.divideMode = 'sample';
net.divideParam.trainRatio = 0.8;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0;

net.trainFcn = 'trainlm';
net.trainParam.max_fail = 10;

net.performFcn = 'mse';
end

