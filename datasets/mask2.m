% coordinates of the centers of the focus areas
coords = [-G_size_x 0; G_size_x 0]*2;

if disp_info >= 2; ndisp('creating masks'); end
MASK = single((abs(X{end} - permute(coords(:,1), [3 2 1])) < G_size_x/2).*...
              (abs(Y{end} - permute(coords(:,2), [3 2 1])) < G_size_y/2));