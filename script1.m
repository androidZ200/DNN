clear all;
init;
z = [0.2 0.4 0.6 0.8]/metric;
DOES = ones(N,N,length(z)-1);

epoch = 4;
speed = 1e0;
slowdown = 0.9997;
LossFunc = 'SCE';
training;
check_result;

