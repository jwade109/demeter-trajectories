function [orbit, dv] = change_periapsis(orbit, radius)

if abs(norm(orbit.r) - orbit.ra) > 1E-05
    warning("Changing apsis while not at opposite apsis violates assumptions");
end

old_vel = orbit.v;
a = (orbit.ra + radius)/2;
vel = sqrt(orbit.mu*(2/norm(orbit.r) - 1/a));

orbit = rv2orbit(orbit.r, orbit.in_track*vel, ...
    orbit.primary_body, orbit.epoch);
dv = norm(orbit.v - old_vel);

end