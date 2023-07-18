% the Gershberg-Saxton algorithm

if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end;
if exist('Iteration', 'var') ~= 1; Iteration = 1; end;
if exist('batch', 'var') ~= 1; batch = 16; end;
if exist('alghoritm', 'var') ~= 1; alghoritm = 1; end;


cycle = 64;
Target = zeros(N,N,ln);
for num=1:ln
    Target(:,:,num) = exp(-((X - coords(num,1)).^2 + (Y - coords(num,2)).^2)/(A/6)^2);
    Target(:,:,num) = Target(:,:,num)/sqrt(sum(sum(Target(:,:,num).^2)));
end
H = zeros(N,N,ln);
Accr = 0;
FullAccr = 0;

tic;
for ep=1:epoch
    randind = randperm(size(Train,3));
    randind = randind(1:P);
    for iter7=1:batch:P
        for iter8=1:Iteration
            Tmp = zeros(N);
            
            if alghoritm == 1 % Alghoritm GS part 1
                % Forward propagation
                for iter9=0:batch-1
                    for num=1:ln
                        W = resizeimage(Train(:,:,randind(iter7+iter9),num),N,AN);
                        W = propagation(W, z(1), k, U);
                        W = propagation(W.*DOES, z(2)-z(1), k, U);
                        Tmp = Tmp + W.*Target(:,:,num);
                        
                        % Check accuracy
                        if iter8 == Iteration
                            tmp = get_scores(W, MASK, true);
                            if tmp(num) == max(tmp)
                                Accr = Accr + 1;
                            end
                            FullAccr = FullAccr + 1;
                        end
                    end
                end
                psi = exp(1i*angle(Tmp));
                Tmp = zeros(N);

                % Backward propagation
                for num=1:ln
                    H(:,:,num) = propagation(Target(:,:,num).*psi, -(z(2)-z(1)), k, U);
                end
                 for iter9=0:batch-1
                    for num=1:ln
                        W = resizeimage(Train(:,:,randind(iter7+iter9),num),N,AN);
                        W = propagation(W, z(1), k, U);
                        Tmp = Tmp + H(:,:,num).*conj(W);
                    end
                 end
                DOES = exp(1i*angle(Tmp));
                
            elseif alghoritm == 2  % Alghoritm GS part 2
                for iter9=0:batch-1
                    for num=1:ln
                        % Forward propagation
                        W = resizeimage(Train(:,:,randind(iter7+iter9),num),N,AN);
                        W = propagation(W, z(1), k, U);
                        F = propagation(W.*DOES, z(2)-z(1), k, U);
                        
                        % Check accuracy
                        if iter8 == Iteration
                            tmp = get_scores(F, MASK, true);
                            if tmp(num) == max(tmp)
                                Accr = Accr + 1;
                            end
                            FullAccr = FullAccr + 1;
                        end
                        
                        % Backward propagation
                        F = Target(:,:,num).*exp(1i*angle(F));
                        F = propagation(F, -(z(2)-z(1)), k, U);
                        Tmp = Tmp + F.*conj(W);
                    end
                end
                DOES = exp(1i*angle(Tmp));
                
            else
                error(['Alghoritm "' num2str(alghoritm) '" is not exist']);
            end
            
        end
        
        % Display progress
        if mod(iter7+batch-1, cycle) == 0
            display(['iter = ' num2str(iter7+batch-1 + (ep-1)*P) '/' num2str(P*epoch) ...
                '; accuracy = ' num2str(Accr/FullAccr*100) '%; time = ' num2str(toc) ';']);
            FullAccr = 0;
            Accr = 0;
        end
    end
end

clearvars iter7 iter8 iter9 num Target H W F Tmp P Iteration batch cycle psi randind tmp Accr FullAccr;