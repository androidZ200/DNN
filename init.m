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
x = linspace(-B, B, N+1); x(end) = []; x = x + B/N;
[X, Y] = meshgrid(x, x);

% U - needed for the propagation operator
if exist('z', 'var') ==1
    U = zeros(N,N,length(z)-1);
    for iter=1:size(U,3)
        U(:,:,iter) = matrix_propagation(X, Y, z(iter+1)-z(iter), k);
    end
end

if exist('is_max', 'var') ~= 1; is_max = true; end  % find max or sum in MASKs

clearvars iter;