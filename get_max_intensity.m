function [E, ind_max] = get_max_intensity(W, MASK)
    % we are looking for the maximum intensity in the area
    [E, index] = max(abs(W(:)).^2.*MASK(:));
    E = gather(E);
    % coordinates of the maximum intensity
    ind_max = zeros(size(W));
    ind_max(index) = 1;
    ind_max = gpuArray(ind_max);
end
