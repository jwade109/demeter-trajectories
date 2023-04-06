function [t, vd, va] = ztof(z, r1, r2, mu, dir)

dnu = acos(dot(r1, r2)/(norm(r1)*norm(r2)));

A = dir*sqrt(norm(r1)*norm(r2))*sin(dnu)/sqrt(1-cos(dnu));

C = (1 - cos(sqrt(z)))/z;
S = (sqrt(z) - sin(sqrt(z)))./sqrt(z.^3);

y = norm(r1) + norm(r2) - A.*(1 - z.*S)./sqrt(C);
x = sqrt(y./C);

t = (x.^3 .* S + A.*sqrt(y))./sqrt(mu);

f = 1 - y./norm(r1);
g = A.*sqrt(y./mu);
gdot = 1 - y/norm(r2);
vd = (r2 - f.*r1)./g;
va = (gdot.*r2 - r1)./g;

end
