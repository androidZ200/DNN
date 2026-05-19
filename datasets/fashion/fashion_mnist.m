
load('datasets/fashion/FashionMNIST.mat');

% rename digits label
TrainLabel = single(TrainLabel + 1);
TestLabel = single(TestLabel + 1);

