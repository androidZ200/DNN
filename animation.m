% animation of radiation propagation through the entire DOE system
num = randi([1 ln]);
W = resizeimage(Test(:,:,randi([1 TestData(num)]),num),N,AN);

fig = figure;
zones = [0 z];
for zone=1:length(z)
    for zz = zones(zone):5:zones(zone+1)
        imagesc(x, x, abs(propagation(W, zz - zones(zone), k, U)), [0 0.03]);
        axis xy;
        title(['z = ' num2str(zz)]);
        pause(0.01);
    end
    W = propagation(W, zones(zone+1)-zones(zone), k, U);
    if zone ~= length(z)
        W = W.*DOES(:,:,zone);
    end
end

pause(3);
close(fig);

clearvars fig num zones zone zz W;
