classdef Field
    properties
        CA (:,:); %complex amplitude
        mesh Mesh;
    end
    
    methods
        function obj = Field(mesh, ca)
            obj.mesh = mesh;
            if nargin > 1
                if isequal(size(ca), size(mesh))
                    obj.CA = ca;
                else
                    error("size mesh and complex amplitude not equal");
                end
            else
                obj.CA = GPUTest(single(zeros(size(mesh))));
            end
        end
        
        function int = intensity(obj)
            int = abs(obj.CA).^2;
        end
        function sz = size(obj, N)
            if nargin < 2
                sz = size(obj.mesh);
            else
                sz = size(obj.mesh, N);
            end
        end
        function im = imagesc(varargin)
            h = imagesc(varargin{1}.mesh.X, varargin{1}.mesh.Y, varargin{1}.intensity(), varargin{2:end});
            if nargout > 0
                im = h;
            end
        end
        function res = plus(obj, other)
            if isa(other, 'Field')
                if ~isequal(obj.mesh, other.mesh)
                    warning('meshs of fields are not equal');
                end
                res = Field(obj.mesh, obj.CA + other.CA);
            else
                res = Field(obj.mesh, obj.CA + other);
            end
        end
    end
end

