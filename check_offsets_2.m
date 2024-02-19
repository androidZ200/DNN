% check avg accuracy and min_contrast for offsets several DOE

if exist('max_offset', 'var') ~= 1; max_offset = 2; end
if exist('max_check', 'var') ~= 1; max_check = 8; end

% all posible offsets
offsets = zeros((max_offset*2+1)^(2*size(DOES,3)),2*size(DOES,3));

ind = (-max_offset:max_offset)';
for iter1 = 1:size(offsets,2)
    offsets(:,iter1) = repmat(...
        kron(ind, ones(size(offsets,1)/(length(ind)^iter1),1)), ...
        [length(ind)^(iter1-1) 1]);
end
offsets = reshape(offsets, [size(offsets,1), size(DOES,3), 2]);

% max offsets for each DOE
mm = max(abs(offsets),[],3);

% 1-size_DOE - max offsets, end-1 - accuracy, end - min_contrast
tabl2 = zeros((max_offset+1)^size(DOES,3), size(DOES,3)+2);
ind = (0:max_offset)';
for iter1 = 1:size(tabl2,2)-2
    tabl2(:,iter1) = repmat(...
        kron(ind, ones(size(tabl2,1)/(length(ind)^iter1),1)), ...
        [length(ind)^(iter1-1) 1]);
end

% data accuracy for each offsets in rand set
tabl1 = [];

save_doe = DOES;
for jj = size(tabl2,1):-1:1
    ind = find(ismember(mm, tabl2(jj, 1:end-2), 'rows'));
    ind = ind(randperm(length(ind)));
    ind = ind(1:min(max_check,length(ind)));
    for iter1=1:length(ind)
        for iter2 = 1:size(DOES,3)
            DOES(:,:,iter2) = circshift(save_doe(:,:,iter2), ...
                permute(offsets(ind(iter1),iter2,:), [1 3 2]));
            display(['DOE ' num2str(iter2) '; offset = (' ...
                num2str(offsets(ind(iter1),iter2,1)) '; ' ...
                num2str(offsets(ind(iter1),iter2,2)) ')']);
        end
        check_result;
        tabl1(end+1, 1:2:size(DOES,3)*2) = offsets(ind(iter1),:,1);
        tabl1(end  , 2:2:size(DOES,3)*2) = offsets(ind(iter1),:,2);
        tabl1(end, size(DOES,3)*2+1) = accuracy;
        tabl1(end, size(DOES,3)*2+2) = min_contrast;
        tabl2(jj, end-1) = tabl2(jj, end-1) + accuracy;
        tabl2(jj, end)   = tabl2(jj, end)   + min_contrast;
    end
    tabl2(jj, end-1:end) = tabl2(jj, end-1:end) / length(ind);
end
DOES = save_doe;

clearvars max_offset max_check offsets ind iter1 iter2 mm save_doe jj;