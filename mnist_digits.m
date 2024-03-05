
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

% size of focus area
if exist('G_size_x', 'var') ~= 1; G_size_x = 0.2e-3; end
if exist('G_size_y', 'var') ~= 1; G_size_y = 0.2e-3; end

% size all area
if exist('aa', 'var') ~= 1; aa = 1.5e-3; end
if exist('hh', 'var') ~= 1; hh = 1.2e-3; end
aa = (aa - G_size_x)/3;
hh = (hh - G_size_y)/2;

% coordinates of the centers of the focus areas
if exist('coords', 'var') ~= 1
    coords = [-1.5*aa -hh; -0.5*aa -hh; 0.5*aa -hh; 1.5*aa -hh; ...
              -1.5*aa   0;                          1.5*aa   0; ...
              -1.5*aa  hh; -0.5*aa  hh; 0.5*aa  hh; 1.5*aa  hh];
end

MASK = (abs(X - permute(coords(:,1), [3 2 1])) < G_size_x/2).*...
       (abs(Y - permute(coords(:,2), [3 2 1])) < G_size_y/2);

clearvars ind aa hh iter99 nums tmp_label;