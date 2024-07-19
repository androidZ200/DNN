function rdisp(text)
    global nbytes;
    if nargin == 0
        nbytes = fprintf([repmat('\b', [1 nbytes])]) - nbytes;
    else
        text = strrep(text, '%', '%%');
        text = strrep(text, '\', '\\');
        nbytes = fprintf([repmat('\b', [1 nbytes]) text '\n']) - nbytes;
    end
end