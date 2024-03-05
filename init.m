% setting the system parameters

if exist('lambda', 'var') ~= 1; lambda = 0.532e-6; end  % wavelength
if exist('N', 'var') ~= 1; N = 512; end % total area size
if exist('pixel', 'var') ~= 1; pixel = 4e-6; end % next pixel size
if exist('spixel', 'var') ~= 1; spixel = pixel; end % source pixel size
if exist('is_max', 'var') ~= 1; is_max = true; end  % find max or sum in MASKs
if exist('m_prop', 'var') ~= 1; m_prop = 'fft'; end  % method propagation

B = pixel*N/2; % half-size of the entire area
k = 2*pi/lambda;
% coordinates of grid nodes
x = single(linspace(-B, B, N+1)); x(end) = []; x = x + B/N;
[X, Y] = meshgrid(x, x);

if exist('z', 'var') ~= 1; z = [0 0.01 0.02]; end

for iter=1:length(z)-1
    U(:,:,iter) = matrix_propagation(X,Y,z(iter+1)-z(iter),k,m_prop);
end
GetImage = @(W)propagation(normalize_field(resizeimage(W,N,spixel,pixel)), U(:,:,1), m_prop);
Propagations = [];
for iter=2:size(U,3)
    Propagations{end+1} = @(W)propagation(W, U(:,:,iter), m_prop);
end


if exist('DOES', 'var') ~= 1;
    DOES = exp(2i*pi*(rand(N,N,length(Propagations),'single')-0.5)/10);
end


clearvars iter;