function orbit = propagate_to(orbit, time)

% if abs(orbit.e) < 1E-02
%     warning("Very circular orbit -- results unstable!");
% end

if norm(orbit.e) < 1
    orbit = propagate_to_elements(orbit, time);
else
    dt = seconds(time - orbit.epoch);
    f = @ (x) dt - xtof(x, orbit);
    x = fzero(f, orbit.x);
    [~, r, v] = xtof(x, orbit);
    orbit = rv2orbit(r, v, orbit.primary_body, time);
end

end

function [tof, r, v] = xtof(x, orbit)

if orbit.e < 1
    warning("Doesn't work for elliptical orbits, for some reason!");
end

r0 = orbit.r;
v0 = orbit.v;
a = orbit.a;
mu = orbit.mu;

z = x^2/a;
C = 1/2 - z/24 + z^2/720 - z^3/40320 + z^4/3628800;
S = 1/6 - z/120 + z^2/5040 - z^3/362880;

tof = (x^3*S + dot(r0, v0)/sqrt(mu)*x^2*C ...
    + norm(r0)*x*(1 - z*S))/sqrt(mu);

f = 1 - x^2/norm(r0)*C;
g = tof - x^3/sqrt(mu)*S;
r = f*r0 + g*v0;

gdot = 1 - x^2/norm(r)*C;
fdot = sqrt(mu)/dot(r, r0)*x*(z*S - 1);
v = fdot*r0 + gdot*v0;

end

function orbit = propagate_to_elements(orbit, time)

if orbit.e > 1
    warning("Doesn't work for hyperbolic orbits, for some reason!");
end

old_nu = orbit.nu;
dt = seconds(time - orbit.epoch);

M2 = orbit.mm*dt + orbit.M;
f = @ (E) M2 - E + orbit.e*sin(E);
E2 = fzero(f, M2);
nu2 = 2*atan(sqrt((1+orbit.e)/(1-orbit.e))*tan(E2/2));
if nu2 < 0
    nu2 = nu2 + 2*pi;
end

fprintf("old: %0.3f, new %0.3f\n", old_nu, nu2);

if dt == 0 && abs(old_nu - nu2) > 1E-9
    error("bad news bears");
end

new = elements2orbit(orbit.a, orbit.e, orbit.i, orbit.raan, ...
    orbit.argp, nu2, orbit.primary_body);
new.epoch = time;

if dt == 0 && norm(new.v - orbit.v) > 1E-2
    warning("Propagation of zero time caused change in orbit");
end

orbit = new;

end
