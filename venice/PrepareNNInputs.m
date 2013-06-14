function inputs = PrepareNNInputs( data, varargin )
% PREPARENNDATA prepares data to predict time series using a NN
% which uses a window of the past records as input.
[N,D] = size(data);
if nargin > 1
    window = varargin{1};
    assert(window > 0, 'Window size must be greater or equal to 1.');
    if window >= N
        warning('Window size shrinked to N - 1 (N is the number of data samples).');
        window = N-1;
    end
else
    window = 1;
end
inputs = zeros(N, window * D);
for i = 1:window
    z = zeros(1, D*(window-i+1));
    p = reshape(data(1:i-1, :)', 1 , D * (i-1));
    inputs(i,:) = [z, p];
end
for i = window + 1 : N
    inputs(i,:) = data(i-window:i-1,:);
end
end

