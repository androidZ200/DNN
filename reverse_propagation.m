function [ Fields ] = reverse_propagation( Fields, Propagations, DOES )
    Fields(:,:,end,:) = Propagations{end}(Fields(:,:,end,:));
    for iter=size(Fields,3)-1:-1:1
        Fields(:,:,iter,:) = Propagations{iter}(Fields(:,:,iter+1,:)./DOES(:,:,iter+1));
    end
end

