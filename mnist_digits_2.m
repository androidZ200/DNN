
% path = 'D:/mnist/';
load('D:/mnist/Train.mat');
load('D:/mnist/Test.mat');

% what numbers will we teach
nums = [1 2];
ln = length(nums);

% delete unused digits
ind = find(ismember(TrainLabel, nums));
Train = single(Train(:,:,ind));
TrainLabel = TrainLabel(ind);
ind = find(ismember(TestLabel, nums));
Test = single(Test(:,:,ind));
TestLabel = TestLabel(ind);

% rename digits label
tmp_label = single(zeros(length(TestLabel),1));
for iter99 = 1:ln
    tmp_label = tmp_label + (TestLabel == nums(iter99))*iter99;
end
TestLabel = tmp_label;
tmp_label = single(zeros(length(TrainLabel),1));
for iter99 = 1:ln
    tmp_label = tmp_label + (TrainLabel == nums(iter99))*iter99;
end
TrainLabel = tmp_label;

G_size_x = 1.0e-3/metric; % size of focus areas X
G_size_y = 3.0e-3/metric; % size of focus areas X

% coordinates of the centers of the focus areas
coords = [-1e-3 0; 1e-3 0]/metric;
MASK = single(zeros(N,N,ln));
for iter99=1:ln
    MASK(:,:,iter99) = (abs(X-coords(iter99,1)) < G_size_x/2).*(abs(Y-coords(iter99,2)) < G_size_y/2);
end

clearvars ind aa hh iter99 nums tmp_label;