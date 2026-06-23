classdef Field
    properties
        CA = 0; %complex amplitude
    end
    
    methods
        function obj = Field(ca)
            if nargin > 0
                obj.CA = ca;
            end
        end
        
        function int = intensity(obj)
            int = abs(obj.CA).^2;
        end
        function E = energy(obj, mask)
            if nargin < 2
                mask = 1;
            end
            E = sum(obj.intensity().*mask, [1 2]);
        end
        function sz = size(obj, N)
            if nargin < 2
                sz = size(obj.CA);
            else
                sz = size(obj.CA, N);
            end
        end
        function field = conj(obj)
            field = Field(conj(obj.CA));
        end
        function res = plus(obj, other)
            if isa(other, 'Field')
                res = Field(obj.CA + other.CA);
            else
                res = Field(obj.CA + other);
            end
        end
    end
end

