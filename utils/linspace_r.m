function X = linspace_r(left, right, N)
    X = linspace(left, right, N+1); X(1) = [];
end