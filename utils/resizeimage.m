function W = resizeimage(Image, N, source_pixel, next_pixel)
    % we scale the images to the desired parameters
    x = linspace(-source_pixel*size(Image,1)/2, source_pixel*size(Image,1)/2, size(Image,1)+1); x(end)=[]; x=x+source_pixel/2;
    y = linspace(-source_pixel*size(Image,2)/2, source_pixel*size(Image,2)/2, size(Image,2)+1)'; y(end)=[]; y=y+source_pixel/2;
    xx = linspace(-next_pixel*N/2, next_pixel*N/2, N+1); xx(end)=[];  xx=xx+next_pixel/2;
    yy = xx';
    if size(Image,3) > 1
        z = 1:size(Image, 3);
        W = interp3(x, y, z, Image, xx, yy, z, 'nearest');
    else
        W = interp2(x, y, Image, xx, yy, 'nearest');
    end
    W(isnan(W)) = 0;
end

