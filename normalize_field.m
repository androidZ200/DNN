function [ Field ] = normalize_field( Field )
    Field = bsxfun(@rdivide,Field,sqrt(sum(sum(abs(Field).^2))));
end

