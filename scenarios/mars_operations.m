clear;
clc;
close all;

phobos = phobos_body();
deimos = deimos_body();
eci(phobos, deimos);

% mars entrance

dt = minutes(20);
acc1 = seconds(dt)*50/(120*1000);
acc2 = seconds(dt)*50/(70*1000);

interplanetary = earth_to_mars();

entrance_epoch = interplanetary.t2.epoch;
circular = mars_parking(150);
circular.epoch = entrance_epoch;
hyperbolic_entry = prograde(circular, interplanetary.dv2); % source - opposition

[maneuvers, aero_dv, tof] = aerocapture(hyperbolic_entry, ...
    4000, phobos.orbit.primary_body.soi/10, ...
    phobos.orbit.ra*1.7, phobos.orbit.primary_body.radius + 400e+03);

final = maneuvers{end};
entry_traj = continuous_rendezvous( ...
    final, phobos.orbit, days(50), dt, acc1);
entry_traj.final.stop = entry_traj.final.epoch;

phobos.orbit.epoch = circular.epoch + phobos.orbit.T/2;
phobos.orbit.stop = entry_traj.final.stop;
parking_orbit = entry_traj.final;

exit_epoch = entry_traj.final.stop;
parking_orbit.stop = exit_epoch;

spacecraft = propagate_to(entry_traj.final, exit_epoch);
hyperbolic_exit = prograde(circular, interplanetary.dv3);
[spacecraft, mav_dv] = prograde(spacecraft, 1000);

exit_traj = continuous_escape( ...
    spacecraft, hyperbolic_exit.vinf, dt, acc2);

% plot

eci(phobos.orbit, deimos.orbit, exit_traj.final);
% animate(40, maneuvers{:}, parking_orbit, entry_traj, exit_traj);

fprintf("MAV dv: %0.1f\n", mav_dv);
fprintf("Aerocapture raise dv: %f\n", aero_dv(end));
fprintf("SEP dv: %0.1f, %0.1f\n", entry_traj.dv, exit_traj.dv);