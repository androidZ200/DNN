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
MASK = mask10_1(mesh,[1.2e-3, 0.9e-3],250e-6);

dc = InputModulator(mesh_inp, @(W)normalize_field(W));
dc = SincPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), opt); doe = dc;
dc = ASMPropagator(dc, f, lambda);
dc = GetMaskSum(mesh, dc, MASK); decoder = dc;
dc = Normalization(dc); 
Error = ErrorSCE(dc, ClassificationTarget(dc.count_outputs(), length(unique(TrainLabel))), 80);
predictor = Error;

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

mesh_doe = Mesh(16e-6, 512);
mesh_lens = Mesh(3e-6, 4096);
mesh_inp = Mesh(36e-6, 28);
MASK = mask10_1(mesh_doe,[5e-3, 4e-3],1e-3);

dc = InputModulator(mesh_inp, @(W)normalize_field(W));

dc = CompiledMatrixPropagator(dc);
dc.add_next(SincPropagator(dc, f, lambda));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "X").set_data(-2*pi/lambda/f/2*mesh_lens.X.^2));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "Y").set_data(-2*pi/lambda/f/2*mesh_lens.Y.^2));
dc.add_next(SincPropagator(dc, f, lambda));

dc = FullDOE(dc, mesh_doe, PhaseDOE(), AdamFabric()); doe = dc;

dc = CompiledMatrixPropagator(dc);
dc.add_next(SincPropagator(dc, f, lambda));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "X").set_data(-2*pi/lambda/f/2*mesh_lens.X.^2));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "Y").set_data(-2*pi/lambda/f/2*mesh_lens.Y.^2));
dc.add_next(SincPropagator(dc, f, lambda));

dc = GetMaskSum(mesh_doe, dc, MASK); decoder = dc;
dc = Normalization(dc); 
Error = ErrorSCE(dc, ClassificationTarget(dc.count_outputs(), length(unique(TrainLabel))), 80);
predictor = Error;

epoch = 4;
batch = 20;
cycle = 6000;
speed = 0.3;
slowdown = 0.9995;
training1;

check_result;

%% example image generation

clear variables;
global is_gpu; is_gpu = true;

f = 0.15;
lambda = 532e-9; k = 2*pi/lambda;
mesh = Mesh(18e-6, 512);
B = 18e-6*512/2;
sigma = B/8;
alpha = pi/180/10;

Amp = normalize_field(exp(-(mesh.X.^2 + mesh.Y.^2)/2/sigma^2));
Train(:,:,1) = Amp.*exp( 1i*k*sin(alpha)*mesh.X);
Train(:,:,2) = Amp.*exp(-1i*k*sin(alpha)*mesh.X);
Train(:,:,3) = Amp.*exp( 1i*k*sin(alpha)*mesh.Y);
Train(:,:,4) = Amp.*exp(-1i*k*sin(alpha)*mesh.Y);
TrainLabel = 1:size(Train,3);

Target(:,:,1) = ((mesh.X.^2 + mesh.Y.^2) < (B/4)^2).*((mesh.X.^2 + mesh.Y.^2) > (B/4.4)^2);
Target(:,:,2) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*(max(abs(mesh.X), abs(mesh.Y)) > B/4.4);
Target(:,:,3) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*(min(abs(mesh.X), abs(mesh.Y)) < B*0.05/4.4);
Target(:,:,4) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*(abs(abs(mesh.X) - abs(mesh.Y)) <  B*0.07/4.4);
Target = normalize_field(Target).^2;

dc = InputModulator(mesh, @(W)W);
dc = ASMPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
dc = ASMPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
dc = ASMPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
dc = ASMPropagator(dc, f, lambda);
dc = GetFullIntensity(mesh, dc);
Error = ErrorMSE(dc, GenerationTarget(Target));

batch = size(Train,3);
epoch = batch*2000;
cycle = epoch*batch/10;
speed = 1;
slowdown = 0.9992;
training1;

for iter=1:size(Train,3)
    figure;
    imagesc(dc.intensity(Train(:,:,iter)));
end

%% 1-dimension image generation

clear variables;
global is_gpu; is_gpu = true;
lambda = 532e-9;
f = 0.2;

mesh_in = Mesh(2e-6, [5000 1]);
mesh_out= Mesh(2*tand(5)*f/size(mesh_in,1), size(mesh_in));

Train = normalize_field(abs(mesh_in.X) < 5e-3);
TrainLabel = 1;
Target = atan(mesh_out.X*5e2)+pi/2;
Target = Target - min(Target);
Target = Target/sum(Target);

dc = InputModulator(mesh_in);
dc = FullDOE(dc, mesh_in, PhaseDOE(), AdamFabric());
dc = SincPropagator(dc, f, lambda);
dc = GetFullIntensity(mesh_out, dc);
Error = ErrorMSE(dc, GenerationTarget(Target));

epoch = 100000;
cycle = epoch/20;
speed = 1e-2;
slowdown = 0.99995;
training1;

plot(dc.intensity(Train));
hold on;
plot(Target);
