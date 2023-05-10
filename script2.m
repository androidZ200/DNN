clear all;
init;

for iter21=3:3
    load(['data\image generation\save' num2str(iter21) '_600.mat']);
    INP_save = INPUT;
    first = doe_plane(1);
    for iter22=1:size(INPUT,3)
        INPUT(:,:,iter22) = propagation(INPUT(:,:,iter22), first, k, U);
    end
    loss_graph = [nan, loss_graph];
    doe_plane = doe_plane - first;
    output_plane = output_plane - first;

    iteration = 1024*16;
    speed = 4e-3;
    slowdown = 1;
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