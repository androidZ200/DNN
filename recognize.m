function [Score, F, CoordScore] = recognize(Input, z, DOES, k, MASK, U, is_max)
    % running the image through the system and ratings
    F = system_propagation(Input, DOES, z, k, U);
    [Score, CoordScore] = get_scores(F(:,:,end), MASK, is_max);
end

