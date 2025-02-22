function Arr = create_cells(N,type,is_gpu)
    Arr = cell(size(N,1),1);
    for it=1:length(Arr)
        switch type
            case 'zeros'
                Arr{it} = zeros(N(it,:),'single').';

            case 'ones'
                Arr{it} = ones(N(it,:),'single').';

            case 'rand'
                Arr{it} = rand(N(it,:),'single').';

            otherwise
                error('type can be zeros, ones or rand');
        end
        if nargin > 2 && is_gpu
            Arr{it} = gpuArray(Arr{it});
        end
    end
end