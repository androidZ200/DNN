function Out = propagation(Field, z, U)
    % the function of radiation propagation over a distance z
    F = exp(1i*z*U); 
    % U = sqrt(k^2 - U)
    % U = k - U/2/k
        
    Out = ifft2(fft2(Field).*F);
end
