% check result with offsets one DOE

if ~exist('max_offsets', 'var'); max_offsets = 2; end
if ~exist('num_doe', 'var'); num_doe = 1; end

off_err_table = zeros(max_offsets*2+1);
off_int_table = zeros(max_offsets*2+1);

save_doe = DOES;
for iter1 = -max_offsets:max_offsets
    for iter2 = -max_offsets:max_offsets
        ndisp(['offsets = (' num2str(iter2) ', ' num2str(iter1) ');']);
        DOES(:,:,num_doe) = circshift(save_doe(:,:,num_doe), [iter1 iter2]);
        % max_batch = 20;
        check_result;
        off_err_table(iter1+max_offsets+1,iter2+max_offsets+1) = accuracy;
        off_int_table(iter1+max_offsets+1,iter2+max_offsets+1) = min_contrast;
    end
end
DOES = save_doe;
check_result;

clearvars max_offsets num_doe iter1 iter2 save_doe;
return;

%% error offsets

max_offsets = (size(off_err_table, 1)-1)/2;
figure;
grad = 100;
imagesc(-max_offsets:max_offsets, -max_offsets:max_offsets, off_err_table);
colormap([linspace(1, 32/255, grad)', linspace(1, 145/255, grad)', linspace(1, 201/255, grad)']);
for ii = 1:max_offsets*2+1
    for jj = 1:max_offsets*2+1
        color = [0 0 0];
        text(ii-max_offsets-1, jj-max_offsets-1, ...
            sprintf('%.1f', off_err_table(jj, ii)), 'fontsize', 14, ...
            'color', color, 'HorizontalAlignment', 'center');
    end
end
clearvars ii jj color max_offsets grad;

%% intensity offsets

max_offsets = (size(off_err_table, 1)-1)/2;
figure;
grad = 100;
imagesc(-max_offsets:max_offsets, -max_offsets:max_offsets, off_int_table);
colormap([linspace(1, 201/255, grad)', linspace(1, 88/255, grad)', linspace(1, 32/255, grad)']);
for ii = 1:max_offsets*2+1
    for jj = 1:max_offsets*2+1
        color = [0 0 0];
        text(ii-max_offsets-1, jj-max_offsets-1, ...
            sprintf('%.1f', off_int_table(jj, ii)), 'fontsize', 14, ...
            'color', color, 'HorizontalAlignment', 'center');
    end
end
clearvars ii jj color max_offsets grad;
