function W = resizeimage(Image, N, source_pixel, next_pixel)
    % we scale the images to the desired parameters
    xold = linspace(-source_pixel(1)*size(Image,1)/2, source_pixel(1)*size(Image,1)/2, size(Image,1)+1); xold(end)=[]; xold=xold+source_pixel(1)/2;
    yold = linspace(-source_pixel(end)*size(Image,2)/2, source_pixel(end)*size(Image,2)/2, size(Image,2)+1)'; yold(end)=[]; yold=yold+source_pixel(end)/2;
    xnew = linspace(-next_pixel(1)*N(1)/2, next_pixel(1)*N(1)/2, N(1)+1); xnew(end)=[];  xnew=xnew+next_pixel(1)/2;
    ynew = linspace(-next_pixel(end)*N(end)/2, next_pixel(end)*N(end)/2, N(end)+1)'; ynew(end)=[];  ynew=ynew+next_pixel(end)/2;
    if size(Image,3) > 1
        z = 1:size(Image, 3);
        W = interp3(xold, yold, z, Image, xnew, ynew, z, 'nearest');
    else
        W = interp2(xold, yold, Image, xnew, ynew, 'nearest');
    end
    W(isnan(W)) = 0;
end

