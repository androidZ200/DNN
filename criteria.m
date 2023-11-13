function [step, tmp_data] = criteria(gradient, tmp_data, name, params)
    % learning algorithm
    switch name
        case 'SGD'
            % standard gradient descent (without parameters)
            step = gradient;
        case 'Nesterov'
            % gradient descent with momentum (params(1) - viscosity)
            tmp_data = params(1)*tmp_data + (1 - params(1))*gradient;
            step = tmp_data;
        case 'Adagrad'
            % we accumulate learning weights (params(1) - so that there is no division by 0)
            tmp_data = tmp_data + gradient.^2;
            step = gradient ./ sqrt(tmp_data + params(1));
        case 'RMSprop'
            % dynamically accumulating the gradient (params(1) - accumulating, params(2) - so that there is no division by 0)
            tmp_data = params(1)*tmp_data + (1 - params(1))*gradient.^2;
            step = gradient ./ sqrt(tmp_data + params(2));
        case 'Adam'
            % Adam algorithm (params(1) - viscosity, params(2) - gradient accumulation,
            % params(3) - so that there is no division by 0, params(4) - the number of the current iteration)
            % recomend params = [0.9 0.999 1e-8];
            tmp_data = params(1)*real(tmp_data) + (1 - params(1))*gradient + ...
                   1i*(params(2)*imag(tmp_data) + (1 - params(2))*gradient.^2);
            step = real(tmp_data)/(1 - params(1)^params(4))./ ...
                sqrt(imag(tmp_data)/(1 - params(2)^params(4)) + params(3));
        otherwise
            error(['criteria "' name '" is not exist']);
    end
end

