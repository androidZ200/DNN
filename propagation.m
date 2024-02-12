function Out = propagation(Field, U)
    % the function of radiation propagation
    Out = zeros(size(Field));
    for iter1=1:size(Field,3)
        for iter2=1:size(Field,4)
            Out(:,:,iter1,iter2) = U*Field(:,:,iter1,iter2)*(U.');
        end
    end
end
