
if disp_info >= 2; ndisp('loading cat vs dog dataset'); end
load('datasets/catvsdog/CvD.mat');

if ~exist('Width_image', 'var'); Width_image = N(1,1); end
if ~exist('Height_image', 'var'); Height_image = N(1,2); end

% Labels numbers
Labels = {'cat', 'dog'};
ln = length(Labels);

% Standart size images
if disp_info >= 2; rdisp('resizing cat dataset'); end
for iter = 1:length(cat)
    scx = size(cat{iter},2)/Width_image;
    scy = size(cat{iter},1)/Height_image;
    sc = max(scx, scy);
    imag = im2gray(cat{iter});
    if sc > 1
        imag = imresize(imag,1/sc);
    end
    cat{iter} = zeros(Width_image, Height_image, 'single');
    cat{iter}(floor(end/2-size(imag,1)/2)+1:floor(end/2+size(imag,1)/2),...
              floor(end/2-size(imag,2)/2)+1:floor(end/2+size(imag,2)/2)) = imag;
end
if disp_info >= 2; rdisp('resizing dog dataset'); end
for iter = 1:length(dog)
    scx = size(dog{iter},2)/Width_image;
    scy = size(dog{iter},1)/Height_image;
    sc = max(scx, scy);
    imag = im2gray(dog{iter});
    if sc > 1
        imag = imresize(imag,1/sc);
    end
    dog{iter} = zeros(Width_image, Height_image, 'single');
    dog{iter}(floor(end/2-size(imag,1)/2)+1:floor(end/2+size(imag,1)/2),...
              floor(end/2-size(imag,2)/2)+1:floor(end/2+size(imag,2)/2)) = imag;
end

% Create test set
if disp_info >= 2; rdisp('spliting dataset'); end
Testsize = 2000;
catid = randi(length(cat),1,Testsize);
dogid = randi(length(dog),1,Testsize);

Test = [cat(catid), dog(dogid)];
TestLabel = [repmat(1, [1 Testsize]), repmat(2, [1 Testsize])];
cat(catid) = []; dog(dogid) = [];

Test = cell2mat(reshape(Test,1,1,[]));

% Create training set
Train = [cat, dog];
TrainLabel = [repmat(1, [1 length(cat)]), repmat(2, [1 length(dog)])];

Train = cell2mat(reshape(Train,1,1,[]));

% coordinates of the centers of the focus areas
if exist('coords', 'var') ~= 1
    coords = [-G_size_x 0; G_size_x 0]*2;
end

if disp_info >= 2; rdisp('creating masks'); end
MASK = single((abs(X{end} - permute(coords(:,1), [3 2 1])) < G_size_x/2).*...
              (abs(Y{end} - permute(coords(:,2), [3 2 1])) < G_size_y/2));
if disp_info >= 2; rdisp('load cat vs dog finished'); end

clearvars Testsize catid dogid cat dog imag scx scy sc iter;