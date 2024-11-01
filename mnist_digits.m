
load('datasets/mnist/Train.mat');
load('datasets/mnist/Test.mat');

% what numbers will we teach
nums = [0 1 2 3 4 5 6 7 8 9];
ln = length(nums);

% delete unused digits
ind = find(ismember(TrainLabel, nums));
Train = single(Train(:,:,ind));
TrainLabel = TrainLabel(ind);
ind = find(ismember(TestLabel, nums));
Test = single(Test(:,:,ind));
TestLabel = TestLabel(ind);

% rename digits label
tmp_label = zeros(length(TestLabel),1, 'single');
for iter99 = 1:ln
    tmp_label = tmp_label + (TestLabel == nums(iter99))*iter99;
end
TestLabel = tmp_label;
tmp_label = zeros(length(TrainLabel),1, 'single');
for iter99 = 1:ln
    tmp_label = tmp_label + (TrainLabel == nums(iter99))*iter99;
end
TrainLabel = tmp_label;

% coordinates of the centers of the focus areas
if exist('coords', 'var') ~= 1
    aa = (Full_width  - G_size_x)/3;
    hh = (Full_height - G_size_y)/2;

    coords = [-1.5*aa -hh; -0.5*aa -hh; 0.5*aa -hh; 1.5*aa -hh; ...
              -1.5*aa   0;                          1.5*aa   0; ...
              -1.5*aa  hh; -0.5*aa  hh; 0.5*aa  hh; 1.5*aa  hh];
end

MASK = single((abs(X - permute(coords(:,1), [3 2 1])) < G_size_x/2).*...
              (abs(Y - permute(coords(:,2), [3 2 1])) < G_size_y/2));

clearvars ind aa hh iter99 nums tmp_label;