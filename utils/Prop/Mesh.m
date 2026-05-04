classdef Mesh < handle
    properties (SetAccess=private)
        X (1,:) single = [];
        Y (1,:) single = [];
    end

    methods
        function obj = Mesh(pixel,N)
            if length(pixel) == 1; pixel(2) = pixel; end
            if length(N) == 1; N(2) = N; end

            if N(1) > 1; obj.Y = GPUTest(linspace_m(-pixel(1)*N(1)/2, pixel(1)*N(1)/2, N(1)).'); end
            if N(2) > 1; obj.X = GPUTest(linspace_m(-pixel(2)*N(2)/2, pixel(2)*N(2)/2, N(2))); end
        end

        function sz = size(obj, N)
            if nargin < 2
                sz = [length(obj.X) length(obj.Y)];
            else
                sz = zeros(1,length(N));
                for iter=1:length(N)
                    if N(iter) == 1
                        sz(iter) = length(obj.X);
                    elseif N(iter) == 2
                        sz(iter) = length(obj.Y);
                    else
                        error('Mesh has only 2 dimenshons');
                    end
                end
            end
        end
    end
end