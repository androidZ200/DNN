classdef SincPropagator < FreePropagator
    properties(Access=private)
        Left = 1;
        Right = 1;
        Rev_Left = 1;
        Rev_Right = 1;

        mesh_in = [];
        mesh_out = [];
    end

    methods
        function obj = SincPropagator(distance, wavelength)
            obj.distance = distance;
            obj.wavelength = wavelength;
        end

        function init(obj, Before_Mesh, After_Mesh)
            if isa(Before_Mesh, 'Prop')
                obj.mesh_in = Before_Mesh.output_mesh();
            elseif isa(Before_Mesh, 'Mesh')
                obj.mesh_in = Before_Mesh;
            else
                error('before is not propagator or mesh'); 
            end
            if isa(After_Mesh, 'Prop')
                obj.mesh_out = After_Mesh.input_mesh();
            elseif isa(Before_Mesh, 'Mesh')
                obj.mesh_out = After_Mesh;
            else
                error('after is not propagator or mesh'); 
            end

            if ~isempty(obj.mesh_in.Y) && ~isempty(obj.mesh_out.Y)
                obj.Left = obj.matrix_sinc(obj.mesh_in.Y, obj.mesh_out.Y, obj.f, 2*pi/obj.lambda);
                if isequal(obj.mesh_in.Y, obj.mesh_out.Y)
                    obj.Rev_Left = obj.Left;
                else
                    obj.Rev_Left = obj.matrix_sinc(obj.mesh_out.Y, obj.mesh_in.Y, obj.f, 2*pi/obj.lambda);
                end
            end
            
            if ~isempty(obj.mesh_in.X) && ~isempty(obj.mesh_out.X)
                if isequal(obj.mesh_in.X, obj.mesh_in.Y) && isequal(obj.mesh_out.X, obj.mesh_out.Y)
                    obj.Right = obj.Left.';
                else
                    obj.Right = obj.matrix_sinc(obj.mesh_in.X, obj.mesh_out.X, obj.f, 2*pi/obj.lambda).';
                end
                if isequal(obj.mesh_in.X, obj.mesh_out.X)
                    obj.Rev_Right = obj.Right;
                else
                    obj.Rev_Right = obj.matrix_sinc(obj.mesh_out.X, obj.mesh_in.X, obj.f, 2*pi/obj.lambda).';
                end
            end
        end

        function W = propagation(obj, W)
            W = pagemtimes(obj.Left, pagemtimes(W, obj.Right));
        end
        function W = back_propagation(obj, W)
            W = pagemtimes(obj.Rev_Left, pagemtimes(W, obj.Rev_Right));
        end
        function mesh = input_mesh(obj)
            if ~empty(obj.mesh_in)
                mesh = obj.mesh_in;
            else
                error('mesh does not initialize');
            end
        end
        function mesh = output_mesh(obj)
            if ~empty(obj.mesh_out)
                mesh = obj.mesh_out;
            else
                error('mesh does not initialize');
            end
        end
    end

    methods (Access = private, Static)
        function U = matrix_sinc(Mesh_old, Mesh_new, f, k)
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
                sqzk = sqrt(2.0*f./k);
                xm  = Mesh_old - Mesh_new;
                mu1 = -pi * sqzk * bndW - xm ./ sqzk;
                mu2 = +pi * sqzk * bndW - xm ./ sqzk;
                Smu1 = fresnelS(sq2p * mu1) / sq2p;
                Cmu1 = fresnelC(sq2p * mu1) / sq2p;
                Smu2 = fresnelS(sq2p * mu2) / sq2p;
                Cmu2 = fresnelC(sq2p * mu2) / sq2p;
            
                U = (sqrt(pixel_new*pixel_old) / pi) ./ sqzk .* sqrt(exp(1i*k.*f))...
                .* exp(0.5i * (xm.^2) .* k ./ f)...
                .* (Cmu2 - Cmu1 - 1i.* (Smu2 - Smu1));
            else
                U = 1;
            end
        end
    end
end