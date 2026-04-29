classdef Mesh < handle
    properties
        X = [];
        Y = [];
    end

    methods
        function obj = Mesh(pixel,N,is_gpu)
            if length(pixel) == 1; pixel(2) = pixel; end
            if length(N) == 1; N(2) = N; end

            if N(1) > 1; obj.Y = linspace_m(-pixel(1)*N(1)/2, pixel(1)*N(1)/2, N(1)).'; end
            if N(2) > 1; obj.X = linspace_m(-pixel(2)*N(2)/2, pixel(2)*N(2)/2, N(2)); end

            if (nargin > 2 && is_gpu)
                obj.X = gpuArray(obj.X);
                obj.Y = gpuArray(obj.Y);
            end
        end
    end
end