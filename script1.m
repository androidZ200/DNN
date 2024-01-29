%% standart gradient training

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

epoch = 5;
batch = 20;
cycle = 1200;
speed = 0.1;
slowdown = 0.9996;
LossFunc = 'SCE';
method = 'Adam';
params = [0.9 0.999 1e-8];
training1;

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

ssau = [linspace(255,  32, 80), linspace( 32,  40, 80), linspace(40,  255, 80);...
        linspace(255, 146, 80), linspace(146,  40, 80), linspace(40,  255, 80);...
        linspace(255, 201, 80), linspace(201,  40, 80), linspace(40,  255, 80)]'/255;

for iter=1:size(DOES,3)
    figure;
    imagesc([-B B], [-B B], angle(DOES(:,:,iter)));
    title(['DOE ' num2str(iter)]);
    colormap(ssau); colorbar;
end

clearvars ssau;

