function [ U ] = matrix_propagation( X, Y, f, k )
    pixel = X(1,2)-X(1,1);
    U = fresnelC(sqrt(k/pi/f)*(X - Y + pixel)) - fresnelC(sqrt(k/pi/f)*(X - Y)) + ...
    1i*(fresnelS(sqrt(k/pi/f)*(X - Y + pixel)) - fresnelS(sqrt(k/pi/f)*(X - Y)));
    U = U*sqrt(exp(1i*k*f)/2i);
end

