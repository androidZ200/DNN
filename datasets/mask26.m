% coordinates of the centers of the focus areas
function [Mask, coords] = mask26(Mesh, Full_rect, Mask_size)
    if length(Mask_size) == 1
        Mask_size(2) = Mask_size(1);
    end

    aa = (Full_rect(1) - Mask_size(1))/6;
    hh = (Full_rect(2) - Mask_size(2))/3;
    
    coords = [-2.5*aa -1.5*hh; -1.5*aa -1.5*hh; -0.5*aa -1.5*hh; 0.5*aa -1.5*hh; 1.5*aa -1.5*hh; 2.5*aa -1.5*hh; ...
        -3*aa -0.5*hh; -2*aa -0.5*hh; -aa -0.5*hh; 0 -0.5*hh; aa -0.5*hh; 2*aa -0.5*hh; 3*aa -0.5*hh; ...
        -3*aa  0.5*hh; -2*aa  0.5*hh; -aa  0.5*hh; 0  0.5*hh; aa  0.5*hh; 2*aa  0.5*hh; 3*aa  0.5*hh; ...
              -2.5*aa  1.5*hh; -1.5*aa  1.5*hh; -0.5*aa  1.5*hh; 0.5*aa  1.5*hh; 1.5*aa  1.5*hh; 2.5*aa  1.5*hh];
    coords = permute(coords, [3 2 1]);
    
    Mask = single((abs(Mesh.X - coords(1,2,:)) < Mask_size(2)/2).*...
                  (abs(Mesh.Y - coords(1,1,:)) < Mask_size(1)/2));
end