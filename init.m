% setting the system parameters

if exist('metric', 'var') ~= 1; metric = 0.001; end % metric (in millimeters)
if exist('lambda', 'var') ~= 1; lambda = 0.532e-6/metric; end  % wavelength
k = 2*pi/lambda;

if exist('N', 'var') ~= 1; N = 512; end % total area size
if exist('A', 'var') ~= 1; A = 36e-6*N/2/metric; end % half-size of the digit area

% coordinates of grid nodes
x = linspace(-A, A, N+1); x(end) = [];
[X, Y] = meshgrid(x, x);

% U - needed for the propagation operator
kx = linspace(-pi*N/2/A, pi*N/2/A, N+1); kx(end) = [];
[Kx, Ky] = meshgrid(kx, kx);
T = Kx.^2 + Ky.^2;
U = zeros(N);
U(1:N/2,1:N/2) = T(N/2+1:N,N/2+1:N);
U(N/2+1:N,1:N/2) = T(1:N/2,N/2+1:N);
U(1:N/2,N/2+1:N) = T(N/2+1:N,1:N/2);
U(N/2+1:N,N/2+1:N) = T(1:N/2,1:N/2);
U = sqrt(k^2 - U);

clearvars x kx Kx Ky T;
