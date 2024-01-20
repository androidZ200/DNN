function [ Score, CoordScore ] = get_scores( F, MASK, is_max )
    % getting ratings
    if is_max % if we are looking for maxima in the areas
        [Score, CoordScore] = get_max_intensity(F, MASK);
    else % if we are looking for amounts in the areas
        Score = get_energy(F, MASK);
        CoordScore = repmat(MASK, [1 1 1 size(F,4)]);
    end
end

