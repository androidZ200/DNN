function [ Fields ] = direct_propagation( Fields, Propogations, DOES )
    for iter=1:size(Fields,3)-1
        Fields(:,:,iter+1,:) = Propogations{iter}(Fields(:,:,iter,:).*DOES(:,:,iter));
    end
end

