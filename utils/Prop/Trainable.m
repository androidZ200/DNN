classdef (Abstract) Trainable < handle
    properties
        Tensor;
        Mask;
        optimizer;
    end

    methods (Abstract)
        grad = get_gradient();
    end

    methods
        function obj = Trainable(N, is_gpu, optimizer_fabric)
            obj.Tensor = zeros(N, 'single');
            obj.Mask = 1;
            if is_gpu
                obj.Tensor = gpuArray(obj.Tensor); 
            end
            if nargin >= 3
                if ~isa(optimizer_fabric, 'OptimizerFabric'); error('optimizer is not fabric'); end
                obj.optimizer = optimizer_fabric.generate(N, is_gpu);
            else
                obj.optimizer = SGDOptimizer();
            end
        end

        function step(obj, gradient, speed)
            szg = size(gradient); szt = size(obj.Tensor);
            if length(szg) > length(szt); szt = [szt ones(1,length(szg)-length(szt))]; end
            gradient = sum(gradient,find((szg - szt)>0));
            gradient = obj.optimizer.optimize(gradient);
            obj.Tensor = obj.Tensor + speed*gradient.*obj.Mask;
        end

        function is = is_trainable(obj)
            is = max(obj.Mask,[],'all') > 0;
        end

        function obj = set_mask(obj, Mask)
            obj.Mask = Mask;
        end

        function SZ = size(obj, N)
            if nargin > 1
                SZ = size(obj.Tensor, N);
            else
                SZ = size(obj.Tensor);
            end
        end
    end

end