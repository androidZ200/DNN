% coordinates of the centers of the focus areas
aa = (Full_width  - G_size_x)/7;
hh = (Full_height - G_size_y)/3;

coords = [-2.5*aa -1.5*hh; -1.5*aa -1.5*hh; -0.5*aa -1.5*hh; 0.5*aa -1.5*hh; 1.5*aa -1.5*hh; 2.5*aa -1.5*hh; ...
    -3*aa -0.5*hh; -2*aa -0.5*hh; -aa -0.5*hh; 0 -0.5*hh; aa -0.5*hh; 2*aa -0.5*hh; 3*aa -0.5*hh; ...
    -3*aa  0.5*hh; -2*aa  0.5*hh; -aa  0.5*hh; 0  0.5*hh; aa  0.5*hh; 2*aa  0.5*hh; 3*aa  0.5*hh; ...
          -2.5*aa  1.5*hh; -1.5*aa  1.5*hh; -0.5*aa  1.5*hh; 0.5*aa  1.5*hh; 1.5*aa  1.5*hh; 2.5*aa  1.5*hh];

if disp_info >= 2; ndisp('creating masks'); end
MASK = single((abs(X{end} - permute(coords(:,1), [3 2 1])) < G_size_x/2).*...
              (abs(Y{end} - permute(coords(:,2), [3 2 1])) < G_size_y/2));

clearvars aa hh;