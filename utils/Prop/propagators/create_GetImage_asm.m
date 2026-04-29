function GetImage = create_GetImage_asm(input_pixel, output_pixel, N, k, f, is_gpu)
    UU = matrix_propagation_asm(output_pixel,N,f,k);
    if nargin > 5 && is_gpu; UU = gpuArray(UU); end
    GetImage = @(W)propagation_asm(normalize_field(resizeimage(W,N,input_pixel,output_pixel)),UU);
end