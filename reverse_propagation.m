function [ Fields ] = reverse_propagation( End_Field, Propagations, DOES )
    N = size(End_Field,1);
    Fields = zeros(N,N,length(Propagations),size(End_Field,4));
    Fields(:,:,end,:) = Propagations{end}(End_Field);
    for iter=size(Fields,3)-1:-1:1
        Fields(:,:,iter,:) = Propagations{iter}(Fields(:,:,iter+1,:)./DOES(:,:,iter+1));
    end
end

