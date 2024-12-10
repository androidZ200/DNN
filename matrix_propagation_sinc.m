function U = matrix_propagation_sinc( Mesh_old, Mesh_new, f, k )
    Mesh_old = reshape(Mesh_old,1,[]);
    Mesh_new = reshape(Mesh_new,[],1);

    pixel_old = Mesh_old(2)-Mesh_old(1);
    pixel_new = Mesh_new(2)-Mesh_new(1);

    bndW = 0.5/pixel_old;
    sq2p = sqrt(2.0/pi);
    sqzk = sqrt(2.0*f./k);
    xm  = Mesh_old - Mesh_new;
    mu1 = -pi * sqzk * bndW - xm ./ sqzk;
    mu2 = +pi * sqzk * bndW - xm ./ sqzk;
    Smu1 = fresnelS(sq2p * mu1) / sq2p;
    Cmu1 = fresnelC(sq2p * mu1) / sq2p;
    Smu2 = fresnelS(sq2p * mu2) / sq2p;
    Cmu2 = fresnelC(sq2p * mu2) / sq2p;
    
    U = (sqrt(pixel_new*pixel_old) / pi) ./ sqzk .* sqrt(exp(1i*k.*f))...
    .* exp(0.5i * (xm.^2) .* k ./ f)...
    .* (Cmu2 - Cmu1 - 1i.* (Smu2 - Smu1));
end