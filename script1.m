clear all;
init;

sigma = A/8;
alpha = pi/180/10;
INPUT(:,:,1) = exp(-(X.^2 + Y.^2)/2/sigma^2).*exp( 1i*k*sin(alpha)*X);
INPUT(:,:,2) = exp(-(X.^2 + Y.^2)/2/sigma^2).*exp(-1i*k*sin(alpha)*X);
INPUT(:,:,3) = exp(-(X.^2 + Y.^2)/2/sigma^2).*exp( 1i*k*sin(alpha)*Y);
INPUT(:,:,4) = exp(-(X.^2 + Y.^2)/2/sigma^2).*exp(-1i*k*sin(alpha)*Y);

OUTPUT(:,:,1) = ((X.^2 + Y.^2) < (A/4)^2).*((X.^2 + Y.^2) > (A/4.4)^2);
OUTPUT(:,:,2) = (max(abs(X), abs(Y)) < A/4).*(max(abs(X), abs(Y)) > A/4.4);
OUTPUT(:,:,3) = (max(abs(X), abs(Y)) < A/4).*(min(abs(X), abs(Y)) < A*0.05/4.4);
OUTPUT(:,:,4) = (max(abs(X), abs(Y)) < A/4).*(abs(abs(X) - abs(Y)) <  A*0.07/4.4);

for iter=1:size(INPUT, 3)
    INPUT(:,:,iter) = INPUT(:,:,iter)/sqrt(sum(sum(abs(INPUT(:,:,iter)).^2)));
    OUTPUT(:,:,iter) = OUTPUT(:,:,iter)/sum(sum(OUTPUT(:,:,iter)));
end

INP_save = INPUT;
for iter21=1:3
    doe_plane = linspace(0, 0.6, iter21+2)/metric;
    doe_plane(1) = [];
    first = doe_plane(1);
    for iter22 = 1:size(INPUT,3)
        INPUT(:,:,iter22) = propagation(INP_save(:,:,iter22), first, k, U);
    end
    doe_plane = doe_plane - first;
    output_plane = repmat(doe_plane(end), [1 size(INPUT,3)]);
    doe_plane(end) = [];
    DOES = ones(N,N,length(doe_plane));

    iteration = 1024*8;
    speed = 1e0;
    slowdown = 0.9992;
    method = 'adam';
    params = [0.9 0.999 1e-8];
    training;
    
    loss_graph(1) = [];
    doe_plane = doe_plane + first;
    output_plane = output_plane + first;
    INPUT = INP_save;
    save(['data/image generation/save' num2str(iter21) '_600.mat'], 'DOES', 'doe_plane', 'output_plane', 'loss_graph', ...
        'INPUT', 'OUTPUT');
    clear loss_graph;
end



clearvars iter iter21 iter22 INP_save first;