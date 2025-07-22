
if disp_info >= 2; ndisp('loading mnist dataset'); end
load('datasets/mnist/MNIST.mat');

ln = length(Labels);

Train = single(Train);
Test = single(Test);

if disp_info >= 2; rdisp('load mnist finished'); end
