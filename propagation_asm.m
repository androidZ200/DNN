function Out = propagation_asm(Field, U)
    % the function of radiation propagation
    Out = ifft2(fft2(Field).*U);
end
