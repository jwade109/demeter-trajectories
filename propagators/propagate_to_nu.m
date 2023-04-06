function orbit = propagate_to_nu(orbit, nu2, dir)

if nargin < 3
    dir = 1;
end

if nu2 < 0
    error("nu must be positive or zero");
end

if dir ~= 1 && dir ~= -1
    error("dir must be 1 or -1");
end

e = orbit.e;
M2 = nu2 - 2*e*sin(nu2) + (3/4*e^2 + e^4/8)*sin(2*nu2) - ...
     e^3/3*sin(3*nu2) + 5/32*e^4*sin(4*nu2);
 
dM = dir*abs(M2 - orbit.M);
dt = seconds(dM/orbit.mm);

if seconds(dt) < 0
    warning("Propagating backwards in time")
end

epoch = orbit.epoch + dt;
orbit = elements2orbit(orbit.a, orbit.e, orbit.i, ...
    orbit.raan, orbit.argp, nu2, orbit.primary_body);
orbit.epoch = epoch;

end