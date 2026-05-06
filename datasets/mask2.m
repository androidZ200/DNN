% coordinates of the centers of the focus areas
function [Mask, coords] = mask2(Mesh, distance, Mask_size)
    if length(Mask_size) == 1
        Mask_size(2) = Mask_size(1);
    end

    coords = [-Mask_size(1)/2 - distance/2 0; ...
               Mask_size(2)/2 + distance/2 0];
    coords = permute(coords, [3 2 1]);
    
    Mask = single((abs(Mesh.X - coords(1,2,:)) < Mask_size(2)/2).*...
                  (abs(Mesh.Y - coords(1,1,:)) < Mask_size(1)/2));
end