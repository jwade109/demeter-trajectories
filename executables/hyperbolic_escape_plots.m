
e = earth_body()
r = 6378*1000 + 400*1000;
vcirc = sqrt(e.mu/r);
orbit = rv2orbit([r, 0, 0], [0, vcirc, 0], e, 0);
disp(orbit);
excess_vel = linspace(0, 10000, 100)'*1000;

req = dvreq(excess_vel, orbit);

plot(excess_vel/1000, (excess_vel - req)/1000);
grid on;
