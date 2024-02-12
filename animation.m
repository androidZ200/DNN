% animation of radiation propagation through the entire DOE system

W = normalize_field(resizeimage(Test(:,:,randi([1 size(Test,3)])),N,spixel,pixel));
score = recognize(propagation(W, U(:,:,1)), Propagations, DOES, MASK, is_max);
score = score/sum(score)*100;

fig = figure;
imagesc(x, x, abs(W));
title(['z = ' num2str(z(1)) ' mm']);
pause(3);
zones = z;
h = (z(end)-z(1))/100;
UU = matrix_propagation(X,Y,h,k);
for zone=1:length(zones)-1
    F = W;
    for zz = zones(zone):h:zones(zone+1)
        F = propagation(F, UU);
        imagesc(x, x, abs(F));
        title(['z = ' num2str(zz*metric*1000) ' mm']);
        pause(0.05);
    end
    W = propagation(W, U(:,:,zone));
    if zone ~= length(zones)-1
        W = W.*DOES(:,:,zone);
    end
end
hold on;
xx = [-1 -1  1  1 -1]*G_size_x/2;
yy = [ 1 -1 -1  1  1]*G_size_y/2;
for nt=1:ln
    plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [1 1 1]);
    text(coords(nt, 1), coords(nt, 2)-G_size_y/2*1.5, sprintf('%.2f%%', score(nt)), ...
                    'fontsize', 14, 'HorizontalAlignment', 'center', 'color', [1 1 1]);
end

pause(6);
close(fig);

clearvars fig zones zone zz W F nt xx yy score h UU;
