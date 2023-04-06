clear;
clc;
close all;

luna = luna();
parking = earth_parking();
impulsive = prograde(parking, 3700);

dt = minutes(15);
acc = 200/(200*1000)*seconds(dt);

spiral = continuous_rendezvous(parking,...
    luna.orbit, days(300), dt, acc);
mav_kick = propagate_to(spiral.final, spiral.final.epoch + days(14));
mav_kick = prograde(mav_kick, 2365*0.7);
crew = continuous_escape(mav_kick, impulsive.vinf, dt, acc);

orion = propagate_to_nu(parking, 3*pi/2*0.95);
[orion, dv] = change_apoapsis(orion, spiral.final.a*1.001);
orion = propagate_to_nu(orion, pi);

copy = spiral.final;
copy.stop = copy.epoch + days(14);

eci2({spiral, spiral.final, crew, copy, orion},...
    {'y-', 'w--', 'y-', 'y-', 'w-'}, ...
    {'r.', 'r.', 'r.', 'r.', 'r.'});