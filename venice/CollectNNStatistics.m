function [ tr_perf, va_perf, te_perf, te_errs] = CollectNNStatistics( net, tr, inputs_tr, inputs_te, targets_tr, targets_te )
outputs_tr = net(inputs_tr);
outputs_te = net(inputs_te);

%errors_tr = gsubtract(targets_tr, outputs_tr);
te_errs = gsubtract(targets_te, outputs_te);


trainTargets = gmultiply(targets_tr,tr.trainMask);
valTargets = gmultiply(targets_tr,tr.valMask);

tr_perf = perform(net,trainTargets,outputs_tr);
va_perf = perform(net,valTargets,outputs_tr);
te_perf = perform(net,targets_te,outputs_te);
end

