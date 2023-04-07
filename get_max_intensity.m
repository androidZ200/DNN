function [E, ind_max] = get_max_intensity(W, MASK)
    % we are looking for the maximum intensity in the area
    [E, index] = max(abs(W(:).*MASK(:)).^2);
    % coordinates of the maximum intensity
    ind_max = zeros(size(W,1), size(W,2));
    ind_max(index) = 1;
end
