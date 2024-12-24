
TestScores = zeros(size(MASK,3), size(Test,3), 'single'); % scores

if ~exist('max_batch', 'var'); max_batch = 40; end
W = create_cells(N,'zeros',is_gpu);

ndisp('check result 0%');
for iter3=1:size(Test,3)/max_batch
    % running through the system
    W{1} = GetImage(Test(:,:,(iter3-1)*max_batch+1:iter3*max_batch));
    for iter4=1:length(DOES)
        W{iter4+1} = FPropagations{iter4}(W{iter4}.*DOES{iter4});
    end
    TestScores(:,(iter3-1)*max_batch+1:iter3*max_batch) = get_scores(permute(W{end},[1 2 4 3]), MASK, is_max);
    rdisp(['check result ' num2str(iter3*max_batch/size(Test,3)*100,'%.2f') '%']);
end
%%
% error table
[~, argmax] = max(TestScores);
err_tabl = zeros(size(MASK,3), ln, size(Test,3), 'single');
err_tabl(argmax + size(MASK,3)*(TestLabel'-1) + (size(MASK,3))*ln*(0:(size(Test,3)-1))) = 1;
err_tabl = sum(err_tabl,3);

% intensity table
int_tabl = zeros(size(MASK,3), ln*size(Test,3), 'single');
int_tabl(:, TestLabel'+(0:(size(Test,3)-1))*ln) = TestScores./sum(TestScores);
int_tabl = reshape(int_tabl, size(MASK,3), ln, []);
int_tabl = sum(int_tabl,3);
%%
% accuracy info
accuracy = sum(diag(err_tabl))/sum(sum(err_tabl))*100;
int_tabl = int_tabl./sum(int_tabl)*100;
rdisp(['accuracy = ' num2str(accuracy) '%;']);
% min contrast info
T = sort(int_tabl);
min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
ndisp(['min contrast = ' num2str(min_contrast) '%;']);
% effectiveness info
if ~is_max
    avg_energy = sum(sum(TestScores(1:ln,:)))/size(Test,3);
    ndisp(['avg energy = ' num2str(avg_energy*100) '%']);
end

clearvars argmax W iter3 iter4 num T max_batch;
return


%% error table
% output of a beautiful error table
grad = 100;
figure;
imagesc(0:(ln-1),0:(size(MASK,3)-1), bsxfun(@rdivide, err_tabl, sum(err_tabl)));
colormap([linspace(1, 32/255, grad)', linspace(1, 145/255, grad)', linspace(1, 201/255, grad)']);
for ii = 1:ln
    for jj = 1:size(MASK,3)
        color = [0 0 0];
        if err_tabl(jj, ii)/sum(err_tabl(:, ii)) > 0.5
            color = [1 1 1];
        end
        text(ii-1, jj-1, sprintf('%.1f', err_tabl(jj, ii)/sum(err_tabl(:, ii))*100), 'fontsize', 14, 'color', color, ...
            'HorizontalAlignment', 'center');
    end
end
accuracy = sum(diag(err_tabl))/sum(sum(err_tabl,1))*100;
title(['accuracy = ' num2str(accuracy) '%;']);
ndisp(['accuracy = ' num2str(accuracy) '%;']);
clearvars ii jj grad color;
return;

%% intensity table
% output of a beautiful intensity table
grad = 100;
figure;
imagesc(0:(ln-1),0:(size(MASK,3)-1), int_tabl);
colormap([linspace(1, 201/255, grad)', linspace(1, 88/255, grad)', linspace(1, 32/255, grad)']);
for ii = 1:ln
    for jj = 1:size(MASK,3)
        color = [0 0 0];
        text(ii-1, jj-1, sprintf('%.1f', int_tabl(jj, ii)), 'fontsize', 14, ...
            'color', color, 'HorizontalAlignment', 'center');
    end
end
T = sort(int_tabl);
min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
title(['min contrast = ' num2str(min_contrast) '%;']);
ndisp(['min contrast = ' num2str(min_contrast) '%;']);
clearvars ii jj grad T color;
return;
