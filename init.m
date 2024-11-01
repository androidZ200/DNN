% setting the system parameters

if ~exist('lambda', 'var'); lambda = 0.532e-6; end  % wavelength
if ~exist('N', 'var'); N = 512; end % total area size
if ~exist('pixel', 'var'); pixel = 4e-6; end % next pixel size
if ~exist('spixel', 'var'); spixel = pixel; end % source pixel size
if ~exist('is_max', 'var'); is_max = true; end  % find max or sum in MASKs
if ~exist('is_gpu', 'var'); is_gpu = true; end  % calculation on gpu

B = pixel*N/2; % half-size of the entire area
k = 2*pi/lambda;
% coordinates of grid nodes
x = single(linspace(-B, B, N+1)); x(end) = []; x = x + B/N;
[X, Y] = meshgrid(x, x);

GPU_CPU;

if exist('z', 'var')
    if ~exist('m_prop', 'var'); m_prop = 'ASM'; end  % method propagation

    % matrixes propagations
    U = matrix_propagation(X,Y,permute(z(2:end)-z(1:end-1),[1 3 2]),k,m_prop);
    % functions propagation
    GetImage = @(W)propagation(normalize_field(resizeimage(W,N,spixel,pixel)), U(:,:,1), m_prop);
    Propagations = [];
    for iter99=2:size(U,3)
        Propagations{end+1} = @(W)propagation(W, U(:,:,iter99), m_prop);
    end
end

clearvars iter99;