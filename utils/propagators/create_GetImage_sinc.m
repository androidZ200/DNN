function GetImage = create_GetImage_sinc(input_pixel, input_N, X, Y, k, f)
    iX = linspace_m(-input_pixel(1)*input_N(1), input_pixel(1)*input_N(1), input_N(1)); 
    if length(input_pixel) > 1 || length(input_N) > 1
        iY = linspace_m(-input_pixel(end)*input_N(end), input_pixel(end)*input_N(end), input_N(end)); 
    else
        iY = iX;
    end
    UU1 = matrix_propagation_sinc(iY, Y, f, k);
    UU2 = matrix_propagation_sinc(iX, X, f, k).';
    GetImage = @(W)propagation_sinc(normalize_field(W),UU1,UU2);
end