function phi = min_phase(G, F)
    phi = exp(1i*angle(sum(sum(G.*abs(F), 3), 4)));
end

