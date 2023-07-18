% setting the system parameters

if exist('metric', 'var') ~= 1; metric = 0.001; end % metric (in millimeters)
if exist('lambda', 'var') ~= 1; lambda = 0.532e-6/metric; end  % wavelength
k = 2*pi/lambda;

if exist('pixel', 'var') ~= 1; pixel = 18e-6/metric; end % pixel size
if exist('AN', 'var') ~= 1; AN = 28*2; end % number of pixels for digits
if exist('N', 'var') ~= 1; N = 512; end % total area size
A = AN*pixel/2; % half-size of the digit area
B = A*N/AN; % half-size of the entire area

% coordinates of grid nodes
x = linspace(-B, B, N+1); x(end) = [];
[X, Y] = meshgrid(x, x);

% U - needed for the propagation operator
kx = linspace(-pi*N/2/B, pi*N/2/B, N+1); kx(end) = [];
[Kx, Ky] = meshgrid(kx, kx);
T = Kx.^2 + Ky.^2;
U = circshift(T, [N/2 N/2]);
U = sqrt(k^2 - U);

% what numbers will we teach
is_max = true;
nums = [0 1 2 3 4 5 6 7 8 9];
ln = length(nums);
aa = A*4;
hh = aa; %aa*sqrt(3)/2;
% coordinates of the centers of the focus areas
coords = [-aa hh; 0 hh; aa hh; -1.5*aa 0; -0.5*aa 0; 0.5*aa 0; 1.5*aa 0; -aa -hh; 0 -hh; aa -hh];
G_size = A; % size of focus areas
MASK = zeros(N,N,ln);
for iter99=1:ln
    MASK(:,:,iter99) = (abs(X-coords(iter99,1)) < G_size/2).*(abs(Y-coords(iter99,2)) < G_size/2);
end

% path = 'D:/mnist/';
load('D:/mnist/Train.mat');
load('D:/mnist/Test.mat');

clearvars aa hh kx Kx Ky T iter99;
