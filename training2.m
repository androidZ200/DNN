% non-gradient learning method

if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end
if exist('batch', 'var') ~= 1; batch = 1; end
if exist('LossFunc', 'var') ~= 1; LossFunc = 'SCE'; end
if exist('IntensityFactor', 'var') ~= 1; IntensityFactor = 2; end


Accr = 0;
cycle = 64;
lz = length(z)-1;
f = z(2:end)-z(1:end-1);
randind = randperm(size(Train,3));
randind = randind(1:P);
accr_graph(1) = nan;

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
        min_phase = zeros(N,N,lz);
        min_intensity = zeros(N,N,lz);
        for iter8=0:batch*ln-1 % parfor
            num = mod(iter8, ln)+1;

            % direct propagation
            W = resizeimage(Train(:,:,randind(iter7-floor(iter8/ln)),num),N,AN);
            [me, W, mi] = recognize(W,z,DOES,k,MASK,U,true);

            if max(me) == me(num)
                Accr = Accr + 1;
            else
                % training
                F = zeros(N);
                switch LossFunc
                    case 'Gauss' % the integral Gaussian function
                        F = conj(W(:,:,end)).*(abs(W(:,:,end)).^2 - Target(:,:,num));
                    case 'MSE' % standard deviation
                        me(num) = me(num) - 1;
                        for num2=1:ln
                            F = F + conj(W(:,:,end))*me(num2).*mi(:,:,num2);
                        end
                    case 'SCE' % cross entropy
                        me = exp(me*5e3);
                        for num2=1:ln
                            F = F + conj(W(:,:,end))*me(num2).*mi(:,:,num2);
                        end
                        F = F - conj(W(:,:,end))*sum(me).*mi(:,:,num);
                    otherwise
                        error(['Loss function "' name '" is not exist']);
                end
                tmp_phase = zeros(N,N,lz);
                tmp_intensity = zeros(N,N,lz);
                for iter9=0:lz-1
                    F = propagation(F, f(end-iter9), k, U);
                    tmp_intensity(:,:,end-iter9) = abs(W(:,:,end-iter9-1)).^IntensityFactor;
                    tmp_phase(:,:,end-iter9) = -angle(W(:,:,end-iter9-1).*F);
                    F = F.*DOES(:,:,end-iter9);
                end
                min_phase = min_phase + tmp_phase.*tmp_intensity;
                min_intensity = min_intensity + tmp_intensity;
            end
        end
    
        % updating weights
        min_phase = min_phase./min_intensity;
        min_phase(isnan(min_phase))=0;
        DOES = exp(1i*min_phase);

        % data output to the console
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

clearvars num num2 iter7 iter8 iter9 ep epoch P me mi W F argmax Accr cycle f Target ...
    randind min_phase batch LossFunc lz tmp_intensity tmp_phase IntensityFactor;
