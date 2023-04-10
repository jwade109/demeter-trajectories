function [new_orbit, dv] = circularize(orbit)

o2 = propagate_to_nu(orbit, pi, 1);

old_vel = o2.v;
a = norm(o2.r);
vel = sqrt(o2.mu*(2/a - 1/a));

new_orbit = rv2orbit(o2.r, o2.in_track*vel, ...
    o2.primary_body, o2.epoch);
dv = norm(new_orbit.v - old_vel);
new_orbit.label = "circularized";

end