clear all;
init;
z = [0.3 0.6]/metric;
DOES = exp(2i*pi*rand(N,N,length(z)-1));

epoch = 1;
batch = 16;
LossFunc = 'Gauss';
IntensityFactor = 2;
training;
check_result;

