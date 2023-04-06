function [dv1, dv2, tof] = hohmann(r1, r2, primary_body)

m = mu(primary_body);

dv1 = sqrt(m/r1)*(sqrt(2*r2/(r1+r2)) - 1);
dv2 = sqrt(m/r2)*(1 - sqrt(2*r1/(r1+r2)));
tof = pi*sqrt((r1+r2)^3/(8*m));

end