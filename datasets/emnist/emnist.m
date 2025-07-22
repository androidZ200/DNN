
if disp_info >= 2; ndisp('loading emnist dataset'); end
load('datasets/emnist/EMNIST.mat');

ln = length(Labels);
TrainLabel = single(TrainLabel);
TestLabel = single(TestLabel);

if disp_info >= 2; rdisp('load emnist finished'); end
