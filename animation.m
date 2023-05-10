% animation of radiation propagation through the entire DOE system
num = 2;
W = INPUT(:,:,num);

fig = figure;
pause(2);
zones = [0 doe_plane output_plane(num)];
for zone=1:length(zones)-1
    for zz = zones(zone):1:zones(zone+1)
        imagesc([-A A], [-A A], abs(propagation(W, zz - zones(zone), k, U)), [0 0.03]);
        axis xy;
        title(['z = ' num2str(zz)]);
        pause(0.01);
    end
    W = propagation(W, zones(zone+1)-zones(zone), k, U);
    if zone ~= length(doe_plane)+1
        W = W.*DOES(:,:,zone);
    end
end

pause(5);
close(fig);

clearvars fig num zones zone zz W;
