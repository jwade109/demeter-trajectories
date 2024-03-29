clear;
clc;
close all;

%% orbit definitions

sol = sol_body();
earth = earth_body();
earth_parking = parking_orbit(earth, km(500));
mars = mars_body();
mars_parking = parking_orbit(mars, km(500));

%% comb the desert

global_min = Inf;
epoch = datetime('01-jan-2020');
reentry_limit = 5000;

for launch_date = datetime('27-Apr-2033')

e1 = propagate_to(earth, launch_date);

for dtof = days(250:10:320)

m2 = propagate_to(mars, launch_date + dtof);

for stay = days(450:25:550)

m3 = propagate_to(mars, launch_date + dtof + stay);

for rtof = days(250:10:320)

e4 = propagate_to(earth, launch_date + dtof + stay + rtof);

[v1, ~, v2, ~] = intercept2(e1.r, m2.r, dtof, sol.mu);
[v3, ~, v4, ~] = intercept2(m3.r, e4.r, rtof, sol.mu);

if sum(isnan(v1)) || sum(isnan(v2)) || sum(isnan(v3)) || sum(isnan(v4))
    warning("NaN detected!");
end

if norm(v1 - e1.v) < norm(v2 - e1.v)
    t1 = rv2orbit(e1.r, v1, sol, e1.epoch);
else
    t1 = rv2orbit(e1.r, v2, sol, e1.epoch);
end

if norm(v3 - m3.v) < norm(v4 - m3.v)
    t3 = rv2orbit(m3.r, v3, sol, m3.epoch);
else
    t3 = rv2orbit(m3.r, v4, sol, m3.epoch);
end

if strcmp(t1.class, 'hyperbolic') || strcmp(t3.class, 'hyperbolic')
    warning("Hyperbolic!");
    continue;
end

t2 = propagate_to(t1, m2.epoch);
t4 = propagate_to(t3, e4.epoch);

t1.stop = t2.epoch;
t3.stop = t4.epoch;

dv1 = dvreq(norm(t1.v - e1.v), earth_parking);
dv2 = max(dvreq(norm(t2.v - m2.v), mars_parking) - reentry_limit, 0);
dv3 = dvreq(norm(t3.v - m3.v), mars_parking);
dv4 = max(dvreq(norm(t4.v - e4.v), earth_parking) - reentry_limit, 0);
dv = dv1 + dv2 + dv3 + dv4;
minimize = dv;

fprintf("%s D %0.1f, S %0.1f, R %0.1f = " +...
    "%0.1f km/s\n",...
    datestr(launch_date),...
    days(dtof),...
    days(stay),...
    days(rtof),...
    dv/1000);

if minimize < global_min
    global_min = minimize;
    optimal = struct;
    optimal.dv = dv;
    optimal.e1 = e1;
    optimal.m2 = m2;
    optimal.m3 = m3;
    optimal.e4 = e4;
    optimal.t1 = t1;
    optimal.t2 = t2;
    optimal.t3 = t3;
    optimal.t4 = t4;
    optimal.time = launch_date;
    optimal.dtof = dtof;
    optimal.rtof = rtof;
    optimal.stay = stay;
end

end

end

end

end

%%

fprintf(">> %s D %0.1f, S %0.1f, R %0.1f = " +...
    "%0.1f kmps, %0.1f days\n",...
    datestr(optimal.time),...
    days(optimal.dtof),...
    days(optimal.stay),...
    days(optimal.rtof),...
    optimal.dv/1000);

animate({optimal.e1, optimal.m2, optimal.t1, optimal.m2, optimal.t3},...
    [[optimal.e1.epoch, optimal.t4.epoch];...
    [optimal.e1.epoch, optimal.t4.epoch];...
    [optimal.t1.epoch, optimal.t2.epoch];
    [optimal.m2.epoch, optimal.m3.epoch];...
    [optimal.t3.epoch, optimal.t4.epoch]],...
    {'', '', 'blue', 'red', 'green'});
