function [E, ind_max] = get_max_intensity(W, MASK)
    % we are looking for the maximum intensity in the area
    F = abs(W).^2 .* MASK;
    E = max(F, [], [1 2]);
    
    ind_max = (F == E);
    E = squeeze(E);
    % coordinates of the maximum intensity
end
