function [f, g, df, dg] = lagrangeCoefficients(r0, r, dF, dt, a, mu)

f = 1 - a/r0*(1 - cosh(dF));
g = dt - sqrt(-a^3/mu)*(sinh(dF) - dF);
df = -sqrt(-mu*a)*sinh(dF)/(r*r0);
dg = 1 - a/r*(1 - cosh(dF));

if abs(f*dg - df*g) - 1 > 1e-8
    fprintf('(f*dg - df*g == %f)\n', f*dg - df*g);
end

end