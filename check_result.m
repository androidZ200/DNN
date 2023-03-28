
tabl1 = zeros(ln);
tabl2 = zeros(ln);

tic;
parfor iter=1:sum(TestData);
    num = 1;
    it = iter;
    while it > TestData(num)
        it = it - TestData(num);
        num = num+1;
    end
    
    W = resizeimage(Test(:,:,it,num),N,AN);
%     W = W(end:-1:1, :);
    [tmp,W] = recognize(W,z,DOES,k,MASK,U)

    [~, argmax] = max(tmp);
    ttt = zeros(ln);
    ttt(argmax, num) = 1;
    tabl1 = tabl1 + ttt;
%     for nt = 1:ln
%         tmp(nt) = get_energy(W(:,:,end), MASK(:,:,nt));
%     end
    ttt(:,num) = tmp;
    tabl2 = tabl2 + ttt;
end

accuracy = sum(diag(tabl1))/sum(TestData)*100;
display(['accuracy = ' num2str(accuracy) '%; time ' num2str(toc)]);
% display(round(tabl1));

clearvars argmax W iter num tmp nt ttt it;
return

%% accuracy table

grad = 100;
figure('position', [500 500 1000 500]);
imagesc(nums, nums, tabl1./repmat(TestData, [ln, 1])*100, [0 100]);
colormap([linspace(1, 32/255, grad)', linspace(1, 145/255, grad)', linspace(1, 201/255, grad)']);
% colormap(repmat(linspace(1, 0.5, grad)', [1 3]));
for ii = 1:ln
    for jj = 1:ln
        text(ii-0.25-1, jj-1, sprintf('%.1f%%', tabl1(jj, ii)/TestData(ii)*100), 'fontsize', 14, 'color', [0 0 0]);
    end
end
clearvars ii jj grad;
accuracy = sum(diag(tabl1))/sum(TestData)*100;
title(['accuracy = ' num2str(accuracy) '%;']);
return;

%% intensity tabel

grad = 100;
figure('position', [500 500 1000 500]);
imagesc(nums, nums, tabl2./repmat(sum(tabl2), [ln, 1])*100, [0 100]);
colormap([linspace(1, 201/255, grad)', linspace(1, 88/255, grad)', linspace(1, 32/255, grad)']);
% colormap(repmat(linspace(1, 0, grad)', [1 3]));
for ii = 1:ln
    for jj = 1:ln
        text(ii-0.25-1, jj-1, sprintf('%.1f%%', tabl2(jj, ii)/sum(tabl2(:, ii))*100), 'fontsize', 14, 'color', [0 0 0]);
    end
end
T = tabl2;
for ii=1:ln
    T(:,ii) = sort(T(:,ii));
end
title(['min contrast = ' num2str(min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100)) '%;']);
clearvars ii jj grad T;
return;