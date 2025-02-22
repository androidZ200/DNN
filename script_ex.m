return;
%% standart gradient training

clear variables;

pixel = 4e-6;
spixel = pixel*2;
lambda = 632.8e-9;
N = 512;
is_max = true;
f = [0.01 0.01];
m_prop = 'sinc';
init;

GetImage = create_GetImage_sinc(spixel,28,X{1},Y{1},k,0.01);

Full_width  = 0.6e-3;
Full_height = 0.4e-3;
G_size_x = 50e-6;
G_size_y = G_size_x;
mnist_digits;
% MASK(:,:,end+1) = ones(N) - (sum(MASK,3)>0);


epoch = 4;
batch = 20;
cycle = 2000;
speed = 0.3;
slowdown = 0.9995;
LossFunc = 'SCE';
method = 'Adam';
params = [0.9 0.999 1e-8];
training1;

check_result;

%% 4F-system

clear variables;

f = 0.25;
pixel_doe = 8e-6;
lambda = 532e-9;
N = 1024;
pixel = lambda*f/pixel_doe/N;
spixel = 36e-6;
is_max = true;
init;

Full_width  = 5e-3;
Full_height = 4e-3;
G_size_x = 1e-3;
G_size_y = 1e-3;
mnist_digits;

GetImage = @(W)fft2(normalize_field(resizeimage(W,N(1,1),spixel,pixel(1,1))));
FPropagations = { @(W)fft2(W)/N(1,1) };
BPropagations = FPropagations;

DOES{1} = exp(2i*pi*(rand(N(1,:))-0.5)/10);

epoch = 4;
batch = 20;
cycle = 2000;
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
Old_x = linspace(-spixel*14, spixel*14, 29); Old_x(end) = []; Old_x = Old_x + spixel/2;
lambda = 632.8e-9;
is_max = true;
Full_width  = 0.6e-3;
Full_height = 0.4e-3;
G_size_x = 0.05e-3;
G_size_y = 0.05e-3;
f = [0.01 0.01];

DOES = exp(2i*pi*(rand(N,N,length(f))-0.5)/10);
DOES_MASK = ones(size(DOES));
tmp_data = zeros(size(DOES));
DOES = squeeze(num2cell(DOES,[1 2]));
DOES_MASK = squeeze(num2cell(DOES_MASK,[1 2]));
tmp_data = squeeze(num2cell(tmp_data,[1 2]));

cycle = 2000;
speed = 0.3;
slowdown = 0.9995;
LossFunc = 'SCE';
method = 'Adam';
params = [0.9 0.999 1e-8];
%%
N = N*2;
pixel = pixel/2;
m_prop = 'sinc';
init;
UU = matrix_propagation_sinc(Old_x, X{1}, 0.01, k);
GetImage = @(W)propagation_sinc(normalize_field(W),UU);
mnist_digits;

DOES = cellfun(@(DOES)kron(DOES, ones(2)), DOES, 'UniformOutput', false);
DOES_MASK = cellfun(@(DOES_MASK)kron(DOES_MASK, ones(2)), DOES_MASK, 'UniformOutput', false);
tmp_data = cellfun(@(tmp_data)kron(tmp_data, ones(2)), tmp_data, 'UniformOutput', false);

epoch = 1;
speed = 0.03;
slowdown = 0.9995;
batch = 20;
deleted = false;
training1;
check_result;

%% example image generation

clear variables;

pixel = 18e-6;
N = 512;
B = pixel*N/2;
f = [0.15 0.15 0.15];
m_prop = 'ASM';
init;

sigma = B/8;
alpha = pi/180/10;
Train(:,:,1) = exp(-(X{1}.^2 + Y{1}.^2)/2/sigma^2).*exp( 1i*k*sin(alpha)*X{1});
Train(:,:,2) = exp(-(X{1}.^2 + Y{1}.^2)/2/sigma^2).*exp(-1i*k*sin(alpha)*X{1});
Train(:,:,3) = exp(-(X{1}.^2 + Y{1}.^2)/2/sigma^2).*exp( 1i*k*sin(alpha)*Y{1});
Train(:,:,4) = exp(-(X{1}.^2 + Y{1}.^2)/2/sigma^2).*exp(-1i*k*sin(alpha)*Y{1});
Train = normalize_field(Train);
TrainLabel = [1; 2; 3; 4];
Test = Train;

Target(:,:,1) = ((X{end}.^2 + Y{end}.^2) < (B/4)^2).*((X{end}.^2 + Y{end}.^2) > (B/4.4)^2);
Target(:,:,2) = (max(abs(X{end}), abs(Y{end})) < B/4).*(max(abs(X{end}), abs(Y{end})) > B/4.4);
Target(:,:,3) = (max(abs(X{end}), abs(Y{end})) < B/4).*(min(abs(X{end}), abs(Y{end})) < B*0.05/4.4);
Target(:,:,4) = (max(abs(X{end}), abs(Y{end})) < B/4).*(abs(abs(X{end}) - abs(Y{end})) <  B*0.07/4.4);
Target = (normalize_field(Target)).^2;

epoch = 8000;
batch = 4;
cycle = 800;
speed = 1;
slowdown = 0.9992;
method = 'Adam';
params = [0.9 0.999 1e-8];
training2;

for iter=1:size(Train,3)
    W = GetImage(Train(:,:,iter));
    for iter8=1:length(DOES)
        W = FPropagations{iter8}(W.*DOES{iter8});
    end
    figure; imagesc(abs(W).^2);
end

%% 1-dimension image generation

clear variables;

lambda = 532e-9;
f = 0.2;
N = [5000 1];
pixel = [2e-6; 2*tand(5)*f(1)/N(end,1)];
m_prop = 'sinc';
init;

Train = normalize_field(abs(X{1}) < 5e-3);
TrainLabel = 1;
Target = atan(X{2}*5e2)+pi/2;
Target = Target - min(Target);
Target = Target/sum(Target);

epoch = 100000;
cycle = 1000;
speed = 1e-2;
slowdown = 0.99995;
method = 'Adam';
params = [0.9 0.999 1e-8];
training2;

%% phase function doe

ssau = [linspace(40,  32, 40), linspace( 32,  255, 40), linspace(255, 201, 40), linspace(201, 40, 40);...
        linspace(40, 146, 40), linspace(146,  255, 40), linspace(255,  88, 40), linspace( 88, 40, 40);...
        linspace(40, 201, 40), linspace(201,  255, 40), linspace(255,  32, 40), linspace( 32, 40, 40)]'/255;
ssau(1:40:end,:) = [];

for iter=1:length(DOES)
    figure;
    imagesc([X{iter}(1) X{iter}(end)], [X{iter}(1) X{iter}(end)], angle(DOES{iter}));
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
xlim([X{end}(1) X{end}(end)]); ylim([X{end}(1) X{end}(end)]);
axis ij;
axis square;

clearvars xx yy iter;
