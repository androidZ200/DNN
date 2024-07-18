function U = matrix_propagation( X, Y, f, k, method )
    pixel = (X(1,2)-X(1,1));
    switch method
        case 'sphere'
            X = X - X(1,1) - (X(1,end) - X(1,1) + pixel)/2;
            Y = Y - Y(1,1) - (Y(end,1) - Y(1,1) + pixel)/2;
            R = sqrt(X.^2 + Y.^2 + f.^2);
            H = f/2/pi.*exp(1i*k.*R).*(1./R - 1i*k)./R.^2*pixel^2;
            U = fft2(circshift(H,size(X)/2));
        case 'fresnel'
            pixel = pixel/2;
            xm = X - Y;
            h = sqrt(k/pi./f);
            U = fresnelC(h.*(xm + pixel)) - fresnelC(h.*(xm - pixel)) + ...
            1i*(fresnelS(h.*(xm + pixel)) - fresnelS(h.*(xm - pixel)));
            U = U.*sqrt(exp(1i*k.*f)/2i);
        case 'ASM'
            N = size(X,1);
            kx = linspace(-pi/pixel, pi/pixel, N+1); kx(end) = [];
            [Kx, Ky] = meshgrid(kx, kx);
            U = circshift(Kx.^2 + Ky.^2, [N/2 N/2]);
            U = exp(1i*f.*single(sqrt(k.^2 - U)));
        case 'sinc'
            bndW = 0.5/pixel;
            sq2p = sqrt(2.0/pi);
            sqzk = sqrt(2.0*f./k);
            xm  = X - Y;
            mu1 = -pi * sqzk * bndW - xm ./ sqzk;
            mu2 = +pi * sqzk * bndW - xm ./ sqzk;
            Smu1 = fresnelS(sq2p * mu1) / sq2p;
            Cmu1 = fresnelC(sq2p * mu1) / sq2p;
            Smu2 = fresnelS(sq2p * mu2) / sq2p;
            Cmu2 = fresnelC(sq2p * mu2) / sq2p;
            U = (pixel / pi) ./ sqzk .* sqrt(exp(1i*k.*f))...
            .* exp(0.5i * (xm.^2) .* k ./ f)...
            .* (Cmu2 - Cmu1 - 1i.* (Smu2 - Smu1));
        otherwise
            error('this method propagation not exist');
    end
end