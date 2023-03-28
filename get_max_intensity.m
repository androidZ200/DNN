function [E, ind_max] = get_max_intensity(W, MASK)  
    [E, index] = max(abs(W(:).*MASK(:)).^2);
    ind_max(index) = 1;
end
