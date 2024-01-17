function [E, ind_max] = get_max_intensity(W, MASK)
    % we are looking for the maximum intensity in the area
    F = bsxfun(@times,abs(W).^2,MASK);
    E = max(max(F));
    
    ind_max = bsxfun(@eq, F, E);
    E = squeeze(E);
    % coordinates of the maximum intensity
end
