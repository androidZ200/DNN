clear all;
init;
z = [0.3 0.6]/metric;
DOES = ones(N,N,length(z)-1);

epoch = 2;
speed = 1e0;
slowdown = 0.9996;
LossFunc = 'SCE';
method = 'adam';
params = [0.9 0.999 1e-1];
training;
check_result;

