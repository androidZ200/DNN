function TrackControl(Func, action)
    controller = figure('Units', 'normalize', 'MenuBar', 'none', 'ToolBar', 'none');
    set(controller, action, @(h,~)Func(mover(h)));
    ndisp();
    
    function Pos = mover(h)
        Pos.X = h.CurrentPoint(1);
        Pos.Y = h.CurrentPoint(2);
    
        subplot('position',[0 0 1 1]);
        xlim([0 1]); ylim([0 1]);
        hold off;
        plot([0 1], [1 1]*Pos.Y, 'color', [0 0 0]);
        hold on;
        plot([1 1]*Pos.X, [0 1], 'color', [0 0 0]);
        grid on;
        legend(['X = ', num2str(Pos.X)], ['Y = ', num2str(Pos.Y)]);
    end
end