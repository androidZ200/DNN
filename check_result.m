
sz = size(INPUT,3);
figure;
for iter=1:sz
    F = recognize(INPUT(:,:,iter), [doe_plane, output_plane(iter)], DOES, k, U);
    
    subplot(3, sz, iter + sz*0);
    imagesc([-A/2 A/2], [-A/2 A/2], abs(INPUT(:,:,iter)));
    axis xy;
    subplot(3, sz, iter + sz*1);
    imagesc([-A/2 A/2], [-A/2 A/2], abs(OUTPUT(:,:,iter)));
    axis xy;
    subplot(3, sz, iter + sz*2);
    imagesc([-A/2 A/2], [-A/2 A/2], abs(F(:,:,end)));
    axis xy;
end

clearvars iter F sz;