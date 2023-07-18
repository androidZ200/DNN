clear all;
init;

z = [0.3 0.6 0.9]/metric;
DOES = ones(N,N,length(z)-1);

LossFunc = 'Gauss';
IntensityFactor = 0;
training2;
check_result;
data(iter3+1) = accuracy;
