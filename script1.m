clear all;
init;

doe_plane = [0 0.2 0.4]/metric;
output_plane = [0.6 0.6]/metric;
DOES = ones(N,N,length(doe_plane));

INPUT(:,:,1) = exp(-((X-A/8).^2 + Y.^2)/(A/4)^2).*exp( 1i*128*X/A);
INPUT(:,:,2) = exp(-((X+A/8).^2 + Y.^2)/(A/4)^2).*exp(-1i*128*X/A);

OUTPUT = zeros(N,N,2);
OUTPUT(:,:,1) = ((X.^2 + Y.^2) < (A/4)^2).*((X.^2 + Y.^2) > (A/5)^2);
OUTPUT(:,:,2) = (max(abs(X), abs(Y)) < A/4).*(max(abs(X), abs(Y)) > A/5);

for iter=1:length(output_plane)
    INPUT(:,:,iter) = INPUT(:,:,iter)/sqrt(sum(sum(abs(INPUT(:,:,iter)).^2)));
    OUTPUT(:,:,iter) = OUTPUT(:,:,iter)/sqrt(sum(sum(abs(OUTPUT(:,:,iter)).^2)));
end

iteration = 1024*2;
speed = 1e0;
speeddown = 0.999;
training;
check_result;