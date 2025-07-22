
if disp_info >= 2; ndisp('loading fashion mnist dataset'); end
load('datasets/fashion/FashionMNIST.mat');

ln = length(Labels);

% rename digits label
TrainLabel = single(TrainLabel + 1);
TestLabel = single(TestLabel + 1);

% coordinates of the centers of the focus areas
if exist('coords', 'var') ~= 1
    aa = (Full_width  - G_size_x)/3;
    hh = (Full_height - G_size_y)/2;

    coords = [-1.5*aa -hh; -0.5*aa -hh; 0.5*aa -hh; 1.5*aa -hh; ...
              -1.5*aa   0;                          1.5*aa   0; ...
              -1.5*aa  hh; -0.5*aa  hh; 0.5*aa  hh; 1.5*aa  hh];
end

if disp_info >= 2; rdisp('creating masks'); end
MASK = single((abs(X{end} - permute(coords(:,1), [3 2 1])) < G_size_x/2).*...
              (abs(Y{end} - permute(coords(:,2), [3 2 1])) < G_size_y/2));
if disp_info >= 2; rdisp('load fashion mnist finished'); end

clearvars aa hh;