
if ~exist('Size', 'var'); Size = 6; end
if ~exist('delay', 'var'); delay = 0.2; end

% colormap in shades of Samara university
ssau = [linspace(1,  32/255, 50), linspace( 32/255, 0, 100); ...
		linspace(1, 145/255, 50), linspace(145/255, 0, 100); ...
		linspace(1, 201/255, 50), linspace(201/255, 0, 100)]';
% to draw squares
xx = [-1 -1 1 1 -1]*G_size_x/2;
yy = [1 -1 -1 1 1]*G_size_y/2;
F = zeros(N,N,length(Propagations)+1);
GPU_CPU;
       
fig = figure('position', [100 100 1500 400]);
for num=1:ln
    for iter10=1:Size
        % getting results
        ind = find(TestLabel == num);
        nt = randi([1,length(ind)]);
        W = Test(:,:,ind(nt));
        
        F(:,:,1) = GetImage(W);
        for iter11=1:size(F,3)-1
            F(:,:,iter11+1) = Propagations{iter11}(F(:,:,iter11).*DOES(:,:,iter11));
        end
        tmp = get_scores(F(:,:,end),MASK,is_max);
        tmp = tmp(1:ln);
        tmp = tmp./sum(tmp);

        % drawing images
        colormap(ssau);
		subplot(1, 3, 1);
		imagesc(abs(W));
        set(gca,'xtick',[],'ytick',[]);
        axis square;
		subplot(1, 3, 2);
		imagesc([-B B], [-B B], abs(F(:,:,end)).^2);
        C = max(max(abs(coords)));
        xlim([-C C]*1.5); ylim([-C C]*1.5);
        set(gca,'xtick',[],'ytick',[]);
        axis square;
        hold on;

        % drawing numbers and squares of focus areas
        for nt=1:ln
            if nt == num
                plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [201 88 32]/255);
            else
                plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [0 0 0]);
            end
        end
        
        % drawing bar of scores
        subplot(1, 3, 3);
        bar(0:ln-1, tmp*100,'FaceColor',[32 145 201]/255,'EdgeAlpha',0);
        ylim([0 60]);
        
		pause(delay);
        if ~ishandle(fig); return; end
%         saveas(gca, ['im_' num2str((p-1)*ln+num) '.png']);
    end
end
close(fig);

clearvars fig nt iter10 iter11 Size num F W tmp ssau xx yy ind C delay;
