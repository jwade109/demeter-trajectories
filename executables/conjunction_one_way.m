clear;
clc;
close all;

%% orbit definitions

earth = earth_body();
mars = mars_body();
sun = sol_body();

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
earth_parking = elements2orbit((6378+500)*1000,...
    0, 0, 0, 0, 0, earth);
mars_parking = elements2orbit(9000*1000,...
    0, 0, 0, 0, 0, mars);

%% comb the desert

global_min = Inf;
epoch = datetime('01-jan-2020');

for launch_date = linspace(...
        datetime('01-Apr-2033'),...
        datetime('30-Apr-2033'), 30)

e1 = propagate_to(earth.orbit, launch_date);
m1 = propagate_to(mars.orbit, launch_date);

for dtof = days(180:280)

m2 = propagate_to(mars.orbit, launch_date + dtof);

[v1, ~, v2, ~] = intercept2(e1.r, m2.r, dtof, sun.mu);

if sum(isnan(v1)) || sum(isnan(v2))
    error("NaN detected!");
end

if norm(v1 - e1.v) < norm(v2 - e1.v)
    t1 = rv2orbit(e1.r, v1, sun, e1.epoch);
else
    t1 = rv2orbit(e1.r, v2, sun, e1.epoch);
end

t2 = propagate_to(t1, m2.epoch);
% t1.stop = t2.epoch;

dv1 = dvreq(norm(t1.v - e1.v), earth_parking);
dv2 = dvreq(norm(t2.v - m2.v), mars_parking);

dv = dv1 + dv2;
minimize = dv1 + dv2;

total_time = dtof;

fprintf("%s: D: %0.1f = %0.1f km/s\n",...
    datestr(launch_date), days(dtof), dv/1000);

if minimize < global_min
    global_min = minimize;
    min = struct;
    min.dv = dv;
    min.dv1 = dv1;
    min.dv2 = dv2;
    min.e1 = e1;
    min.m1 = m1;
    min.m2 = m2;
    min.t1 = t1;
    min.t2 = t2;
    min.time = launch_date;
    min.dtof = dtof;
end

end

end

%%

fprintf(":: %s D %0.1f = (%0.1f, %0.1f) km/s\n",...
    datestr(min.time), days(min.dtof), min.dv1/1000, min.dv2/1000);

eci({min.e1, min.m2, min.t1, min.m1});

% TODO get this working -- it was cool
% animate({min.e1, min.m2, min.t1, min.m1},...
%     [[min.e1.epoch, min.m2.epoch];...
%     [min.e1.epoch, min.m2.epoch];...
%     [min.e1.epoch, min.m2.epoch];...
%     [min.e1.epoch, min.m2.epoch]],...
%     {'', '', 'red', ''});
