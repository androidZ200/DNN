function [ Fields ] = direct_propagation( First_Field, Propogations, DOES )
    N = size(First_Field,1);
    Fields = gpuArray(zeros(N,N,length(Propogations)+1,size(First_Field,3),'single'));
    Fields(:,:,1,:) = First_Field;
    for iter=1:size(Fields,3)-1
        Fields(:,:,iter+1,:) = Propogations{iter}(Fields(:,:,iter,:).*DOES(:,:,iter));
    end
end

