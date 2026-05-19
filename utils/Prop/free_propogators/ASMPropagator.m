classdef ASMPropagator < FreePropagator
    properties(SetAccess=private)
        U;
        mesh = [];
    end

    methods
        function obj = ASMPropagator(distance, wavelength)
            obj.distance = distance;
            obj.wavelength = wavelength;
        end

        function init(obj, Before_Mesh, After_Mesh)
            if isa(Before_Mesh, 'Prop') || isa(Before_Mesh, 'GetInput')
                mesh_in = Before_Mesh.output_mesh();
            elseif isa(Before_Mesh, 'Mesh')
                mesh_in = Before_Mesh;
            else
                error('before is not propagator or mesh'); 
            end
            if isa(After_Mesh, 'Prop') || isa(After_Mesh, 'GetOutput')
                mesh_out = After_Mesh.input_mesh();
            elseif isa(Before_Mesh, 'Mesh')
                mesh_out = After_Mesh;
            else
                error('after is not propagator or mesh'); 
            end

            ky = 0; kx = 0; Ny = 0; Nx = 0;
            if ~isempty(mesh_in.Y) && ~isempty(mesh_out.Y)
                if ~isequal(mesh_in.Y, mesh_out.Y)
                    error('grid Y is not equal');
                end
                Ny = length(mesh_in.Y); pixely = (mesh_in.Y(end) - mesh_in.Y(1))/(Ny-1);
                ky = linspace_l(-pi/pixely, pi/pixely, Ny).';
            end
            if ~isempty(mesh_in.X) && ~isempty(mesh_out.X)
                if ~isequal(mesh_in.X, mesh_out.X)
                    error('grid X is not equal');
                end
                Nx = length(mesh_in.X); pixelx = (mesh_in.X(end) - mesh_in.X(1))/(Nx-1);
                kx = linspace_l(-pi/pixelx, pi/pixelx, Nx);
            end
            obj.mesh = mesh_in;

            T = circshift(kx.^2 + ky.^2, [Nx/2 Ny/2]);
            obj.U = exp(1i*obj.distance.*single(sqrt((2*pi/obj.wavelength).^2 - T)));
        end

        function W = propagation(obj, W)
            W = ifft2(fft2(W).*obj.U);
        end
        function W = back_propagation(obj, W)
            W = obj.propagation(W);
        end
        function mesh = input_mesh(obj)
            if ~isempty(obj.mesh)
                mesh = obj.mesh;
            else
                error('mesh does not initialize');
            end
        end
        function mesh = output_mesh(obj)
            mesh = obj.input_mesh();
        end
    end
end