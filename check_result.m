
if ~exist('decoder', 'var') || ~isa(decoder, "Decoder"); error('decoder is not exist'); end

TestScores = zeros(decoder.count_outputs(), size(Test,3), 'single'); % scores
decoder.clear();

if ~exist('max_batch', 'var'); max_batch = 40; end
max_batch = min(size(Test,3), max_batch);

ttcr = tic();
ndisp(['check result\n' waitbartext(60, -1) ' 0%']);
for iter3=1:size(Test,3)/max_batch
    % running through the system
    TestScores(:,(iter3-1)*max_batch+1:iter3*max_batch) = ...
        decoder.get_output(Test(:,:,(iter3-1)*max_batch+1:iter3*max_batch));
    decoder.clear();
    
    rdisp(['check result\n' waitbartext(60, iter3/size(Test,3)*max_batch) ...
            ' ' num2str(iter3*max_batch/size(Test,3)*100,'%.2f') '%']);
end
rdisp(['check result takes time: ' num2str(toc(ttcr)) 's']);
%%
% error table
[~, argmax] = max(TestScores);
err_tabl = zeros(Error.decoder.count_outputs(), length(Labels), size(Test,3), 'single');
err_tabl(argmax + Error.decoder.count_outputs()*(reshape(TestLabel,1,[])-1) + ...
    Error.decoder.count_outputs()*length(Labels)*(0:(size(Test,3)-1))) = 1;
err_tabl = sum(err_tabl,3);

% intensity table
onehot = reshape(TestLabel,1,[]) == (1:length(Labels))';
int_tabl = (TestScores./sum(TestScores)) * onehot';
%%
% accuracy info
accuracy = sum(diag(err_tabl))/sum(sum(err_tabl))*100;
int_tabl = int_tabl./sum(int_tabl)*100;
ndisp(['accuracy = ' num2str(accuracy) '%;']);
% min contrast info
T = sort(int_tabl);
min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
ndisp(['min contrast = ' num2str(min_contrast) '%;']);

clearvars max_batch ttcr iter3 argmax onehot T;
return


%% error table
% output of a beautiful error table
grad = 100;
figure;
imagesc(bsxfun(@rdivide, err_tabl, sum(err_tabl)));
xlabel('input class'); ylabel('recognized class');
xticks(1:size(err_tabl,1)); yticks(1:size(err_tabl,2));
xticklabels(Labels); yticklabels(Labels);
colormap([linspace(1, 32/255, grad)', linspace(1, 145/255, grad)', linspace(1, 201/255, grad)']);
for ii = 1:size(err_tabl,2)
    for jj = 1:size(err_tabl,1)
        color = [0 0 0];
        if err_tabl(jj, ii)/sum(err_tabl(:, ii)) > 0.5
            color = [1 1 1];
        end
        text(ii, jj, replace(sprintf('%.1f', err_tabl(jj, ii)/sum(err_tabl(:, ii))*100), '.', ','), ...
            'fontsize', 14, 'color', color, 'HorizontalAlignment', 'center');
    end
end
accuracy = sum(diag(err_tabl))/sum(sum(err_tabl,1))*100;
title(['accuracy = ' replace(num2str(accuracy), '.', ',') '%;']);
ndisp(['accuracy = ' num2str(accuracy) '%;']);
clearvars ii jj grad color;
return;

%% intensity table
% output of a beautiful intensity table
grad = 100;
figure;
imagesc(int_tabl);
xlabel('input class'); ylabel('recognized class');
xticks(1:size(int_tabl,2)); yticks(1:size(int_tabl,1));
xticklabels(Labels); yticklabels(Labels);
colormap([linspace(1, 201/255, grad)', linspace(1, 88/255, grad)', linspace(1, 32/255, grad)']);
for ii = 1:size(int_tabl,2)
    for jj = 1:size(int_tabl,1)
        color = [0 0 0];
        text(ii, jj, replace(sprintf('%.1f', int_tabl(jj, ii)), '.', ','), 'fontsize', 14, ...
            'color', color, 'HorizontalAlignment', 'center');
    end
end
T = sort(int_tabl);
min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
title(['min contrast = ' replace(num2str(min_contrast), '.', ',') '%;']);
ndisp(['min contrast = ' num2str(min_contrast) '%;']);
clearvars ii jj grad T color;
return;

%% contrast hist
% output contrast histogramm
T = sort(TestScores);
Contrasts = (T(end,:)-T(end-1,:))./(T(end,:)+T(end-1,:))*100;
figure;
hist(Contrasts, 50); colormap([32 145 201]/255);
title('Contrast distribution');
xlim([0 max(Contrasts)*1.05]);
xlabel('contrast, %'); ylabel('count');
clearvars T;
