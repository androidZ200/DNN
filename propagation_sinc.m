function Out = propagation_sinc(Field, U)
    % the function of radiation propagation
    if (size(U,3) == 1)
        Out = pagemtimes(U, pagemtimes(Field, U.'));
    else
        Out = pagemtimes(U(:,:,1), pagemtimes(Field, U(:,:,2)));
    end
end
