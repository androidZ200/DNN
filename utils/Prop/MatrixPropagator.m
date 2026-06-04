classdef (Abstract) MatrixPropagator < handle
    methods (Abstract)
        get_left_f();
        get_right_f();
        get_left_b();
        get_right_b();
    end
end

