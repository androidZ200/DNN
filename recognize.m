function [Score, F, CoordScore] = recognize(Input, Propogations, DOES, MASK, is_max)
    % running the image through the system and ratings
    F = direct_propagation(Input, Propogations, DOES);
    [Score, CoordScore] = get_scores(F(:,:,end), MASK, is_max);
end

