function TrackControl(Func, LastPos)
    if nargin < 2
        LastPos.X = 0; LastPos.Y = 0;
    end

    controller = figure('Units', 'normalize', 'MenuBar', 'none', 'ToolBar', 'none');
    set(controller, 'WindowButtonMotionFcn', @(h,~)mover(h));
    set(controller, 'WindowButtonDownFcn', @(h,~)Func(clicker(h)));
    set(controller, 'WindowKeyPressFcn', @(h,eventdata)Func(keypress(h,eventdata)));
    DrawGrid(controller);
    Func(LastPos);
    
    function Pos = mover(h)
        Pos.X = h.CurrentPoint(1);
        Pos.Y = h.CurrentPoint(2);
        DrawGrid(h, Pos);
    end

    function Pos = clicker(h)
        if strcmp(h.SelectionType, 'normal')
            Pos.X = h.CurrentPoint(1);
            Pos.Y = h.CurrentPoint(2);
            LastPos = Pos;
            DrawGrid(h, Pos);
        end
    end

    function Pos = keypress(h,eventdata)
        if strcmpi(eventdata.Key, 'rightarrow')
            LastPos.X = min(LastPos.X + 0.05, 1);
        end
        if strcmpi(eventdata.Key, 'leftarrow')
            LastPos.X = max(LastPos.X - 0.05, 0);
        end
        if strcmpi(eventdata.Key, 'uparrow')
            LastPos.Y = min(LastPos.Y + 0.05, 1);
        end
        if strcmpi(eventdata.Key, 'downarrow')
            LastPos.Y = max(LastPos.Y - 0.05, 0);
        end
        DrawGrid(h);
        Pos = LastPos;
    end

    function DrawGrid(fig, Pos)
        figure(fig);
        subplot('position',[0 0 1 1]);
        xlim([0 1]); ylim([0 1]);
        hold off;
        plot([1 1]*LastPos.X, [0 1], 'color', [0 0 0]);
        hold on;
        plot([0 1], [1 1]*LastPos.Y, 'color', [0 0 0]);
        grid on;
        if nargin == 2
            plot([0 1], [1 1]*Pos.Y, 'color', [0 0 0], 'LineStyle','--');
            plot([1 1]*Pos.X, [0 1], 'color', [0 0 0], 'LineStyle','--');
            legend(['X = ', num2str(Pos.X)], ['Y = ', num2str(Pos.Y)]);
        else
            legend(['X = ', num2str(LastPos.X)], ['Y = ', num2str(LastPos.Y)]);
        end
    end
end