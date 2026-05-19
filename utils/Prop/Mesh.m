classdef Mesh < handle
    properties (SetAccess=private)
        X (:,1) = [];
        Y (1,:) = [];
    end

    methods
        function obj = Mesh(pixel,N)
            if length(pixel) == 1; pixel(2) = pixel; end
            if length(N) == 1; N(2) = N; end

            PN = pixel.*N/2;

            if N(1) > 1; obj.X = GPUTest(single(linspace_m(-PN(1), PN(1), N(1)).')); end
            if N(2) > 1; obj.Y = GPUTest(single(linspace_m(-PN(2), PN(2), N(2)))); end
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