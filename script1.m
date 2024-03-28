clear variables;

lambda = 632.8e-9;
pixel = 4e-6;
spixel = 4*pixel;
z = [0 0.03 0.06];
m_prop = 'sinc';
init;

aa = 0.6e-3;
hh = 0.4e-3;
G_size_x = 50e-6;
G_size_y = 50e-6;
mnist_digits;

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

return;
%%

clear variables;

N = 256;
lambda = 632.8e-9;
pixel = 4e-6;
init;

W = single(X.^2 + Y.^2 < (1*B/16)^2);
W = normalize_field(W);
W = DOES.*W;

zz = linspace(0,0.03,300);
E = zeros(4, length(zz));

figure; pause(5);
for iter=1:length(zz)
    z = zz(iter);
    m_prop = 'ASM';
    F1 = propagation(W, matrix_propagation(X,Y,z,k,m_prop), m_prop);
    m_prop = 'sphere';
    F2 = propagation(W, matrix_propagation(X,Y,z,k,m_prop), m_prop);
    m_prop = 'fresnel';
    F3 = propagation(W, matrix_propagation(X,Y,z,k,m_prop), m_prop);
    m_prop = 'sinc';
    F4 = propagation(W, matrix_propagation(X,Y,z,k,m_prop), m_prop);
    
    E(1,iter) = sum(sum(abs(F1).^2));
    E(2,iter) = sum(sum(abs(F2).^2));
    E(3,iter) = sum(sum(abs(F3).^2));
    E(4,iter) = sum(sum(abs(F4).^2));

    subplot(2,2,1); imagesc(abs(F1)); title('ASM');
    subplot(2,2,2); imagesc(abs(F2)); title('sphere');
    subplot(2,2,3); imagesc(abs(F3)); title('fresnel');
    subplot(2,2,4); imagesc(abs(F4)); title('sinc');
    pause(0.001)
end

subplot(1,1,1);
hold on; grid on;
plot(zz, E(1,:));
plot(zz, E(2,:));
plot(zz, E(3,:));
plot(zz, E(4,:));
legend('ASM', 'sphere', 'fresnel', 'sinc');


%%

clear variables;

pixel = 0.2e-6;
N = 1024;
lambda = 400e-9;
m_prop = 'sphere';
z = [0 250e-6];
init;

W = normalize_field(max(abs(X), abs(Y)) < pixel*N/4);
F = propagation(W, U, m_prop);

sum(sum(abs(F).^2))