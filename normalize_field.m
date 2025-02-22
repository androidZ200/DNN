function [ Field ] = normalize_field( Field )
    Field = Field./sqrt(sum(abs(Field).^2, [1, 2]));
end

