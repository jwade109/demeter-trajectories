function orbit = gibb2orbit(r1, r2, r3, mu)

D = cross(r1, r2) + cross(r2, r3) + cross(r3, r1);
N = norm(r3).*cross(r1, r2) + ...
    norm(r1).*cross(r2, r3) + ...
    norm(r2).*cross(r3, r1);
S = (norm(r2) - norm(r3)).*r1 + ...
    (norm(r3) - norm(r1)).*r2 + ...
    (norm(r1) - norm(r2)).*r3;

B = cross(D, r1);
L = sqrt(mu./(norm(D)*norm(N)));
v1 = L.*B./norm(r1) + L.*S;

orbit = rv2orbit(r1, v1, mu);

end