clear all;
init;

z = [0.3 0.6]/metric;
DOES = ones(N,N,length(z)-1);

epoch=3;
speed=1e0;
speeddown=0.996;
LossFunc='SCE';
method='adam';
params=[0.9 0.999 0.1];
dropout = 0.1;
training;
check_result;
