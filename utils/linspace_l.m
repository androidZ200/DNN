function X = linspace_l(left, right, N)
    X = linspace(left, right, N+1); X(end) = [];
end