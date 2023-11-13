clear all;
init;
mnist_digits;

load('data/Georgy''s results/approx/test_00.mat');
load('data/Georgy''s results/approx/test_02.mat');

acc_min = min(min(min(Accuracy_0)), min(min(Accuracy_2)));
acc_max = max(max(max(Accuracy_0)), max(max(Accuracy_2)));

int_min = min(min(min(MinContrast_0)), min(min(MinContrast_2)));
int_max = max(max(max(MinContrast_0)), max(max(MinContrast_2)));

figure;
imagesc(-2:2,-2:2, Accuracy_2, [acc_min acc_max]);
colormap([linspace(1, 32/255, 8)', linspace(1, 145/255, 8)', linspace(1, 201/255, 8)']);
xlabel('\Delta X, пиксель');
ylabel('\Delta Y, пиксель');
for ii = 1:5
    for jj = 1:5
        text(ii-3, jj-3, sprintf('%.1f', Accuracy_2(jj, ii)), 'fontsize', 14, 'color', [0 0 0], ...
            'HorizontalAlignment', 'center');
    end
end



figure;
imagesc(-2:2,-2:2, MinContrast_2, [int_min int_max]);
colormap([linspace(1, 201/255, 8)', linspace(1, 88/255, 8)', linspace(1, 32/255, 8)']);
xlabel('\Delta X, пиксель');
ylabel('\Delta Y, пиксель');
for ii = 1:5
    for jj = 1:5
        text(ii-3, jj-3, sprintf('%.1f', MinContrast_2(jj, ii)*100), 'fontsize', 14, 'color', [0 0 0], ...
            'HorizontalAlignment', 'center');
    end
end