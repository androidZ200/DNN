
load('datasets/catvsdog/CvD.mat');

% Labels numbers
Labels = {'cat', 'dog'};
ln = length(Labels);

% Create test set
Testsize = 2000;
catid = randi(length(cat),1,Testsize);
dogid = randi(length(dog),1,Testsize);

Test = [cat(catid), dog(dogid)];
TestLabel = [repmat(1, [1 Testsize]), repmat(2, [1 Testsize])];
cat(catid) = []; dog(dogid) = [];

% Create training set
Train = [cat, dog];
TrainLabel = [repmat(1, [1 length(cat)]), repmat(2, [1 length(dog)])];

% coordinates of the centers of the focus areas
if exist('coords', 'var') ~= 1
    coords = [-G_size_x 0; G_size_x 0];
end

MASK = single((abs(X{end} - permute(coords(:,1), [3 2 1])) < G_size_x/2).*...
              (abs(Y{end} - permute(coords(:,2), [3 2 1])) < G_size_y/2));

clearvars Testsize catid dogid cat dog;