function str = waitbartext(length, progress)
    length = floor(length);
    if progress < 0
        str = ['[', repmat(' ', [1, length]), ']'];
    elseif progress < 1
        fill = floor(length*progress);
        str = ['[', repmat('=', [1, fill]), '>', repmat(' ', [1, length - fill - 1]), ']'];
    else
        str = ['[', repmat('=', [1, length]), ']'];
    end
end

