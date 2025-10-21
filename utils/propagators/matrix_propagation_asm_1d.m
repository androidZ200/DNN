function U = matrix_propagation_asm_1d( pixel, N, f, k )
    kx = linspace_l(-pi/pixel, pi/pixel, N);
    U = circshift(kx.^2, N/2);
    U = exp(1i*f.*single(sqrt(k.^2 - U)));
end