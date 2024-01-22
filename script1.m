clear all;
pixel = 4e-6/0.001;
spixel = pixel*2;
lambda = 632.8e-9/0.001;
N = 512;
init;

mnist_digits;

GetImage = @(W)propagation(normalize_field(resizeimage(W,N,spixel,pixel)), 10, U);
Propagations = { @(W)propagation(W, 10, U); };

for iter3 = 0:2
    DOES = exp(2i*pi*rand(N,N,length(Propagations)));

    epoch = 5;
    batch = 20;
    cycle = 1200;
    speed = 0.1;
    slowdown = 0.9996;
    LossFunc = 'SCE';
    method = 'Adam';
    params = [0.9 0.999 1e-8];
    max_offsets = iter3;
    training1;

    check_offsets;
    save(['offsets_' num2str(iter3)]);
end

return;

%%
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
% batch    <30    30   60    120     240
% threads    0   0|4    6   8-10   10-12

%%
% example image generation

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

%%

DOES = exp(2i*pi*rand(N,N,length(Propagations)));
for iter=1:50
    W = GetImage(Train(:,:,1));
    [me, W, mi] = recognize(W,Propagations,DOES,MASK,is_max);
    F = zeros(N);
    W(:,:,end) = conj(W(:,:,end));

    me = exp(me/max(me)*8);
    for num2=1:ln
        F = F + W(:,:,end)*me(num2).*mi(:,:,num2);
    end
    F = F - W(:,:,end)*sum(me).*mi(:,:,1);

    F = reverse_propagation(F, Propagations, DOES);
    DOES1 = exp(1i*(pi-angle(W(:,:,1:end-1).*F)));
    imagesc(abs(DOES - DOES1)); colorbar; pause(0.1);
    DOES = DOES1;
end



%%
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;

hold on;
for iter=1:ln
    plot(xx+coords(iter,1), yy+coords(iter,2), '-k');
    text(coords(iter,1), coords(iter,2), num2str(iter-1), 'fontsize', 14, 'HorizontalAlignment', 'center');
end
xlim([-3 3]);
ylim([-3 3]);
grid on;
axis ij;

%%
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;

for num=nums
    for iter=1:20
        imwrite(Train(end:-1:1,:,iter,num+1) > 128, ['data/experiment/input/' num2str(num) '/' num2str(iter) '.bmp'])
        W = resizeimage(Train(:,:,iter,num+1),N,spixel,pixel);
        F = fft2(W);
        imwrite(circshift(abs(F(end:-1:1, :)/max(max(abs(F)))).^2, [N/2 N/2]), ['data/experiment/spector/' num2str(num) '/' num2str(iter) '.bmp'])
        F = fft2(F.*DOES);
        tmp = get_scores(F, MASK, is_max);
        tmp = tmp./sum(tmp);

        imagesc([-B B]/2, [-B B]/2, abs(F(N/2-N/4:N/2+N/4+1, N/2-N/4:N/2+N/4+1)).^2);
        hold on;
        colormap(gray);
        axis xy;
        for num2=1:ln
            plot(xx+coords(num2,1), yy+coords(num2,2), 'color', [1 0 0]);
            text(coords(num2, 1), coords(num2, 2)-G_size_y*0.8, sprintf('%.2f%%', tmp(num2)*100), ...
                    'fontsize', 8, 'color', [1 0 0], 'HorizontalAlignment', 'center');
        end
        saveas(gca, ['data/experiment/output/' num2str(num) '/' num2str(iter) '.png']);
    end
end
imwrite(circshift((angle(DOES(end:-1:1, :))+pi)/2/pi, [N/2 N/2]), 'data/experiment/DOE.bmp');

%%
gpuDevice
%%
N = 512;
M = 1000;
A = rand(N);
B = rand(N);

tic;
for iter=1:M
    C = A.*B;
end
display(['cpu time = ' num2str(toc/M)]);

A = gpuArray(A);
B = gpuArray(B);

tic;
for iter=1:M
    C = A.*B;
end
display(['gpu time = ' num2str(toc/M)]);

display(' ');
