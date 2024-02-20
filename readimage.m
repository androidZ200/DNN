function [WF, W] = readimage(path, N, Pad)
	% we read the image and bring it to the specified form
	W = imread(path);
    W = mean(W, 3);
    W = W(end:-1:1, :);
	WF = single(zeros(N, N));
	W = interp2(W, linspace(1, size(W, 1), N - Pad*2), linspace(1, size(W, 2), N - Pad*2)', 'nearest');
    W(isnan(W)) = 0;
    W = single(normalize_field(W));
	WF(Pad+1:N-Pad, Pad+1:N-Pad) = W;
end