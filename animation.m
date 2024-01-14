% animation of radiation propagation through the entire DOE system

W = normalize_field(resizeimage(Test(:,:,randi([1 size(Test,3)])),N,spixel,pixel));
score = recognize(propagation(W, 10, U), Propagations, DOES, MASK, is_max);
score = score/sum(score)*100;

fig = figure;
imagesc(x, x, abs(W), [0 0.02]);
pause(3);
zones = [0 10 20];
for zone=1:length(zones)-1
    for zz = zones(zone):0.2:zones(zone+1)
        imagesc(x, x, abs(propagation(W, zz - zones(zone), U)), [0 0.01]);
        title(['z = ' num2str(zz)]);
        pause(0.05);
    end
    W = propagation(W, zones(zone+1)-zones(zone), U);
    if zone ~= length(zones)-1
        W = W.*DOES(:,:,zone);
    end
end
hold on;
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;
for nt=1:ln
    plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [1 1 1]);
    text(coords(nt, 1), coords(nt, 2)-G_size_y/2-0.1, sprintf('%.2f%%', score(nt)), ...
                    'fontsize', 14, 'HorizontalAlignment', 'center', 'color', [1 1 1]);
end

pause(6);
close(fig);

clearvars fig zones zone zz W nt xx yy score;
