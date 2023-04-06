function [orbit, dv] = prograde(orbit, dv)

if norm(orbit.v) < 1E-05
    error("Zero velocity cannot define prograde direction");
end

old_vel = orbit.v;
dir = orbit.v/norm(orbit.v);
mag = norm(orbit.v) + dv;

orbit = rv2orbit(orbit.r, dir*mag, orbit.primary_body, orbit.epoch);
dv = norm(orbit.v - old_vel);

end