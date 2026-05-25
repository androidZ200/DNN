addpath(genpath(pwd));
return;
%% standart gradient training

clear variables;

mnist_digits;
global is_gpu; is_gpu = true;
lambda = 632.8e-9;
f = 0.01;
mesh = Mesh(4e-6, 512);
mesh_inp = Mesh(8e-6, 28);
opt = AdamFabric();

dc = InputModulator(mesh_inp);
dc = SincPropagator(dc, f, lambda);
dc = PhaseDOE(mesh, dc, opt); doe1 = dc;
dc = SincPropagator(dc, f, lambda);
dc = GetMaskSum(mesh, dc, mask10_1(mesh,[1.2e-3, 0.9e-3],250e-6));
dc = Predictor(dc); predictor = dc;
dc = Normalization(dc);
% Error = ErrorSCE(dc, 80);
Error = ErrorMAE(dc);

epoch = 2;
batch = 20;
cycle = 6000;
speed = 0.3;
slowdown = 0.9995;
training1;

check_result;

%% 4F-system

clear variables;

mnist_digits;
global is_gpu; is_gpu = true;
f = 0.25;
lambda = 532e-9;

mesh_doe = Mesh(8e-6, 1024);
mesh_lens = Mesh(3e-6, 4096);
mesh_inp = Mesh(36e-6, 28);

Input = GetInput(mesh_inp,@(W)normalize_field(GPUTest(W)));
Layers = SequentialSystem({ ...
    SincPropagator(f, lambda), ...
    PhaseDOE(mesh_lens).set_phi(-2*pi/lambda/f*(mesh_lens.X.^2 + mesh_lens.Y.^2)), ...
    SincPropagator(f, lambda), ...
    PhaseDOE(mesh_doe, AdamFabric()), ...
    SincPropagator(f, lambda), ...
    PhaseDOE(mesh_lens).set_phi(-2*pi/lambda/f*(mesh_lens.X.^2 + mesh_lens.Y.^2)), ...
    SincPropagator(f, lambda)});
Output = GetMaskSum(mesh_doe,mask10_1(mesh_doe,[5e-3, 4e-3],1e-3));

OptSystem = OpticalSystem(Input,Layers,Output);

epoch = 4;
batch = 20;
cycle = 6000;
speed = 0.3;
slowdown = 0.9995;
LossFunc = ErrorSCENorm(80);
training1;

check_result;

%% iterative alghoritm

clear variables;

N = 256/2;
pixel = 4e-6*512/N;
spixel = 8e-6;
Old_x = linspace_m(-spixel*14, spixel*14, 28);
lambda = 632.8e-9;
is_max = true;
disp_info = 1;
mnist_digits;
Full_width  = 0.6e-3;
Full_height = 0.4e-3;
G_size_x = 0.05e-3;
G_size_y = 0.05e-3;
f = [0.01 0.01];

DOES = exp(2i*pi*(rand(N,N,length(f))-0.5)/10);
GRAD_MASK = ones(size(DOES));
DOES = squeeze(num2cell(DOES,[1 2]));
GRAD_MASK = squeeze(num2cell(GRAD_MASK,[1 2]));

cycle = 2000;
speed = 0.3;
slowdown = 0.9995;
LossFunc = 'SCE';
%%
N = N*2;
pixel = pixel/2;
m_prop = 'sinc';
init;
UU = matrix_propagation_sinc(Old_x, X{1}, 0.01, k);
GetImage = @(W)propagation_sinc(normalize_field(W),UU);
mask10_1;

DOES = cellfun(@(DOES)kron(DOES, ones(2)), DOES, 'UniformOutput', false);
GRAD_MASK = cellfun(@(GRAD_MASK)kron(GRAD_MASK, ones(2)), GRAD_MASK, 'UniformOutput', false);

epoch = 1;
speed = 0.03;
slowdown = 0.9995;
batch = 20;
deleted = false;
optimizer = Adam_optimizer(N,is_gpu);
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
optimizer = Adam_optimizer(N,is_gpu);
training2;

W = GetImage(Train);
for iter8=1:length(DOES)
    W = FPropagations{iter8}(DOES{iter8}.*W);
end
for iter=1:size(Train,3)
    figure; imagesc(abs(W(:,:,iter)).^2);
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
Target = atan(X{2}*5e2)+pi/2;
Target = Target - min(Target);
Target = Target/sum(Target);

epoch = 100000;
cycle = 1000;
speed = 1e-2;
slowdown = 0.99995;
optimizer = Adam_optimizer(N,is_gpu);
training2;

%% image function doe

for iter=1:length(DOES)
    figure;
    imagesc(DOES{iter});
    title(['DOE ' num2str(iter)]);
end

clearvars iter;

%% outputs regions

xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;

hold on; grid on;
for iter=1:size(MASK,3)
    plot(xx+coords(iter,1), yy+coords(iter,2), '-k');
    text(coords(iter,1), coords(iter,2), Labels{iter}, ...
        'fontsize', 14, 'HorizontalAlignment', 'center');
end
xlim([X{end}(1) X{end}(end)]); ylim([X{end}(1) X{end}(end)]);
axis ij;
axis square;

clearvars xx yy iter;
