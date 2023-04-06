clear;
clc;
close all;

luna = luna();

parking = earth_parking(300);
R = parking.primary_body.radius;
r = R + 600*1000;
impulsive = prograde(parking, 4300);

[maneuvers, dv, tof] = aerocapture(impulsive, 3000, luna.orbit.a, r, r);

disp(dv);
disp(tof);

eci(luna.orbit);

animate(500, maneuvers{2:end});