
P = 1;

% colormap in shades of Samara university
ssau = [linspace(1,  32/255, 50), linspace( 32/255, 0, 100); ...
		   linspace(1, 145/255, 50), linspace(145/255, 0, 100); ...
		   linspace(1, 201/255, 50), linspace(201/255, 0, 100)]';

% to draw squares
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;
       
fig = figure('position', [100 100 1000 500]);
for p=1:P
	for num=1:ln
        % getting results
        ind = find(TestLabel == num);
        nt = randi([1,length(ind)]);
        W = Test(:,:,ind(nt));
        [tmp, F] = recognize(GetImage(W),Propagations,DOES,MASK,is_max);
        tmp = tmp(1:ln);
        tmp = tmp./sum(tmp);

        % drawing images
        colormap(ssau);
		subplot(1, 2, 1, 'align', 'position', [0.02, 0.02, 0.47, 0.96]);
		imagesc(abs(W));
        set(gca,'xtick',[],'ytick',[]);
        axis square;
		subplot(1, 2, 2, 'align', 'position', [0.51, 0.02, 0.47, 0.96]);
        zoom = 1;
		imagesc([-B B]/zoom, [-B B]/zoom, abs(F(floor(N/2-N/2/zoom+1:N/2+N/2/zoom),...
            floor(N/2-N/2/zoom+1:N/2+N/2/zoom),end)).^2);
        set(gca,'xtick',[],'ytick',[]);
        axis square;
        hold on;

        % drawing numbers and squares of focus areas
        for nt=1:ln
            if tmp(nt) == max(tmp)
                text(coords(nt, 1), coords(nt, 2)-G_size_y/2-0.1, sprintf('%.2f%%', tmp(nt)*100), ...
                    'fontsize', 14, 'color', [1, 0, 0], 'HorizontalAlignment', 'center');
            else
                text(coords(nt, 1), coords(nt, 2)-G_size_y/2-0.1, sprintf('%.2f%%', tmp(nt)*100), ...
                    'fontsize', 14, 'HorizontalAlignment', 'center');
            end
            if nt == num
                plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [1 0 0]);
            else
                plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [0 0 0]);
            end
        end

		pause(2);
%         saveas(gca, ['im_' num2str((p-1)*ln+num) '.png']);
	end
end
close(fig);

clearvars fig nt p P num F W tmp ssau doe xx yy ind zoom;
