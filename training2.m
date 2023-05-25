
if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end;
if exist('Iteration', 'var') ~= 1; Iteration = 1; end;
if exist('batch', 'var') ~= 1; batch = 16; end;


cycle = 64;
Target = zeros(N,N,ln);
for num=1:ln
    Target(:,:,num) = exp(-((X - coords(num,1)).^2 + (Y - coords(num,2)).^2)*(4/A)^2);
    Target(:,:,num) = Target(:,:,num)/sqrt(sum(sum(Target(:,:,num).^2)));
end
H = zeros(N,N,ln);

tic;
for ep=1:epoch
    randind = randperm(size(Train,3));
    randind = randind(1:P);
    for iter7=1:batch:P
        for iter8=1:Iteration
            Tmp = zeros(N);
            
            % Forward propagation
            for iter9=0:batch-1
                for num=1:ln
                    W = resizeimage(Train(:,:,randind(iter7+iter9),num),N,AN);
                    W = propagation(W, z(1), k, U);
                    W = propagation(W.*DOES, z(2)-z(1), k, U);
                    Tmp = Tmp + W.*Target(:,:,num);
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
        end
        
        % Display progress
        if mod(iter7+batch-1, cycle) == 0
            display(['iter = ' num2str(iter7+batch-1 + (ep-1)*P) '/' num2str(P*epoch) '; time = ' num2str(toc) ';']);
        end
    end
end

clearvars iter7 iter8 iter9 num Target H W Tmp P Iteration batch cycle psi randind;