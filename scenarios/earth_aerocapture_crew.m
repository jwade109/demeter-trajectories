clear;
clc;
close all;

solution = earth_to_mars();
mars_earth_braking_dv = solution.dv4;
luna = luna();
max_aerocapture_dv = 4000;
aerocap_highest_apoapsis = luna.orbit.a/2;
acc = 50/(50*1000);
dt = minutes(9.9);

circular = earth_parking(300);
R = circular.primary_body.radius;
r = R + 600*1000;

impulsive = prograde(circular, mars_earth_braking_dv);
acceptable = prograde(circular, max_aerocapture_dv);

braking = continuous_escape( ...
    acceptable, impulsive.vinf, dt, seconds(dt)*acc);
braking = invert_trajectory(braking);

[maneuvers, dv, tof] = aerocapture( ...
    braking.final, max_aerocapture_dv, aerocap_highest_apoapsis, r, r);

disp(dv);
disp(tof);

eci(impulsive, luna.orbit, maneuvers{:});