function E = get_energy(W, MASK)
    % energy in the area (sum)
    E = squeeze(sum(sum(abs(W).^2 .* MASK)));
end
