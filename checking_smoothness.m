function diff = checking_smoothness (DOES)
    SX = angle(DOES(:,1:end-1))-angle(DOES(:,2:end));
    SY = angle(DOES(1:end-1,:))-angle(DOES(2:end,:));
    diff = abs([SX(:); SY(:)]);
    rev = diff > pi;
    diff(rev) = 2*pi - diff(rev);
    figure; hist(diff,100);
end