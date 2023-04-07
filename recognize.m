function [Score, F, CoordScore] = recognize(Input, z, DOES, k, MASK, U, is_max)
    % running the image through the system and ratings
    N = size(Input,1);
    F = zeros(N,N,length(z));
    % direct propagation
    F(:,:,1) = propagation(Input, z(1), k, U);
    for iter=1:length(z)-1
        F(:,:,iter+1) = propagation(F(:,:,iter).*DOES(:,:,iter), z(iter+1)-z(iter), k, U);
    end
    
    ln = size(MASK, 3);
    Score = zeros(1, ln);
    CoordScore = MASK;
    % getting ratings
    for nt = 1:ln
        if is_max % if we are looking for maxima in the areas
            [Score(nt), CoordScore(:,:,nt)] = get_max_intensity(F(:,:,end), MASK(:,:,nt));
        else % if we are looking for amounts in comments
            Score(nt) = get_energy(F(:,:,end), MASK(:,:,nt));
        end
    end
end

