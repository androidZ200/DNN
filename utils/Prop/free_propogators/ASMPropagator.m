classdef ASMPropagator < FreePropagator
    properties(SetAccess=private)
        U;
        mesh = [];
    end

    methods
        function obj = ASMPropagator(prev, distance, wavelength)
            obj = obj@FreePropagator(prev);
            obj.distance = distance;
            obj.wavelength = wavelength;

            mesh = prev.output_mesh();
            if ~isempty(mesh)
                obj.init(mesh);
            end
        end

        function init(obj, mesh)
            if ~isempty(obj.mesh)
                if ~isequal(obj.mesh, mesh)
                    error('The Meshes dont match');
                end
                return;
            else
                obj.mesh = mesh;
            end

            ky = 0; kx = 0; Ny = 0; Nx = 0;
            if ~isempty(mesh.Y)
                Ny = length(mesh.Y); pixely = (mesh.Y(end) - mesh.Y(1))/(Ny-1);
                ky = linspace_l(-pi/pixely, pi/pixely, Ny).';
            end
            if ~isempty(mesh.X)
                Nx = length(mesh.X); pixelx = (mesh.X(end) - mesh.X(1))/(Nx-1);
                kx = linspace_l(-pi/pixelx, pi/pixelx, Nx);
            end

            T = circshift(kx.^2 + ky.^2, [Nx/2 Ny/2]);
            obj.U = exp(1i*obj.distance.*single(sqrt((2*pi/obj.wavelength).^2 - T)));

            obj.prev_node.set_output_mesh(mesh);
        end

        function field = get_field(obj, input)
            field = obj.prev_node.get_field(input);
            field = ifft2(fft2(field).*obj.U);
        end
        function set_error_field(obj, error)
            error = ifft2(fft2(error).*obj.U);
            obj.prev_node.set_error_field(error);
        end
        function mesh = input_mesh(obj)
            mesh = obj.mesh;
        end
        function mesh = output_mesh(obj)
            mesh = obj.input_mesh();
        end
    end
end