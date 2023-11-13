function [ Field ] = normalize_field( Field )
    Field = Field / sqrt(sum(sum(abs(Field).^2)));
end

