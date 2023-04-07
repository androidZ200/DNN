function W = resizeimage(Image, FullN, ImageN)
    % we scale the images to the desired parameters
    W = zeros(FullN, FullN);
	F = interp2(Image, linspace(1, size(Image, 1), ImageN), linspace(1, size(Image, 2), ImageN)', 'nearest');
    F(isnan(F)) = 0;
    F = F / sqrt(sum(sum(abs(F).^2)));
	W(FullN/2-ImageN/2+1:FullN/2+ImageN/2, FullN/2-ImageN/2+1:FullN/2+ImageN/2) = F;
end

