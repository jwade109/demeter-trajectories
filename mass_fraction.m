function mf = mass_fraction(isp, dv)

g = 9.81;
mf = exp(dv/(isp*g));

end