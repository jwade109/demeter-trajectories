function acc = gacc(loc, positions, masses)

displacement = positions - loc;
G = 6.67408E-11;

acc = [0, 0, 0];

for i = 1:size(positions, 1)
    r = displacement(i,:);
    m = masses(i);
    rnorm = norm(r);
    rhat = r/rnorm;
    ag = G*m/rnorm^2*rhat;
    acc = acc + ag;
end

end