function GetImage = create_GetImage_sinc(input_pixel, input_N, X, Y, k, f)
    iX = linspace(-input_pixel(1)*input_N(1), input_pixel(1)*input_N(1), input_N(1)+1); 
    iX(end) = []; iX = iX + input_pixel(1)/2;
    if length(input_pixel) > 1 || length(input_N) > 1
        iY = linspace(-input_pixel(end)*input_N(end), input_pixel(end)*input_N(end), input_N(end)+1); 
        iY(end) = []; iY = iY + input_pixel(end)/2;
    else
        iY = iX;
    end
    UU1 = matrix_propagation_sinc(iY, Y, f, k);
    UU2 = matrix_propagation_sinc(iX, X, f, k).';
    GetImage = @(W)propagation_sinc(normalize_field(W),UU1,UU2);
end