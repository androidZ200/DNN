function Arr = create_cells(N,batch,type,is_gpu)
    Arr = cell(size(N,1),1);
    for it=1:length(Arr)
        switch type
            case 'zeros'
                Arr{it} = permute(zeros([N(it,:), batch],'single'), [2 1 3]);

            case 'ones'
                Arr{it} = permute(ones([N(it,:), batch],'single'), [2 1 3]);

            case 'rand'
                Arr{it} = permute(rand([N(it,:), batch],'single'), [2 1 3]);

            otherwise
                error('type can be zeros, ones or rand');
        end
        if nargin > 3 && is_gpu
            Arr{it} = gpuArray(Arr{it});
        end
    end
end