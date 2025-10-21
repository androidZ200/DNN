function U = matrix_propagation_asm( pixel, N, f, k )
    kx = linspace_l(-pi/pixel, pi/pixel, N);
    [Kx, Ky] = meshgrid(kx, kx);
    U = circshift(Kx.^2 + Ky.^2, [N/2 N/2]);
    U = exp(1i*f.*single(sqrt(k.^2 - U)));
end