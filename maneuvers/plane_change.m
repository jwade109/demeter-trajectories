function [orbit, dv] = plane_change(orbit, di)

if norm(orbit.v) < 1E-05
    error("Zero velocity cannot define retrograde direction");
end

old_vel = orbit.v;
dir = orbit.in_track*cos(di) + orbit.cross_track*sin(di);
mag = norm(orbit.v);

orbit = rv2orbit(orbit.r, dir*mag, orbit.primary_body, orbit.epoch);
dv = norm(orbit.v - old_vel);

end