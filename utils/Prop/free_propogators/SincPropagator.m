classdef SincPropagator < FreePropagator & MatrixPropagator
    properties(SetAccess=private)
        Mat_left_f = 1;
        Mat_right_f = 1;
        Mat_left_b = 1;
        Mat_right_b = 1;

        mesh_in = [];
        mesh_out = [];
    end

    methods
        function obj = SincPropagator(prev, distance, wavelength)
            obj = obj@FreePropagator(prev);
            obj.distance = distance;
            obj.wavelength = wavelength;
        end

        function init(obj)
            if isempty(obj.prev_node) || isempty(obj.next_node)
                return;
            end
            obj.mesh_in = obj.prev_node.output_mesh();
            obj.mesh_out = obj.next_node.input_mesh();

            if ~isempty(obj.mesh_in.X) && ~isempty(obj.mesh_out.X)
                obj.Mat_left_f = obj.matrix_sinc(obj.mesh_in.X, obj.mesh_out.X, obj.distance, 2*pi/obj.wavelength);
                if isequal(obj.mesh_in.X, obj.mesh_out.X)
                    obj.Mat_left_b = obj.Mat_left_f;
                else
                    obj.Mat_left_b = obj.matrix_sinc(obj.mesh_out.X, obj.mesh_in.X, obj.distance, 2*pi/obj.wavelength);
                end
            end
            
            if ~isempty(obj.mesh_in.Y) && ~isempty(obj.mesh_out.Y)
                if isequal(obj.mesh_in.X, obj.mesh_in.Y) && isequal(obj.mesh_out.X, obj.mesh_out.Y)
                    obj.Mat_right_f = obj.Mat_left_f.';
                else
                    obj.Mat_right_f = obj.matrix_sinc(obj.mesh_in.Y, obj.mesh_out.Y, obj.distance, 2*pi/obj.wavelength).';
                end
                if isequal(obj.mesh_in.Y, obj.mesh_out.Y)
                    obj.Mat_right_b = obj.Mat_right_f;
                else
                    obj.Mat_right_b = obj.matrix_sinc(obj.mesh_out.Y, obj.mesh_in.Y, obj.distance, 2*pi/obj.wavelength).';
                end
            end
        end

        function field = get_field(obj, input)
            field = obj.prev_node.get_field(input);
            field = Field(obj.mesh_out, pagemtimes(obj.Mat_left_f, pagemtimes(field.CA, obj.Mat_right_f)));
        end
        function set_error_field(obj, error)
            error = Field(obj.mesh_in, pagemtimes(obj.Mat_left_b, pagemtimes(error.CA, obj.Mat_right_b)));
            obj.prev_node.set_error_field(error);
        end
        function mesh = input_mesh(obj)
            if ~isempty(obj.mesh_in)
                mesh = obj.mesh_in;
            else
                error('mesh does not initialize');
            end
        end
        function mesh = output_mesh(obj)
            if ~isempty(obj.mesh_out)
                mesh = obj.mesh_out;
            else
                error('mesh does not initialize');
            end
        end

        function M = get_left_f(obj)
            M = obj.Mat_left_f;
        end
        function M = get_right_f(obj)
            M = obj.Mat_right_f;
        end
        function M = get_left_b(obj)
            M = obj.Mat_left_b;
        end
        function M = get_right_b(obj)
            M = obj.Mat_right_b;
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