clear;

% schedule associated with underlying impulsive trajectory
traj = struct;
traj.launch = datetime('07-July-2035');
traj.dep_tof = days(106);
traj.arrival = traj.launch + traj.dep_tof;
traj.stay = days(45);
traj.departure = traj.arrival + traj.stay;
traj.ret_tof = days(260);
traj.return = traj.departure + traj.ret_tof;

fprintf("Launch date: %s\nMars arrival: %s\n" + ...
        "Mars departure: %s\nEarth return: %s\n",...
        datestr(traj.launch),...
        datestr(traj.arrival),...
        datestr(traj.departure),...
        datestr(traj.return));

% burn times
% using 440 kW at Mars, 1 MW at Earth
burn = struct;
burn.leo_lopg = days(213);
burn.lmo_tei = days(151);
burn.tei_leo = days(81);

tolerance = days(7);
leo_lopg_end = traj.launch - tolerance;
leo_lopg_start = leo_lopg_end - burn.leo_lopg;

lmo_tei_start = traj.departure;
lmo_tei_end = lmo_tei_start + burn.lmo_tei;

tei_leo_end = traj.return;
tei_leo_start = tei_leo_end - burn.tei_leo;

fprintf("LEO-LOPG from %s to %s\n" + ...
        "LMO-TEI from %s to %s\n" + ...
        "TEI-LEO from %s to %s\n",...
        datestr(leo_lopg_start), datestr(leo_lopg_end),...
        datestr(lmo_tei_start), datestr(lmo_tei_end),...
        datestr(tei_leo_start), datestr(tei_leo_end));

