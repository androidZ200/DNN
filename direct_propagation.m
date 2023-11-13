function [ Fields ] = direct_propagation( First_Field, Propogations, DOES )
    N = size(First_Field,1);
    Fields = zeros(N,N,length(Propogations)+1);
    Fields(:,:,1) = First_Field;
    for iter=1:size(Fields,3)-1
        Fields(:,:,iter+1) = Propogations{iter}(Fields(:,:,iter).*DOES(:,:,iter));
    end
end

