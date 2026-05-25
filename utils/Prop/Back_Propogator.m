classdef (Abstract) Back_Propogator < handle
    methods (Abstract)
        need = need_error_field();
        set_error_field(error);
        gradient_step(speed);
        clear();
    end
end