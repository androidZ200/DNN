function E = get_energy(W, MASK)
    E = sum(sum(abs(W.*MASK).^2));
end