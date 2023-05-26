function E = get_energy(W, MASK)
    % energy in the area (sum)
    E = sum(sum(abs(W.*MASK).^2));
end
