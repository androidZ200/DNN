function U = matrix_propagation( X, Y, f, k )
    d = (X(1,2)-X(1,1))/2;
    U = fresnelC(sqrt(k/pi/f)*(X - (Y - d))) - fresnelC(sqrt(k/pi/f)*(X - (Y + d))) + ...
    1i*(fresnelS(sqrt(k/pi/f)*(X - (Y - d))) - fresnelS(sqrt(k/pi/f)*(X - (Y + d))));
    U = U*sqrt(exp(1i*k*f)/2i);
end

