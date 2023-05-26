
P = 1;

% colormap in shades of Samara university
ssau = [linspace(1,  32/255, 50), linspace( 32/255, 0, 100); ...
		   linspace(1, 145/255, 50), linspace(145/255, 0, 100); ...
		   linspace(1, 201/255, 50), linspace(201/255, 0, 100)]';

% to draw squares
xx = [-1 -1 1 1 -1]*G_size/2;
yy = [1 -1 -1 1 1]*G_size/2;
       
fig = figure('position', [100 100 1000 500]);
for p=1:P
	for num=1:length(nums)
        % getting results
		W = resizeimage(Test(:,:,randi([1 TestData(num)]),num),N,AN);
%         W = W(end:-1:1, :);
        [tmp, F] = recognize(W,z,DOES,k,MASK,U,false);
%         tmp = exp(tmp);
        tmp = tmp./sum(tmp);

        % drawing images
        colormap(ssau);
		subplot(1, 2, 1, 'align', 'position', [0.02, 0.02, 0.47, 0.96]);
		imagesc([-A A], [-A A], abs(W(1+(N-AN)/2:(N+AN)/2, 1+(N-AN)/2:(N+AN)/2)));
        set(gca,'xtick',[],'ytick',[]);
        axis square;
        axis xy;
		subplot(1, 2, 2, 'align', 'position', [0.51, 0.02, 0.47, 0.96]);
		imagesc([-B B], [-B B], abs(F(:,:,end)).^2);
        set(gca,'xtick',[],'ytick',[]);
        axis square;
        axis xy;
        hold on;

        % drawing numbers and squares of focus areas
        for nt=1:length(nums)
            if tmp(nt) == max(tmp)
                text(coords(nt, 1)-A*4*0.4, coords(nt, 2)-A*4*0.3, sprintf('%.2f%%', tmp(nt)*100), 'fontsize', 14, 'color', [1, 0, 0]);
            else
                text(coords(nt, 1)-A*4*0.4, coords(nt, 2)-A*4*0.3, sprintf('%.2f%%', tmp(nt)*100), 'fontsize', 14);
            end
            if nt == num
                plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [1 0 0]);
            else
                plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [0 0 0]);
            end
        end

		pause(1);
	end
end
close(fig);

clearvars fig nt p P num F W tmp ssau doe xx yy;
