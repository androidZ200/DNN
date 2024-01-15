function [ Fields ] = reverse_propagation( End_Field, Propogations, DOES )
    N = size(End_Field,1);
    Fields = gpuArray(zeros(N,N,length(Propogations)));
    Fields(:,:,end) = Propogations{end}(End_Field);
    for iter=size(Fields,3)-1:-1:1
        Fields(:,:,iter) = Propogations{iter}(Fields(:,:,iter+1).*DOES(:,:,iter+1));
    end
end

