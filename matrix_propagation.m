function U = matrix_propagation( X, Y, f, k, method )
    pixel = (X(1,2)-X(1,1));
    switch method
        case 'fresnel'
            pixel = pixel/2;
            U = fresnelC(sqrt(k/pi/f)*(X - (Y - pixel))) - fresnelC(sqrt(k/pi/f)*(X - (Y + pixel))) + ...
            1i*(fresnelS(sqrt(k/pi/f)*(X - (Y - pixel))) - fresnelS(sqrt(k/pi/f)*(X - (Y + pixel))));
            U = U*sqrt(exp(1i*k*f)/2i);
        case 'fft'
            N = size(X,1);
            kx = linspace(-pi/pixel, pi/pixel, N+1); kx(end) = [];
            [Kx, Ky] = meshgrid(kx, kx);
            U = circshift(Kx.^2 + Ky.^2, [N/2 N/2]);
            U = exp(1i*f*single(sqrt(k^2 - U)));
        otherwise
            error('this method propagation not exist');
    end
end

