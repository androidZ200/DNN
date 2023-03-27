
x = [-1 -1 1 1 -1]*G_size/2;
y = [1 -1 -1 1 1]*G_size/2;
figure;
hold on;

for iter=1:ln
plot(x+coords(iter,1), y+coords(iter,2), 'color', [0 0 0]);
end

xlim([-B B]);
ylim([-B B]);
grid on;
clearvars x y iter;

%%

figure;
hold on;

% plot(1:64:length(accr1)*64, accr1, '-', 'color', [32 145 201]/255);
% plot(1:64:length(accr1)*64, accr2, '--', 'color', [201 88 32]/255);
plot(1:64:length(accr1)*64, accr1, '-', 'color', [0 0 0]);
plot(1:64:length(accr1)*64, accr2, '--', 'color', [0 0 0]);
grid on;
ylim([0 100]);
xlim([0 length(accr1)*64]);

legend('СКО', 'Кросс-энтропия');

%%

figure
imagesc([-B B], [-B B], angle(DOES1));
colormap(gray);
axis xy;
figure
imagesc([-B B], [-B B], angle(DOES2));
colormap(gray);
axis xy;

%%

num = 4;% randi([1 ln]);
W = resizeimage(Test(:,:,3,num),N,AN);
[tmp, F] = recognize(X,Y,W,z,DOES,k,coords,G_size,U);
tmp = tmp./sum(tmp);
gr = gray;
gr = gr(end:-1:1, :);

figure;
imagesc([-B B], [-B B], abs(F(:,:,end)).^2);
colormap(gr);
grid on;
axis xy;
for nt=1:length(nums)
    text(coords(nt, 1)-A*4*0.2, coords(nt, 2)-A*4*0.4, sprintf('%.2f%%', tmp(nt)*100), 'fontsize', 14);
end

figure;
imagesc([-B B], [-B B], (abs(F(:,:,1))).^0.8);
colormap(gr);
axis xy;

figure;
imagesc([-A A], [-A A], W(N/2-AN/2+1:N/2+AN/2, N/2-AN/2+1:N/2+AN/2));
colormap(gr);
axis xy;

clearvars num W F tmp gr nt;