% setting the system parameters
addpath(genpath(pwd));

if ~exist('lambda', 'var'); lambda = 0.532e-6; end  % wavelength
if ~exist('is_max', 'var'); is_max = true; end  % find max or sum in MASKs
if ~exist('is_gpu', 'var'); is_gpu = true; end  % calculation on gpu
if ~exist('disp_info', 'var'); disp_info = 1; end  % display information (0 - none, 1 - progress, 2 - all)
k = 2*pi/lambda;
GetImage = @(W)W;

if disp_info >= 2; ndisp('start init'); end
if exist('f', 'var')
    if size(pixel,1) == 1; pixel = repmat(pixel, [length(f)+1, 1]); end
    if size(pixel,2) == 1; pixel = repmat(pixel, [1, 2]); end
    if size(N,1) == 1; N = repmat(N, [length(f)+1, 1]); end
    if size(N,2) == 1; N = repmat(N, [1, 2]); end

    if disp_info >= 2; rdisp('creating grids'); end
    for iter99=1:length(f)+1
        X{iter99} = single(linspace_m(-pixel(iter99,1)*N(iter99,1)/2, pixel(iter99,1)*N(iter99,1)/2, N(iter99,1))); 
        if is_gpu; X{iter99} = gpuArray(X{iter99}); end
        Y{iter99} = single(linspace_m(-pixel(iter99,2)*N(iter99,2)/2, pixel(iter99,2)*N(iter99,2)/2, N(iter99,2))'); 
        if is_gpu; Y{iter99} = gpuArray(Y{iter99}); end
    end

    if exist('m_prop', 'var')
        switch m_prop
            
            case 'ASM'
                if disp_info >= 2; rdisp('creating ASM kernels'); end
                U = matrix_propagation_asm(pixel(1,1),N(1,1),permute(f,[1 3 2]),k);
                if is_gpu; U = gpuArray(U); end
                U = squeeze(num2cell(U, [1 2]));
                FPropagations = [];
                for iter99=1:length(U)
                    FPropagations{end+1} = @(W)propagation_asm(W, U{iter99});
                end
                BPropagations = FPropagations;
    
            case 'sinc'
                FPropagations = [];
                for iter99=1:length(f)
                    if disp_info >= 2; rdisp(['creating ' num2str(iter99) 'th forward propagation function']); end
                    U{iter99,1} = matrix_propagation_sinc(Y{iter99},Y{iter99+1},f(iter99),k);
                    if pixel(iter99,1) ~= pixel(iter99,2) || pixel(iter99+1,1) ~= pixel(iter99+1,2) || ...
                            N(iter99,1) ~= N(iter99,2) || N(iter99+1,1) ~= N(iter99+1,2)
                        U{iter99,2} = matrix_propagation_sinc(X{iter99},X{iter99+1},f(iter99),k).';
                        FPropagations{end+1} = @(W)propagation_sinc(W, U{iter99,1}, U{iter99,2});
                    else
                        FPropagations{end+1} = @(W)propagation_sinc(W, U{iter99,1});
                    end
                end
                
                BPropagations = [];
                for iter99=1:length(f)
                    if disp_info >= 2; rdisp(['creating ' num2str(iter99) 'th back propagation function']); end
                    BU{iter99,1} = matrix_propagation_sinc(Y{iter99+1},Y{iter99},f(iter99),k);
                    if pixel(iter99,1) ~= pixel(iter99,2) || pixel(iter99+1,1) ~= pixel(iter99+1,2) || ...
                            N(iter99,1) ~= N(iter99,2) || N(iter99+1,1) ~= N(iter99+1,2)
                        BU{iter99,2} = matrix_propagation_sinc(X{iter99+1},X{iter99},f(iter99),k).';
                        BPropagations{end+1} = @(W)propagation_sinc(W, BU{iter99,1}, BU{iter99,2});
                    else
                        BPropagations{end+1} = @(W)propagation_sinc(W, BU{iter99,1});
                    end
                end
    
            otherwise
                error('m_prop can be ether ASM or sinc');
        end
    end

    if disp_info >= 2; rdisp('creating DOES'); end
    if ~exist('DOES_MASK', 'var')    
        GRAD_MASK = squeeze(num2cell(ones(1,1,size(N,1)-1,is_gpu)));
    end
    if ~exist('DOES', 'var')
        DOES = create_cells(N(1:end-1,:),'ones',is_gpu);
    end
end
if disp_info >= 2; rdisp('init finished'); end

clearvars iter99 m_prop;