function orbit = elements2orbit(a, e, i, raan, argp, nu, primary)

clear pi

mu = primary.mu;

ROT = pqw2ijk(raan, i, argp);
p = a*(1 - norm(e)^2);
h = ROT*[0; 0; sqrt(p/mu)];
r = p./(1 + norm(e)*cos(nu));

r = ROT*[r*cos(nu); r*sin(nu); 0];

v = sqrt(mu*(2/norm(r) - 1/a));
phi = acos((1 + norm(e)*cos(nu))/sqrt(1 + norm(e)^2 + 2*norm(e)*cos(nu)));
if nu > pi
    phi = -phi;
end
t = r/norm(r);
s = cross(h, t)/norm(h);
v = v*(sin(phi)*t + cos(phi)*s);

orbit = rv2orbit(r, v, primary, now());

fprintf("argp provided: %0.3f computed: %0.3f\n", argp, orbit.argp);

end

% check(a, orbit.a);
% check(e, orbit.e);
% check(i, orbit.i);
% check(raan, orbit.raan);
% check(argp, orbit.argp);
% check(nu, orbit.nu);

% function check(true, test)
% 
% if norm(true - test) > 1E-3
%     warning("bad!");
%     warning("bad!");
% end
