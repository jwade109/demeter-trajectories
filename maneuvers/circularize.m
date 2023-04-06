function [orbit, dv] = circularize(orbit)

old_vel = orbit.v;
a = norm(orbit.r);
vel = sqrt(orbit.mu*(2/a - 1/a));

orbit = rv2orbit(orbit.r, orbit.in_track*vel, ...
    orbit.primary_body, orbit.epoch);
dv = norm(orbit.v - old_vel);

end