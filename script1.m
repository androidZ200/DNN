%% standart gradient training

clear all;
pixel = 4e-6;
spixel = pixel*2;
lambda = 632.8e-9;
N = 512;
is_max = false;
z = [0 0.01 0.02];
init;

mnist_digits;
% MASK(:,:,end+1) = ones(N) - (sum(MASK,3)>0);

Propagations = [];
GetImage = @(W)propagation(normalize_field(resizeimage(W,N,spixel,pixel)), U(:,:,1));
for iter=2:size(U,3)
    Propagations{end+1} = @(W)propagation(W, U(:,:,iter));
end

DOES = exp(2i*pi*(rand(N,N,length(Propagations))-0.5)/10);

epoch = 1;
batch = 20;
cycle = 1500;
speed = 0.3;
slowdown = 0.9995;
LossFunc = 'SCE';
method = 'Adam';
params = [0.9 0.999 1e-8];
training1;

check_result;
return;

%% iterative alghoritm

clear all;
metric = 1;
N = 256/2;
spixel = 8e-6/metric;
lambda = 632.8e-9/metric;
is_max = true;
G_size_x = 0.05e-3/metric;
G_size_y = 0.05e-3/metric;
z = [0 0.01 0.02]/metric;
DOES = exp(2i*pi*(rand(N,N,length(z)-2)-0.5)/10);
DOES_MASK = ones(N,N,size(DOES,3));
tmp_data = zeros(N,N,size(DOES,3));

epoch = 4;
cycle = 1500;
speed = 0.3;
slowdown = 0.9995;
LossFunc = 'SCE';
method = 'Adam';
params = [0.9 0.999 1e-8];
%%
N = N*2;
pixel = 4e-6*512/N/metric;
init;
aa = (0.6e-3/metric - G_size_x)/3;
hh = (0.4e-3/metric - G_size_y)/2;
mnist_digits;
target_scores = ones(ln)*0.05 + eye(ln)*0.5;
Propagations = [];
GetImage = @(W)propagation(normalize_field(resizeimage(W,N,spixel,pixel)), z(2)-z(1), U);
for iter=3:length(z)
    Propagations{end+1} = @(W)propagation(W, z(iter)-z(iter-1), U);
end

DOES = kron(DOES, ones(2));
DOES_MASK = kron(DOES_MASK, ones(2));
tmp_data = kron(tmp_data, ones(2));

batch = 20;
deleted = false;
training1;
epoch = 1;
check_result;

return;

%% test no-gradient training

clear all;
pixel = 4e-6/0.001;
spixel = pixel*2;
lambda = 632.8e-9/0.001;
N = 512;
init;

mnist_digits;
% MASK(:,:,end+1) = ones(N) - (sum(MASK,3)>0);

GetImage = @(W)propagation(normalize_field(resizeimage(W,N,spixel,pixel)), 10, U);
Propagations = { @(W)propagation(W, 10, U); };
DOES = exp(2i*pi*rand(N,N,length(Propagations)));

P = 4000;
epoch = 1;
batch = 1000;
cycle = 1000;
LossFunc = 'SCE';
training2;

check_result;
return;

%% example image generation

clear all;
pixel = 18e-6/0.001;
N = 512;
init;

sigma = B/8;
alpha = pi/180/10;
Train(:,:,1) = exp(-(X.^2 + Y.^2)/2/sigma^2).*exp( 1i*k*sin(alpha)*X);
Train(:,:,2) = exp(-(X.^2 + Y.^2)/2/sigma^2).*exp(-1i*k*sin(alpha)*X);
Train(:,:,3) = exp(-(X.^2 + Y.^2)/2/sigma^2).*exp( 1i*k*sin(alpha)*Y);
Train(:,:,4) = exp(-(X.^2 + Y.^2)/2/sigma^2).*exp(-1i*k*sin(alpha)*Y);
Train = normalize_field(Train)*1e3;
TrainLabel = [1; 2; 3; 4];
Test = Train;

Target(:,:,1) = ((X.^2 + Y.^2) < (B/4)^2).*((X.^2 + Y.^2) > (B/4.4)^2);
Target(:,:,2) = (max(abs(X), abs(Y)) < B/4).*(max(abs(X), abs(Y)) > B/4.4);
Target(:,:,3) = (max(abs(X), abs(Y)) < B/4).*(min(abs(X), abs(Y)) < B*0.05/4.4);
Target(:,:,4) = (max(abs(X), abs(Y)) < B/4).*(abs(abs(X) - abs(Y)) <  B*0.07/4.4);
Target = (normalize_field(Target)*1e3).^2;

GetImage = @(W) propagation(W, 150, U);
Propagations = { @(W)propagation(W, 150, U); @(W)propagation(W, 150, U); @(W)propagation(W, 150, U); };
MASK = zeros(size(Train));

epoch = 8000;
batch = 4;
cycle = 800;
speed = 1;
slowdown = 0.9992;
LossFunc = 'Target';
method = 'Adam';
params = [0.9 0.999 1e-8];
training1;
return;

%% phase function doe

ssau = [linspace(40,  32, 40), linspace( 32,  255, 40), linspace(255, 201, 40), linspace(201, 40, 40);...
        linspace(40, 146, 40), linspace(146,  255, 40), linspace(255,  88, 40), linspace( 88, 40, 40);...
        linspace(40, 201, 40), linspace(201,  255, 40), linspace(255,  32, 40), linspace( 32, 40, 40)]'/255;
ssau(1:40:end,:) = [];

for iter=1:size(DOES,3)
    figure;
    imagesc([-B B], [-B B], angle(DOES(:,:,iter)));
    title(['DOE ' num2str(iter)]);
    colormap(ssau); colorbar;
end

clearvars ssau;

