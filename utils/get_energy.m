function E = get_energy(W, MASK)
    % energy in the area (sum)
    E = squeeze(sum(abs(W).^2 .* MASK, [1 2]));
end
