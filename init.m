% setting the system parameters

if exist('lambda', 'var') ~= 1; lambda = 0.532e-6; end  % wavelength
if exist('N', 'var') ~= 1; N = 512; end % total area size
if exist('pixel', 'var') ~= 1; pixel = 4e-6; end % next pixel size
if exist('spixel', 'var') ~= 1; spixel = pixel; end % source pixel size
B = pixel*N/2; % half-size of the entire area
k = 2*pi/lambda;

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