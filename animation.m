% animation of radiation propagation through the entire DOE system

W = Test(:,:,randi([1 size(Test,3)]));
W = resizeimage(W,N,spixel,pixel);
W = normalize_field(W);
score = recognize(propagation(W, U(:,:,1), m_prop), Propagations, DOES, MASK, is_max);
score = score/sum(score)*100;

fig = figure;
imagesc([-B B], [-B B], abs(W));
title(['z = ' num2str(z(1)) ' mm']);
pause(3);
h = (z(end)-z(1))/100;
for zone=1:length(z)-1
    for zz = z(zone):h:z(zone+1)
        UU = matrix_propagation(X,Y,zz - z(zone),k,m_prop);
        imagesc([-B B], [-B B], abs(propagation(W,UU,m_prop)));
        title(['z = ' num2str(zz*1000) ' mm']);
        pause(0.05);
    end
    UU = matrix_propagation(X,Y,z(zone+1)-z(zone),k,m_prop);
    W = propagation(W,UU,m_prop);
    if zone ~= length(z)-1
        W = W.*DOES(:,:,zone);
    end
end

if exist('coords', 'var') == 1
    hold on;
    xx = [-1 -1  1  1 -1]*G_size_x/2;
    yy = [ 1 -1 -1  1  1]*G_size_y/2;
    for nt=1:ln
        plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [1 1 1]);
        text(coords(nt, 1), coords(nt, 2)-G_size_y/2*1.5, sprintf('%.2f%%', score(nt)), ...
                        'fontsize', 14, 'HorizontalAlignment', 'center', 'color', [1 1 1]);
    end
end

% pause(8); close(fig);

clearvars fig zone zz W nt xx yy score h UU;