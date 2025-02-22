function [gradient, tmp_data] = criteria(gradient, tmp_data, name, params)
    % learning algorithm
    switch name
        case 'SGD'
            % standard gradient descent (without parameters)
            % gradient = gradient;
        case 'Nesterov'
            % gradient descent with momentum (params(1) - viscosity)
            tmp_data = cellfun(@(tmp,grad)params(1)*tmp + (1 - params(1))*grad, tmp_data,gradient,'UniformOutput',false);
            gradient = tmp_data;
        case 'Adagrad'
            % we accumulate learning weights (params(1) - so that there is no division by 0)
            tmp_data = cellfun(@(tmp,grad)tmp+grad.^2, tmp_data,gradient,'UniformOutput',false);
            gradient = cellfun(@(tmp,grad)grad./sqrt(tmp+params(1)), tmp_data,gradient,'UniformOutput',false);
        case 'RMSprop'
            % dynamically accumulating the gradient (params(1) - accumulating, params(2) - so that there is no division by 0)
            tmp_data = cellfun(@(tmp,grad)params(1)*tmp + (1 - params(1))*grad.^2, tmp_data,gradient,'UniformOutput',false);
            gradient = cellfun(@(tmp,grad)grad./sqrt(tmp+params(2)), tmp_data,gradient,'UniformOutput',false);
        case 'Adam'
            % Adam algorithm (params(1) - viscosity, params(2) - gradient accumulation,
            % params(3) - so that there is no division by 0, params(4) - the number of the current iteration)
            % recomend params = [0.9 0.999 1e-8];
            tmp_data = cellfun(@(tmp,grad)params(1)*real(tmp) + (1 - params(1))*grad + ...
                   1i*(params(2)*imag(tmp) + (1 - params(2))*grad.^2), tmp_data,gradient,'UniformOutput',false);
            gradient = cellfun(@(tmp)real(tmp)/(1 - params(1)^params(4))./ ...
                (sqrt(imag(tmp)/(1 - params(2)^params(4))) + params(3)), tmp_data,'UniformOutput',false);
        otherwise
            error(['criteria "' name '" is not exist']);
    end
end

