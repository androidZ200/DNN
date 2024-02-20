% setting the system parameters

if exist('metric', 'var') ~= 1; metric = 1; end % metric (in meters)
if exist('lambda', 'var') ~= 1; lambda = 0.532e-6/metric; end  % wavelength
k = 2*pi/lambda;

f = 0.25/metric;
if exist('N', 'var') ~= 1; N = 2^10; end % total area size
if exist('pixel', 'var') ~= 1; pixel = lambda*f/(8e-6/metric)/N; end % source pixel size
if exist('spixel', 'var') ~= 1; spixel = 36e-6/metric; end % next pixel size
B = pixel*N/2; % half-size of the entire area

% coordinates of grid nodes
x = single(linspace(-B, B, N+1)); x(end) = [];
[X, Y] = meshgrid(x, x);

% U - needed for the propagation operator
kx = linspace(-pi*N/2/B, pi*N/2/B, N+1); kx(end) = [];
[Kx, Ky] = meshgrid(kx, kx);
U = circshift(Kx.^2 + Ky.^2, [N/2 N/2]);
U = single(sqrt(k^2 - U));

if exist('is_max', 'var') ~= 1; is_max = true; end  % find max or sum in MASKs

clearvars kx Kx Ky;