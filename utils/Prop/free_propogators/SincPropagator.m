classdef SincPropagator < FreePropagator & MatrixPropagator
    properties(SetAccess=private)
        Mat_left = 1;
        Mat_right = 1;

        mesh_in = [];
        mesh_out = [];
    end

    methods
        function obj = SincPropagator(prev, distance, wavelength)
            obj = obj@FreePropagator(prev);
            obj.distance = distance;
            obj.wavelength = wavelength;
            obj.mesh_in = prev.output_mesh();
        end

        function init(obj, mesh)
            if isempty(obj.output_mesh)
                obj.mesh_out = mesh;
                if isempty(obj.mesh_in)
                    obj.mesh_in = obj.mesh_out;
                end
    
                if ~isempty(obj.mesh_in.X) && ~isempty(obj.mesh_out.X)
                    obj.Mat_left = obj.matrix_sinc(obj.mesh_in.X, obj.mesh_out.X, obj.distance, 2*pi/obj.wavelength);
                end
                
                if ~isempty(obj.mesh_in.Y) && ~isempty(obj.mesh_out.Y)
                    if isequal(obj.mesh_in.X, obj.mesh_in.Y) && isequal(obj.mesh_out.X, obj.mesh_out.Y)
                        obj.Mat_right = obj.Mat_left.';
                    else
                        obj.Mat_right = obj.matrix_sinc(obj.mesh_in.Y, obj.mesh_out.Y, obj.distance, 2*pi/obj.wavelength).';
                    end
                end
    
                obj.prev_node.set_output_mesh(obj.mesh_in);
            end
        end

        function field = get_field(obj, input)
            field = obj.prev_node.get_field(input);
            field = Field(obj.mesh_out, obj.prop(obj.Mat_left, field.CA, obj.Mat_right));
        end
        function set_error_field(obj, error)
            error = Field(obj.mesh_in, obj.prop(obj.Mat_left.', error.CA, obj.Mat_right.'));
            obj.prev_node.set_error_field(error);
        end
        function mesh = input_mesh(obj)
            mesh = obj.mesh_in;
        end
        function mesh = output_mesh(obj)
            mesh = obj.mesh_out;
        end

        function M = get_left(obj)
            M = obj.Mat_left;
        end
        function M = get_right(obj)
            M = obj.Mat_right;
        end
    end

    methods (Access = private, Static)
        function U = matrix_sinc(Mesh_old, Mesh_new, z, k)
            Mesh_old = reshape(Mesh_old,1,[]);
            Mesh_new = reshape(Mesh_new,[],1);
        
            if length(Mesh_old) > 1
                pixel_old = Mesh_old(2)-Mesh_old(1);
                if length(Mesh_new) > 1
                    pixel_new = Mesh_new(2)-Mesh_new(1);
                else
                    pixel_new = pixel_old;
                end
            
                bndW = 0.5/pixel_old;
                sq2p = sqrt(2.0/pi);
                sqzk = sqrt(2.0*z./k);
                xm  = Mesh_old - Mesh_new;
                mu1 = -pi * sqzk * bndW - xm ./ sqzk;
                mu2 = +pi * sqzk * bndW - xm ./ sqzk;
                Smu1 = fresnelS(sq2p * mu1) / sq2p;
                Cmu1 = fresnelC(sq2p * mu1) / sq2p;
                Smu2 = fresnelS(sq2p * mu2) / sq2p;
                Cmu2 = fresnelC(sq2p * mu2) / sq2p;
            
                U = (sqrt(pixel_new*pixel_old) / pi) ./ sqzk .* sqrt(exp(1i*k.*z))...
                .* exp(0.5i * (xm.^2) .* k ./ z)...
                .* (Cmu2 - Cmu1 - 1i.* (Smu2 - Smu1));
            else
                U = 1;
            end
        end
    end
end

% Cubillos, M. Numerical simulation of optical propagation using sinc approximation /
% M. Cubillos, E. Jimenez // Journal of the Optical Society of America A. -
% 2022. - Vol. 39, Issue 8. - P. 1403-1413. - DOI: https://doi.org/10.1364/JOSAA.461355