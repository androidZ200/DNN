return;
%% standart gradient training

clear variables;

pixel = 4e-6;
spixel = pixel*2;
lambda = 632.8e-9;
N = 512;
is_max = true;
z = [0 0.01 0.02];
m_prop = 'fft';
init;

aa = 0.6e-3;
hh = 0.4e-3;
G_size_x = 50e-6;
G_size_y = G_size_x;
mnist_digits;
% MASK(:,:,end+1) = ones(N) - (sum(MASK,3)>0);


epoch = 4;
batch = 20;
cycle = 1500;
speed = 0.3;
slowdown = 0.9995;
LossFunc = 'SCE';
method = 'Adam';
params = [0.9 0.999 1e-8];
training1;

check_result;

%% 4F-system

clear variables;

focus = 0.25;
pixel_doe = 8e-6;
lambda = 532e-9;
N = 1024;
pixel = lambda*focus/pixel_doe/N;
spixel = 36e-6;
is_max = true;
init;

aa = 5e-3;
hh = 4e-3;
G_size_x = 1e-3;
G_size_y = 1e-3;
mnist_digits;

GetImage = @(W)fft2(normalize_field(resizeimage(W,N,spixel,pixel)));
Propagations = { @(W)fft2(W) };

DOES = exp(2i*pi*(rand(N,N,length(Propagations))-0.5)/10);

epoch = 4;
batch = 20;
cycle = 1500;
speed = 0.3;
slowdown = 0.9995;
LossFunc = 'SCE';
method = 'Adam';
params = [0.9 0.999 1e-8];
training1;

check_result;

%% iterative alghoritm

clear variables;

N = 256/2;
pixel = 4e-6*512/N;
spixel = 8e-6;
lambda = 632.8e-9;
is_max = true;
G_size_x = 0.05e-3;
G_size_y = 0.05e-3;
z = [0 0.01 0.02];
DOES = exp(2i*pi*(rand(N,N,length(z)-2)-0.5)/10);
DOES_MASK = ones(N,N,size(DOES,3));
tmp_data = zeros(N,N,size(DOES,3));

epoch = 5;
cycle = 1500;
speed = 0.3;
slowdown = 0.9995;
LossFunc = 'SCE';
method = 'Adam';
params = [0.9 0.999 1e-8];
%%
N = N*2;
pixel = pixel/2;
init;

aa = 0.6e-3;
hh = 0.4e-3;
mnist_digits;

DOES = kron(DOES, ones(2));
DOES_MASK = kron(DOES_MASK, ones(2));
tmp_data = kron(tmp_data, ones(2));

epoch = 1;
speed = 0.03;
slowdown = 0.9995;
batch = 20;
deleted = false;
training1;
check_result;

%% test no-gradient training

clear variables;

pixel = 4e-6;
spixel = pixel*2;
lambda = 632.8e-9;
z = [0 0.01 0.02];
init;

mnist_digits;

P = 10000;
epoch = 1;
batch = 1000;
cycle = 1000;
LossFunc = 'SCE';
training2;

check_result;

%% example image generation

clear variables;

pixel = 18e-6;
N = 512;
z = [0 0.15 0.30 0.45];
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

MASK = zeros(size(Train)); ln = 0;

epoch = 8000;
batch = 4;
cycle = 800;
speed = 1;
slowdown = 0.9992;
LossFunc = 'Target';
method = 'Adam';
params = [0.9 0.999 1e-8];
training1;

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
    axis square;
end

clearvars ssau iter;

%% outputs regions
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;

hold on; grid on;
for iter=1:ln
    plot(xx+coords(iter,1), yy+coords(iter,2), '-k');
    text(coords(iter,1), coords(iter,2), num2str(iter-1), ...
        'fontsize', 14, 'HorizontalAlignment', 'center');
end
xlim([-B B]); ylim([-B B]);
axis ij;
axis square;

clearvars xx yy iter;
