function E = get_energy(W, MASK)
    % energy in the area (sum)
    E = squeeze(sum(sum(abs(bsxfun(@times,W,MASK)).^2)));
end
