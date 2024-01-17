function y = sinc( x )
    y = sin(pi*x)./(pi*x);
    y(isnan(y)) = 1;
end

