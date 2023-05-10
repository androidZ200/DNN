
sz = size(INPUT,3);
for iter=1:sz
    F = recognize(INPUT(:,:,iter), [doe_plane, output_plane(iter)], DOES, k, U);
    mask = OUTPUT(:,:,iter) > 0;
    epsilon(iter) = sum(sum(abs(F(:,:,end).*mask).^2))/sum(sum(OUTPUT(:,:,iter)))*100;
    mask = max(abs(X), abs(Y)) < A/4*1.2;
    delta(iter) = sqrt(sum(sum((abs(F(:,:,end).*mask).^2 - epsilon(iter)/100*OUTPUT(:,:,iter)).^2))/ ...
        sum(sum(mask)))/(sum(sum(abs(F(:,:,end).*mask).^2))/sum(sum(mask)))*100;

    figure;
    imagesc([-A A], [-A A], abs(F(:,:,end)).^2);
    title({['\epsilon = ' num2str(epsilon(iter)) '%'],['\delta = ' num2str(delta(iter)) '%']});
    axis xy;
    colormap(ssau);
end

clearvars iter F sz mask;