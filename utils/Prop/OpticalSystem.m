classdef OpticalSystem < handle
    properties
        Middle (1,1) Prop;
        Input  (1,1) GetInput;
        Output (1,1) GetOutput;
    end
    
    methods
        function obj = OpticalSystem(Input, Middle, Output)
            obj.Input = Input;
            obj.Middle = Middle;
            obj.Output = Output;

            obj.Middle.init(obj.Input.output_mesh(), obj.Output.input_mesh());
        end

        function Score = Forward(obj,Data)
            W = obj.Input.propagation(Data);
            W = obj.Middle.propagation(W);
            Score = obj.Output.propagation(W);
        end
        function gradient = Backward(obj,Error)
            F = obj.Output.back_propagation(Error);
            obj.Middle.back_propagation(F);
            gradient = obj.Middle.get_gradient();
        end
        function step(obj,gradient,speed)
            obj.Middle.step(gradient,speed);
        end
    end
end

