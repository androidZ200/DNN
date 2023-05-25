function [E, ind_max] = get_max_intensity(X, Y, W, x, y, size)
	MASK = (abs(X - x) < size/2).*(abs(Y - y) < size/2);
    ind_max = [0 0];
    
    [T, tt] = max(abs(W.*MASK).^2);
	[E, ind_max(2)] = max(T);
    ind_max(1) = tt(ind_max(2));
end
