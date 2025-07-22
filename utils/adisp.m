function adisp(text)
    global nbytes;
    if nargin == 0
        nbytes = fprintf('\n') + nbytes;
    else
        text = strrep(text, '%', '%%');
        % text = strrep(text, '\', '\\');
        nbytes = fprintf([text '\n']) + nbytes;
    end
end