
load('datasets/mnist/MNIST.mat');

Train = single(Train);
TrainLabel = reshape(TrainLabel,1,[]);
Test = single(Test);
TestLabel = reshape(TestLabel,1,[]);