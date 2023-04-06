clear;
clc;
close all;

phobos = phobos();
deimos = deimos();
eci(phobos, deimos);

% mars entrance

dt = minutes(20);
acc = seconds(dt)*50/(70*1000);

interplanetary = earth_to_mars();

entrance_epoch = interplanetary.t2.epoch;
circular = mars_parking(150);
circular.epoch = entrance_epoch;
hyperbolic_entry = prograde(circular, interplanetary.dv2); % source - opposition

[maneuvers, aero_dv, tof] = aerocapture(hyperbolic_entry, ...
    4000, phobos.orbit.primary_body.soi/5, ...
    phobos.orbit.ra*1.7, phobos.orbit.primary_body.radius + 400e+03);

parking = maneuvers{end};

hyperbolic_exit = prograde(circular, interplanetary.dv3);

parking = propagate_to_nu(parking, 0);
[kick, mav_dv] = prograde(parking, 600);

exit_traj = continuous_escape( ...
    kick, hyperbolic_exit.vinf, dt, acc);

% plot

eci(phobos.orbit, deimos.orbit, exit_traj.final);
animate(60, maneuvers{:}, parking, kick, exit_traj);

fprintf("MAV dv: %0.1f\n", mav_dv);
fprintf("Aerocapture raise dv: %f\n", aero_dv(end));
fprintf("SEP dv: %0.1f, %0.1f\n", entry_traj.dv, exit_traj.dv);