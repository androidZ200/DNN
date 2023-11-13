clear all;
init;
mnist_digits;

GetImage = @(W)fft2(normalize_field(resizeimage(W,N,spixel,pixel)>0));
Propagations = { @(W)fft2(W); };
DOES = ones(N,N,length(Propagations));

P = 1200;
threads = 10;
batch = 120;
cycle = 120;
method = 'Adam';
params = [0.9 0.999 1e-8];
IntensityFactor = 0;
alghoritm = 2;
training3;

check_result;

return;
% batch    <30    30   60    120     240
% threads    0   0|4    6   8-10   10-12


%%
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;

hold on;
for iter=1:ln
    plot(xx+coords(iter,1), yy+coords(iter,2), '-k');
    text(coords(iter,1), coords(iter,2), num2str(iter-1), 'fontsize', 14, 'HorizontalAlignment', 'center');
end
xlim([-3 3]);
ylim([-3 3]);
grid on;
axis ij;

%%
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;

for num=nums
    for iter=1:20
        imwrite(Train(end:-1:1,:,iter,num+1) > 128, ['data/experiment/input/' num2str(num) '/' num2str(iter) '.bmp'])
        W = resizeimage(Train(:,:,iter,num+1),N,spixel,pixel);
        F = fft2(W);
        imwrite(circshift(abs(F(end:-1:1, :)/max(max(abs(F)))).^2, [N/2 N/2]), ['data/experiment/spector/' num2str(num) '/' num2str(iter) '.bmp'])
        F = fft2(F.*DOES);
        tmp = get_scores(F, MASK, is_max);
        tmp = tmp./sum(tmp);

        imagesc([-B B]/2, [-B B]/2, abs(F(N/2-N/4:N/2+N/4+1, N/2-N/4:N/2+N/4+1)).^2);
        hold on;
        colormap(gray);
        axis xy;
        for num2=1:ln
            plot(xx+coords(num2,1), yy+coords(num2,2), 'color', [1 0 0]);
            text(coords(num2, 1), coords(num2, 2)-G_size_y*0.8, sprintf('%.2f%%', tmp(num2)*100), ...
                    'fontsize', 8, 'color', [1 0 0], 'HorizontalAlignment', 'center');
        end
        saveas(gca, ['data/experiment/output/' num2str(num) '/' num2str(iter) '.png']);
    end
end
imwrite(circshift((angle(DOES(end:-1:1, :))+pi)/2/pi, [N/2 N/2]), 'data/experiment/DOE.bmp');