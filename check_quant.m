
% quantization check

save = DOES;
quants = [2 4 8 16];
q_accr = zeros(1,length(quants));
q_minc = zeros(1,length(quants));


for iter = 1:length(quants)
    phi = angle(save) + pi;
    phi = floor(phi/2/pi*quants(iter))*2*pi/quants(iter);
    DOES = exp(1i*phi);
    disp(['quant = ' num2str(quants(iter))]);
    check_result;
    q_accr(iter) = accuracy;
    q_minc(iter) = min_contrast;
end

DOES = save;
quants(end+1) = inf;
check_result;
q_accr(end+1) = accuracy;
q_minc(end+1) = min_contrast;

clearvars phi save iter;