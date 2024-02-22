
err_tabl = zeros(ln,'single'); % error table
int_tabl = zeros(ln,'single'); % intensity table

if ~is_max; avg_energy = 0; end
if exist('batch', 'var') ~= 1; batch = 40; end
tic;
parfor iter=1:size(Test,3)/batch
    num = TestLabel((iter-1)*batch+1:iter*batch)';
    % running through the system
    W = GetImage(Test(:,:,(iter-1)*batch+1:iter*batch));
    Scores = recognize(W,Propagations,DOES,MASK,is_max);
    Scores = Scores(1:ln,:);
    if ~is_max; avg_energy = avg_energy + sum(sum(Scores)); end

    % errors
    [~, argmax] = max(Scores);
    tmp_tabl = zeros(ln, ln, batch, 'single');
    tmp_tabl(argmax + ln*(num-1) + ln^2*(0:(batch-1))) = 1;
    err_tabl = err_tabl + sum(tmp_tabl,3);
    
    % intensity
    Scores = bsxfun(@rdivide,Scores,sum(Scores));
    tmp_tabl = zeros(ln, ln*batch, 'single');
    tmp_tabl(:, num+(0:batch-1)*ln) = Scores;
    tmp_tabl = reshape(tmp_tabl, ln, ln, []);
    int_tabl = int_tabl + sum(tmp_tabl,3);
end

accuracy = sum(diag(err_tabl))/sum(sum(err_tabl,1))*100;
int_tabl = int_tabl./repmat(sum(int_tabl, 1), [ln 1])*100;
display(['accuracy = ' num2str(accuracy) '%; time ' num2str(toc)]);
T = int_tabl;
for iter=1:ln
    T(:,iter) = sort(T(:,iter));
end
min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
display(['min contrast = ' num2str(min_contrast) '%;']);
if ~is_max
    avg_energy = avg_energy/size(Test,3);
    display(['avg energy = ' num2str(avg_energy*100) '%']);
end

clearvars argmax W iter num Scores tmp_tabl T batch;
return


%% error table
% output of a beautiful error table
grad = 100;
% figure('position', [500 500 1000 500]);
figure;
imagesc(0:9,0:9,err_tabl./repmat(sum(err_tabl,1), [ln, 1])*100);
colormap([linspace(1, 32/255, grad)', linspace(1, 145/255, grad)', linspace(1, 201/255, grad)']);
% colormap(repmat(linspace(1, 0.5, grad)', [1 3]));
for ii = 1:ln
    for jj = 1:ln
        color = [0 0 0];
        if err_tabl(jj, ii)/sum(err_tabl(:, ii)) > 0.5
            color = [1 1 1];
        end
        text(ii-1, jj-1, sprintf('%.1f', err_tabl(jj, ii)/sum(err_tabl(:, ii))*100), 'fontsize', 14, 'color', color, ...
            'HorizontalAlignment', 'center');
    end
end
clearvars ii jj grad color;
accuracy = sum(diag(err_tabl))/sum(sum(err_tabl,1))*100;
title(['accuracy = ' num2str(accuracy) '%;']);
display(['accuracy = ' num2str(accuracy) '%;']);
clearvars ii jj grad color;
return;


%% intensity table
% output of a beautiful intensity table
grad = 100;
% figure('position', [500 500 1000 500]);
figure;
imagesc(0:9,0:9,int_tabl);
colormap([linspace(1, 201/255, grad)', linspace(1, 88/255, grad)', linspace(1, 32/255, grad)']);
% colormap(repmat(linspace(1, 0, grad)', [1 3]));
for ii = 1:ln
    for jj = 1:ln
        color = [0 0 0];
        text(ii-1, jj-1, sprintf('%.1f', int_tabl(jj, ii)), 'fontsize', 14, ...
            'color', color, 'HorizontalAlignment', 'center');
    end
end
T = int_tabl;
for ii=1:ln
    T(:,ii) = sort(T(:,ii));
end
min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
title(['min contrast = ' num2str(min_contrast) '%;']);
display(['min contrast = ' num2str(min_contrast) '%;']);
clearvars ii jj grad T color;
return;
