% coordinates of the centers of the focus areas
function [Mask, coords] = mask10_1(Mesh, Full_rect, Mask_size)
    if length(Mask_size) == 1
        Mask_size(2) = Mask_size(1);
    end

    aa = (Full_rect(1) - Mask_size(1))/3;
    hh = (Full_rect(2) - Mask_size(2))/2;
    
    coords = [-1.5*aa -hh;  -0.5*aa -hh;  0.5*aa -hh;  1.5*aa -hh; ...
              -1.5*aa   0;                             1.5*aa   0; ...
              -1.5*aa  hh;  -0.5*aa  hh;  0.5*aa  hh;  1.5*aa  hh];
    coords = permute(coords, [3 2 1]);
    
    Mask = single((abs(Mesh.X - coords(1,2,:)) < Mask_size(2)/2).*...
                  (abs(Mesh.Y - coords(1,1,:)) < Mask_size(1)/2));
end