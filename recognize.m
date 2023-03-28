function [Score, F, CoordScore] = recognize(Input, z, DOES, k, MASK, U)    
    N = size(Input,1);
    F = zeros(N,N,length(z));
    F(:,:,1) = propagation(Input, z(1), k, U);
    for iter=1:length(z)-1
        F(:,:,iter+1) = propagation(F(:,:,iter).*DOES(:,:,iter), z(iter+1)-z(iter), k, U);
    end
    
    ln = size(MASK, 3);
    Score = zeros(1, ln);
    CoordScore = MASK;
    for nt = 1:ln
% 		[Score(nt), CoordScore(:,:,nt)] = get_max_intensity(F(:,:,end), MASK(:,:,nt));
        Score(nt) = get_energy(F(:,:,end), MASK(:,:,nt));
    end
end

