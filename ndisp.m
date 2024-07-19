function ndisp(text)
    global nbytes;
    if nargin == 0
        nbytes = fprintf('\n');
    else
        text = strrep(text, '%', '%%');
        text = strrep(text, '\', '\\');
        nbytes = fprintf([text '\n']);
    end
end