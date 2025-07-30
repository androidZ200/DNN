function X = linspace_m(left, right, N)
    X = linspace(left, right, N+1); X(end) = []; X = X + (right-left)/N/2;
end