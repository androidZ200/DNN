function [ Score, CoordScore ] = get_scores( F, MASK, is_max )
    ln = size(MASK, 3);
    Score = zeros(1, ln);
    CoordScore = MASK;
    % getting ratings
    for nt = 1:ln
        if is_max % if we are looking for maxima in the areas
            [Score(nt), CoordScore(:,:,nt)] = get_max_intensity(F, MASK(:,:,nt));
        else % if we are looking for amounts in comments
            Score(nt) = get_energy(F, MASK(:,:,nt));
        end
    end
end

