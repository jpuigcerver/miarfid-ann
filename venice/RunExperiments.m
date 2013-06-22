rng(0)
% Load Data
targets80 = LoadData('corpus/level80.norm');
targets90 = LoadData('corpus/level90.norm');

% Try feed forward networks
WINDOW_SIZES{1} = 1;
WINDOW_SIZES{2} = 6;
WINDOW_SIZES{3} = 12;
WINDOW_SIZES{4} = 24;

HIDDEN_LAYERS{1} = 10;
HIDDEN_LAYERS{2} = 20;
HIDDEN_LAYERS{3} = [10 10];
HIDDEN_LAYERS{4} = [20 20];

REC_DELAYS{1} = 1;
REC_DELAYS{2} = 1:2;
%REC_DELAYS{3} = 1:4;
%REC_DELAYS{4} = 1:8;

targets80 = targets80';
targets90 = targets90';

for i=1:length(WINDOW_SIZES)
    % Prepare data with the correct window size
    inputs80 = PrepareNNInputs(targets80', WINDOW_SIZES{i});
    inputs90 = PrepareNNInputs(targets90', WINDOW_SIZES{i});
    inputs80 = inputs80';
    inputs90 = inputs90';
    % TRY WITH FEED-FORWARD NETWORKS
    for j = 1:length(HIDDEN_LAYERS)
        tic;
        net = feedforwardnet(HIDDEN_LAYERS{j});
        net = PrepareNNTraining(net);
        [net,tr] = train(net, inputs80, targets80);
        [tr_p, va_p, te_p, te_e] = CollectNNStatistics(net, tr, ...
            inputs80, inputs90, targets80, targets90);
        tt = toc;
        fprintf(1, 'FF(i=%d,j=%d). Train MSE = %f, Valid MSE = %f, Test MSE = %f. Time = %fsecs.\n', ...
            i, j, tr_p, va_p, te_p, tt);
    end
    % TRY WITH RECURRENT NETWORKS
    for j = 1:length(HIDDEN_LAYERS)
        for k = 1:length(REC_DELAYS)
            tic;
            net = layrecnet(REC_DELAYS{k}, HIDDEN_LAYERS{j});
            net = PrepareNNTraining(net);
            [net,tr] = train(net, inputs80, targets80);
            [tr_p, va_p, te_p, te_e] = CollectNNStatistics(net, tr, ...
                inputs80, inputs90, targets80, targets90);
            tt = toc;
            fprintf(1, 'RNN(i=%d,j=%d,k=%d). Train MSE = %f, Valid MSE = %f, Test MSE = %f. Time = %fsecs.\n', ...
                i, j, k, tr_p, va_p, te_p, tt);
        end
    end
end