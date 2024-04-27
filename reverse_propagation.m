function [ Fields ] = reverse_propagation( Fields, Propagations, DOES )
    for iter=size(Fields,3)-1:-1:1
        Fields(:,:,iter,:) = Propagations{iter}(Fields(:,:,iter+1,:)).*DOES(:,:,iter);
    end
end

