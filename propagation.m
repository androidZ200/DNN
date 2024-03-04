function Out = propagation(Field, U, method)
    % the function of radiation propagation


    switch(method)
        case 'fresnel'
            Out = pagemtimes(U, pagemtimes(Field, U.'));
        case 'fft'
            Out = ifft2(fft2(Field).*U);
        otherwise
            error('this method propagation not exist');
    end

end
