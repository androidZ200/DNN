
if disp_info >= 2; ndisp('loading fashion mnist dataset'); end
load('datasets/fashion/FashionMNIST.mat');

ln = length(Labels);

% rename digits label
TrainLabel = single(TrainLabel + 1);
TestLabel = single(TestLabel + 1);

if disp_info >= 2; rdisp('load fashion mnist finished'); end
