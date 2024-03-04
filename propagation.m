function Out = propagation(Field, U)
    % the function of radiation propagation
    Out = pagemtimes(U, pagemtimes(Field, U.'));
end
