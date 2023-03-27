
if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end
if exist('speed', 'var') ~= 1; speed = 1e-1; end
if exist('slowdown', 'var') ~= 1; slowdown = 0.9996; end
if exist('batch', 'var') ~= 1; batch = 1; end
if exist('LossFunc', 'var') ~= 1; LossFunc = 'SCE'; end
if exist('method', 'var') ~= 1; method = 'default'; end
if exist('params', 'var') ~= 1; params = []; end


Accr = 0;
cycle = 64;
lz = length(z)-1;
f = z(2:end)-z(1:end-1);
randind = randperm(size(Train,3));
randind = randind(1:P);
accr_graph(1) = nan;
tmp_data = zeros(N,N,lz);

if strcmp(LossFunc, 'Gauss')
    Target = zeros(N,N,ln);
    for num=1:ln
        Target(:,:,num) = exp(-((X - coords(num,1)).^2 + (Y - coords(num,2)).^2)*(4/A)^2);
        Target(:,:,num) = Target(:,:,num)/sqrt(sum(sum(Target(:,:,num).^2)));
    end
end

tic;
for ep=1:epoch
    for iter7=batch:batch:P
        gradient = zeros(N,N,lz);
        for iter8=0:batch*ln-1 % parfor
            num = mod(iter8, ln)+1;

            % прямое распространение
            W = resizeimage(Train(:,:,randind(iter7-floor(iter8/ln)),num),N,AN);
            [me, W, mi] = recognize(X,Y,W,z,DOES,k,coords,G_size,U);

            % получение оценок
            for num2=1:ln
                [me(num2), mi(num2, 1:2)] = get_max_intensity(X, Y, W(:,:,end), coords(num2, 1), coords(num2, 2), G_size);
            end
            [~, argmax] = max(me);

            if argmax == num
                Accr = Accr + 1;
            else
                % обучение
                F = zeros(N);
                switch LossFunc
                    case 'Gauss' % Целевая гауссова функция
                        % Гаусс
                        F = conj(W(:,:,end)).*(abs(W(:,:,end)).^2 - Target(:,:,num));
                    case 'MSE' % Среднеквадратичное отклонение
                        me(num) = me(num) - 1;
                        for num2=1:ln
                            F(mi(num2,1),mi(num2,2)) = conj(W(mi(num2,1),mi(num2,2),end))*me(num2);
                        end
                    case 'SCE' % Кросс энтропия
                        me = exp(me*5e3);
                        for num2=1:ln
                            F(mi(num2,1),mi(num2,2)) = conj(W(mi(num2,1),mi(num2,2),end))*me(num2);
                        end
                        F(mi(num,1),mi(num,2)) = F(mi(num,1),mi(num,2)) - conj(W(mi(num,1),mi(num,2),end))*sum(me);
                    otherwise
                        error(['Loss function "' name '" is not exist']);
                end
                T = zeros(N,N,lz);
                for iter9=0:lz-1
                    F = propagation(F, f(end-iter9), k, U).*DOES(:,:,end-iter9);
                    T(:,:,end-iter9) = -imag(W(:,:,end-iter9-1).*F);
                end
                gradient = gradient + T;
            end
        end
    
        % обновляем веса
        norma = max(max(max(abs(gradient))));
        if norma > 0
            gradient = gradient / norma;
        end
        [gradient, tmp_data] = criteria(gradient, tmp_data, method, [params, iter7+P*(ep-1)]);
        DOES = DOES./exp(1i*speed*gradient);
        speed = speed*slowdown;

        % вывод данных в консоль
        if mod(iter7, cycle) == 0
            Accr = Accr/cycle/ln*100;
            accr_graph(end+1) = Accr;
            display(['epoch = ' num2str(ep) '; iter = ' num2str(iter7) '/' num2str(P) ...
                 '; accr = ' num2str(accr_graph(end)) '%; time = ' num2str(toc) ';']);
            Accr = 0;
        end
    end
    DOES = exp(1i*angle(DOES));
%     save('DOE.mat', 'DOES', 'z');
end

% plot(accr_graph);
% ylim([0 100]);
% grid on;

clearvars num num2 iter7 iter8 iter9 ep epoch P speed me mi W F T argmax Accr cycle f Target ...
    randind gradient batch method params LossFunc slowdown lz tmp_data norma;
