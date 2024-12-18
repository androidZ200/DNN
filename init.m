% setting the system parameters

if ~exist('lambda', 'var'); lambda = 0.532e-6; end  % wavelength
if ~exist('is_max', 'var'); is_max = true; end  % find max or sum in MASKs
if ~exist('is_gpu', 'var'); is_gpu = true; end  % calculation on gpu
k = 2*pi/lambda;
GetImage = @(W)W;

if exist('f', 'var')
    if size(pixel,1) == 1; pixel = repmat(pixel, [length(f)+1, 1]); end
    if size(pixel,2) == 1; pixel = repmat(pixel, [1, 2]); end
    if size(N,1) == 1; N = repmat(N, [length(f)+1, 1]); end
    if size(N,2) == 1; N = repmat(N, [1, 2]); end

    switch m_prop
        
        case 'ASM'
            X{1} = single(linspace(-pixel(1,1)*N(1,1)/2, pixel(1,1)*N(1,1)/2, N(1,1)+1)); X{1}(end) = []; X{1} = X{1} + pixel(1,1)/2;
            Y{1} = X{1}';

            U = matrix_propagation_asm(pixel(1,1),N(1,1),permute(f,[1 3 2]),k);
            U = squeeze(num2cell(U, [1 2]));
            FPropagations = [];
            for iter99=1:length(U)
                FPropagations{end+1} = @(W)propagation_asm(W, U{iter99});
            end
            BPropagations = FPropagations;

        case 'sinc'
            for iter99=1:length(f)+1
                X{iter99} = single(linspace(-pixel(iter99,1)*N(iter99,1)/2, pixel(iter99,1)*N(iter99,1)/2, N(iter99,1)+1)); 
                X{iter99}(end) = []; X{iter99} = X{iter99} + pixel(iter99,1)/2;
                Y{iter99} = single(linspace(-pixel(iter99,2)*N(iter99,2)/2, pixel(iter99,2)*N(iter99,2)/2, N(iter99,2)+1)'); 
                Y{iter99}(end) = []; Y{iter99} = Y{iter99} + pixel(iter99,2)/2;
            end
            
            FPropagations = [];
            for iter99=1:length(f)
                U{iter99,1} = matrix_propagation_sinc(Y{iter99},Y{iter99+1},f(iter99),k);
                if pixel(iter99,1) ~= pixel(iter99,2) || pixel(iter99+1,1) ~= pixel(iter99+1,2) || ...
                        N(iter99,1) ~= N(iter99,2) || N(iter99+1,1) ~= N(iter99+1,2)
                    U{iter99,2} = matrix_propagation_sinc(X{iter99},X{iter99+1},f(iter99),k).';
                end
                FPropagations{end+1} = @(W)propagation_sinc(W, U{iter99,1}, U{iter99,2});
            end
            
            BPropagations = [];
            for iter99=1:length(f)
                BU{iter99,1} = matrix_propagation_sinc(Y{iter99+1},Y{iter99},f(iter99),k);
                if pixel(iter99,1) ~= pixel(iter99,2) || pixel(iter99+1,1) ~= pixel(iter99+1,2) || ...
                        N(iter99,1) ~= N(iter99,2) || N(iter99+1,1) ~= N(iter99+1,2)
                    BU{iter99,2} = matrix_propagation_sinc(X{iter99+1},X{iter99},f(iter99),k).';
                end
                BPropagations{end+1} = @(W)propagation_sinc(W, BU{iter99,1}, BU{iter99,2});
            end

        otherwise
            error('m_prop can be ether ASM or sinc');
    end


    if ~exist('DOES_MASK', 'var')    
         for iter99=1:length(FPropagations); DOES_MASK{iter99} = ones(N(iter99,:),'single')'; end
    end
    if ~exist('DOES', 'var')
        for iter99=1:length(FPropagations); DOES{iter99} = DOES_MASK{iter99}; end
    end
end

clearvars iter99 m_prop;