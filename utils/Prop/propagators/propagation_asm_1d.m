function Out = propagation_asm_1d(Field, U)
    % the function of radiation propagation
    Out = ifft(fft(Field).*U);
end