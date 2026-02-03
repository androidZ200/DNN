if is_max
    error('This check result cannot be applied to the maximum intensity');
end


TestLabel = reshape(TestLabel, [], 1);

ttcr2 = tic();
if disp_info >= 1; ndisp('check result 2 has started ...'); end

Pixel_Image = zeros([size(Test,[1 2]), size(Test,1)*size(Test,2)], 'single');
Pixel_Image(1:(size(Test,1)*size(Test,2)+1):end) = 1;
if is_gpu; Pixel_Image = gpuArray(Pixel_Image); end

W = GetImage(Pixel_Image);
for iter4=1:length(DOES)
    W = FPropagations{iter4}(DOES{iter4}.*W);
end
%%
clear MASK_mat;
W = reshape(W, [], size(Pixel_Image,3));
for iter3=1:size(MASK,3)
    ind = find(MASK(:,:,iter3));
    WT = W(ind,:);
    MASK_mat(:,:,1,iter3) = squeeze(sum(WT.*conj(permute(WT, [1 3 2]))));
end
MASK_mat = real(MASK_mat + permute(MASK_mat, [2 1 3 4]))/2;
%%
TestScores = pagemtimes(reshape(Test, 1,[],size(Test,3)),pagemtimes(MASK_mat,reshape(Test, [],1,size(Test,3))));
TestScores = permute(TestScores, [4 3 2 1]);
if disp_info >= 1; rdisp(['check result takes time: ' num2str(toc(ttcr2)) 's']); end

%%
% error table
[~, argmax] = max(TestScores);
err_tabl = zeros(size(MASK,3), ln, size(Test,3), 'single');
err_tabl(argmax + size(MASK,3)*(reshape(TestLabel,1,[])-1) + size(MASK,3)*ln*(0:(size(Test,3)-1))) = 1;
err_tabl = sum(err_tabl,3);

% intensity table
onehot = reshape(TestLabel,1,[]) == (1:ln)';
int_tabl = (TestScores./sum(TestScores)) * onehot';
%%
% accuracy info
accuracy = sum(diag(err_tabl))/sum(sum(err_tabl))*100;
int_tabl = int_tabl./sum(int_tabl)*100;
if disp_info >= 1; ndisp(['accuracy = ' num2str(accuracy) '%;']); end
% min contrast info
T = sort(int_tabl);
min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
if disp_info >= 1; ndisp(['min contrast = ' num2str(min_contrast) '%;']); end

clearvars W iter3 iter4 Pixel_Image ind WT MASK_mat argmax onehot T ttcr2;
