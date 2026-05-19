classdef OpticalSystem < handle
    properties (SetAccess=protected)
        Middle (1,1);
        Input  (1,1);
        Output (1,1);
    end
    
    methods
        function obj = OpticalSystem(Input, Middle, Output)
            if ~isa(Input, 'GetInput'); error('Input must be the GetInput class'); end
            if ~isa(Output, 'GetOutput'); error('Output must be the GetOutput class'); end
            if ~isa(Middle, 'Prop'); error('Middle must be the Prop class'); end
            obj.Input = Input;
            obj.Middle = Middle;
            obj.Output = Output;

            obj.Middle.init(obj.Input, obj.Output);
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
        function Step(obj,gradient,speed)
            obj.Middle.step(gradient,speed);
        end
    end
end

