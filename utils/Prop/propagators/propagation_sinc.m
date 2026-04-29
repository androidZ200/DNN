function Out = propagation_sinc(Field, U1, U2)
    % the function of radiation propagation
    if (nargin == 2)
        Out = pagemtimes(U1, pagemtimes(Field, U1.'));
    else
        Out = pagemtimes(U1, pagemtimes(Field, U2));
    end
end
