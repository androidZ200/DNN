function cellarr = cellsum(cellarr1, cellarr2)
    if isempty(cellarr1)
        cellarr = cellarr2;
        return;
    elseif isempty(cellarr2)
        cellarr = cellarr1;
        return;
    end

    if iscell(cellarr1)
        if iscell(cellarr2)
            if length(cellarr1) ~= length(cellarr2)
                error('sizes cell array not equal');
            end
            for iter=1:length(cellarr2)
                cellarr{iter} = cellsum(cellarr1{iter}, cellarr2{iter});
            end
        else
            error('cell and not cell can not be added');
        end
    else
        if iscell(cellarr2)
            error('cell and not cell can not be added');
        else
            cellarr = cellarr1 + cellarr2;
        end
    end
end

