clear;

earth = earth_body();
moon = moon();

craft = spacecraft('MS3 ITV', [-7000000, 0, 0], [0, -10300, 0]);
mission_epoch = datetime(2019, 11, 24, 0, 0, 0);
mission_end = mission_epoch + days(2);

sys = orbsys(mission_epoch, earth, [], craft, maneuvers);
[sim, iters] = orbsim(sys, mission_end);
drawsim(sim);