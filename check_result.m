
sz = size(INPUT,3);
figure;
for iter=1:sz
    F = recognize(INPUT(:,:,iter), [doe_plane, output_plane(iter)], DOES, k, U);
    mask = OUTPUT(:,:,iter) > 0;
    epsilon(iter) = sum(sum(abs(F(:,:,end).*mask).^2))/sum(sum(OUTPUT(:,:,iter)))*100;
    delta(iter) = sqrt(sum(sum((abs(F(:,:,end).*mask).^2 - OUTPUT(:,:,iter)).^2))/sum(sum(mask)))/...
        (sum(sum(OUTPUT(:,:,iter)))/sum(sum(mask)))*100;
    
    subplot(3, sz, iter + sz*0);
    imagesc([-A/2 A/2], [-A/2 A/2], abs(INPUT(:,:,iter)));
    axis xy;
    title({['eps = ' num2str(epsilon(iter)) '%'],['delta = ' num2str(delta(iter)) '%']})
    subplot(3, sz, iter + sz*1);
    imagesc([-A/2 A/2], [-A/2 A/2], abs(OUTPUT(:,:,iter)));
    axis xy;
    subplot(3, sz, iter + sz*2);
    imagesc([-A/2 A/2], [-A/2 A/2], abs(F(:,:,end)));
    axis xy;
end

clearvars iter F sz mask;