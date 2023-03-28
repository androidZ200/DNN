
if exist('metric', 'var') ~= 1; metric = 0.001; end % m -> mm
if exist('lambda', 'var') ~= 1; lambda = 0.532e-6/metric; end  % mm
k = 2*pi/lambda;

if exist('AN', 'var') ~= 1; AN = 28*2; end
if exist('N', 'var') ~= 1; N = 512; end
if exist('A', 'var') ~= 1; A = 36e-6*28/2/metric; end % half size figure
B = A*N/AN; % half full size area

x = linspace(-B, B, N+1); x(end) = [];
[X, Y] = meshgrid(x, x);

kx = linspace(-pi*N/2/B, pi*N/2/B, N+1); kx(end) = [];
[Kx, Ky] = meshgrid(kx, kx);
T = Kx.^2 + Ky.^2;
U = zeros(N);
U(1:N/2,1:N/2) = T(N/2+1:N,N/2+1:N);
U(N/2+1:N,1:N/2) = T(1:N/2,N/2+1:N);
U(1:N/2,N/2+1:N) = T(N/2+1:N,1:N/2);
U(N/2+1:N,N/2+1:N) = T(1:N/2,1:N/2);
U = sqrt(k^2 - U);

nums = [0 1 2 3 4 5 6 7 8 9];
ln = length(nums);
aa = A*4;
hh = aa; %aa*sqrt(3)/2;
coords = [-aa hh; 0 hh; aa hh; -1.5*aa 0; -0.5*aa 0; 0.5*aa 0; 1.5*aa 0; -aa -hh; 0 -hh; aa -hh];
G_size = A;
MASK = zeros(N,N,ln);
for iter=1:ln
    MASK(:,:,iter) = (abs(X-coords(iter,1)) < G_size/2).*(abs(Y-coords(iter,2)) < G_size/2);
end

% path = 'D:/mnist/';
load('D:/mnist/Train.mat');
load('D:/mnist/Test.mat');

clearvars aa hh kx Kx Ky T iter;
