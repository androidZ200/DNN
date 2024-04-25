function [Score, Fields, CoordScore] = recognize(Fields, Propogations, DOES, MASK, is_max)
    % running the image through the system and ratings
    Fields = direct_propagation(Fields, Propogations, DOES);
    [Score, CoordScore] = get_scores(Fields(:,:,end,:), MASK, is_max);
end

