clear all;
init;
load('data/real experiments/experiment 10/DOES.mat');

GetImage = @(W)fft2(normalize_field(resizeimage(W,N,spixel,pixel)));
Propagations = { @(W)fft2(W); };

for num=[0 1 2 3 5 6 7 8]
    W = imread(['data/real experiments/experiment 10/input/' num2str(num) '/1.bmp']);
    F = direct_propagation(GetImage(W), Propagations, DOES(end:-1:1,:,:));
    F = F(sum(x<-2)+1:sum(x<2)+1,sum(x<-2.5)+1:sum(x<2.5)+1,end);
    imwrite(abs(F).^2/max(max(abs(F).^2))/2.5, ['data\images 2\' num2str(num) '.bmp']);
end

return;
%%

clear all;
init;
mnist_digits;
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;
nums = [0 1 2 3 5 6 7 8];

for nn = nums
    ImE = double(imread(['data/img/' num2str(nn) 'e.png']));
    ImM = double(imread(['data/img/' num2str(nn) 'm.bmp']));

    xe = linspace(-2.5, 2.5, size(ImE,2)+1); xe(end) = []; xe = xe + (xe(2)-xe(1))/2;
    ye = linspace(-2.0, 2.0, size(ImE,1)+1); ye(end) = []; ye = ye + (ye(2)-ye(1))/2;
    xm = linspace(-2.5, 2.5, size(ImM,2)+1); xm(end) = []; xm = xm + (xm(2)-xm(1))/2;
    ym = linspace(-2.0, 2.0, size(ImM,1)+1); ym(end) = []; ym = ym + (ym(2)-ym(1))/2;

    [Xe, Ye] = meshgrid(xe, ye);
    [Xm, Ym] = meshgrid(xm, ym);

    ImM = interp2(Xm, Ym, ImM, Xe, Ye); ImM(isnan(ImM))=0;
    X = Xe; Y = Ye; clearvars xe ye xm ym Xe Xm Ye Ym;

    MASK = zeros(size(ImM,1), size(ImM,2), ln);
    for iter = 1:ln
        MASK(:,:,iter) = (abs(X-coords(iter,1)) < G_size_x/2).*(abs(Y-coords(iter,2)) < G_size_y/2);
    end

    scM = get_scores(sqrt(ImM), MASK, false); scM = scM/sum(scM);
    scE = get_scores(sqrt(ImE), MASK, false); scE = scE/sum(scE);

    figure('position', [200 0 600 1000]);
    contr=3.5;
    subplot(2, 1, 1); imagesc([-2.5 2.5], [-2, 2], ImE, [0 max(max(ImE))/contr]); colormap(gray);
    hold on;
    for iter=1:ln
        plot(xx+coords(iter,1), yy+coords(iter,2), '-w');
        text(coords(iter,1), coords(iter,2)+0.35, [sprintf('%.1f%%', scE(iter)*100) '%'], ...
            'fontsize', 10, 'color', [1, 1, 1], 'HorizontalAlignment', 'center');
    end
    subplot(2, 1, 2); imagesc([-2.5 2.5], [-2, 2], ImM); colormap(gray);
    hold on;
    for iter=1:ln
        plot(xx+coords(iter,1), yy+coords(iter,2), '-w');
        text(coords(iter,1), coords(iter,2)+0.35, [sprintf('%.1f%%', scM(iter)*100) '%'], ...
            'fontsize', 10, 'color', [1, 1, 1], 'HorizontalAlignment', 'center');
    end
end

%%

err_tabl = [100 0 0 0 0 0 0 0 0 0; ...
    0 100 0 0 0 0 0 0 0 0; ...
    0 0 90 0 0 0 0 0 0 10; ...
    0 0 0 100 0 0 0 0 0 0; ...
    0 0 0 0 100 0 0 0 0 0; ...
    0 10 0 0 0 90 0 0 0 0; ...
    0 0 0 0 10 0 90 0 0 0; ...
    0 0 0 0 0 0 0 100 0 0; ...
    0 0 0 0 0 0 0 0 80 20; ...
    0 0 0 10 0 0 0 0 10 80]';

int_tabl = [11.8 9.2 10.3 9.4 9.2 10.2 9.4 9.6 10.1 10.7; ...
    9.6 12.3 9.7 8.8 9.8 9.9 9.2 10 11 9.8; ...
    9.6 9.1 12.2 10.3 9.4 10.3 8.9 10.3 9.7 10.3; ...
    9.2 9 10.8 12.2 8.8 11 8.2 9.8 10.2 10.9; ...
    9.3 10.1 10.2 9.1 11.7 9.5 9.2 10.3 10.2 10.5; ...
    10 9.9 9.8 10.1 9.3 11.7 9.3 9.7 10.4 9.8;...
    10.5 9.3 9.6 8.6 10.9 9.9 11.4 9.4 10.2 10.1; ...
    9 9.6 10.6 10.3 9.4 10.2 7.7 12.2 10.2 10.8;...
    10 9.6 9.7 9.8 9.6 10.5 9 9.9 11.1 10.9; ...
    9.1 9.5 9.9 10 9.9 10.4 8.3 10.5 10.8 11.5]';