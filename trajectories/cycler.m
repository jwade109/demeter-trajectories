clear;
clc;
close all;

%% orbit definitions

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
epoch = datetime('01-jan-2020');
earth = earth_body();
earth_parking = elements2orbit((6378+500)*1000,...
    0, 0, 0, 0, 0, earth);
mars = mars_body();
mars_parking = elements2orbit(9000*1000,...
    0, 0, 0, 0, 0, mars);

%% comb the desert

global_min = Inf;
epoch = datetime('01-jan-2020');

reentry_limit = 4000;

launch_date_vec = ...
        datetime('6-feb-2031');
dtof_vec = days(105:5:200);
Z = zeros(numel(launch_date_vec), numel(dtof_vec))*NaN;

for i = 1:numel(launch_date_vec)

launch_date = launch_date_vec(i);

e1 = propagate_to(earth.orbit, launch_date);

for j = 1:numel(dtof_vec)

dtof = dtof_vec(j);

m2 = propagate_to(mars.orbit, launch_date + dtof);

for rtof = earth.orbit.T*1.5 - dtof

e3 = e1;
e3.epoch = e1.epoch + years(3);
e1.stop = e3.epoch;

[v1, ~, v2, ~] = intercept2(e1.r, m2.r, dtof, sol.mu);
[v3, ~, v4, ~] = intercept2(m2.r, e3.r, rtof, sol.mu);

if sum(isnan(v1)) || sum(isnan(v2)) || sum(isnan(v3)) || sum(isnan(v4))
    warning("NaN detected!");
    continue;
end

if norm(v1 - e1.v) < norm(v2 - e1.v)
    t1 = rv2orbit(e1.r, v1, sol_body(), e1.epoch);
else
    t1 = rv2orbit(e1.r, v2, sol_body(), e1.epoch);
end

if norm(v3 - m2.v) < norm(v4 - m2.v)
    t3 = rv2orbit(m2.r, v3, sol_body(), m2.epoch);
else
    t3 = rv2orbit(m2.r, v4, sol_body(), m2.epoch);
end

if strcmp(t1.type, 'hyperbolic') || strcmp(t3.type, 'hyperbolic')
    warning("Hyperbolic!");
    continue;
end

t2 = propagate_to(t1, m2.epoch);
t1.stop = t2.epoch;
t4 = propagate_to(t3, e3.epoch);
t3.stop = t4.epoch;
m1 = propagate_to(m2, e1.epoch);

dv1 = dvreq(norm(t1.v - e1.v), earth_parking);
dv2 = norm(t2.v - t3.v);
dv3 = max(dvreq(norm(t4.v - e3.v), earth_parking) - reentry_limit, 0);

dv = dv1 + dv2 + dv3;
minimize = dv;

Z(i, j) = dv;

total_time = days(seconds(dtof)) + days(seconds(rtof));

fprintf("%s: D: %0.1f, R: %0.1f = " +...
    "%0.1f km/s, %0.1f days\n",...
    datestr(launch_date),...
    days(dtof),...
    days(rtof),...
    dv/1000, days(total_time));

if minimize < global_min
    global_min = minimize;
    min = struct;
    min.dv = dv;
    min.dv1 = dv1;
    min.dv2 = dv2;
    min.dv3 = dv3;
    min.e1 = e1;
    min.m1 = m1;
    min.m2 = m2;
    min.e3 = e3;
    min.t1 = t1;
    min.t2 = t2;
    min.t3 = t3;
    min.t4 = t4;
    min.time = launch_date;
    min.dtof = dtof;
    min.rtof = rtof;
end

end

end

end

%%

% hold off;
% ZZ = Z/1000;
% % ZZ(ZZ > 12) = NaN;
% [X, Y] = meshgrid(launch_date_vec - epoch, dtof_vec);
% surf(years(launch_date_vec - epoch) + 2020, days(Y), ZZ');
% hold on;
% plot3(years(min.time - epoch) + 2020, days(min.dtof), 10000, 'r*');
% text(years(min.time - epoch) + 2020, days(min.dtof) + 4, 10000,...
%     sprintf('Launch date: %s\nTransit time: %0.0f days\nDelta-V: %0.1f km/s',...
%     datestr(min.time), days(min.dtof), min.dv/1000),...
%     'FontSize', 16, 'Color', 'white');
% view([0, 90]);
% colorbar;
% grid on;
% shading interp;
% set(gca, 'FontName', 'Times New Roman')
% xlabel("Departure Date",...
%     'FontSize', 16)
% ylabel("Time of Flight to Mars (days)",...
%     'FontSize', 16);
% title("Total Propulsive \Delta{V}, 2-Year Mars Cycler Mission (km/s)",...
%     'FontSize', 20)

fprintf(">> %s: D: %0.1f, R: %0.1f = " +...
    "(%0.1f, %0.3f, %0.1f) km/s, %0.1f days\n",...
    datestr(min.time),...
    days(min.dtof),...
    days(min.rtof),...
    min.dv1/1000, min.dv2/1000, min.dv3/1000,...
    days(min.dtof) + days(min.rtof));

min.e1.stop = min.e3.epoch;
min.m2.stop = min.m2.epoch;
min.e3.stop = min.e3.epoch;
min.t1.stop = min.e3.epoch;

eci({min.t1, min.e1, min.m1, min.m2, min.e3}, ...
     {'w-', 'b--', 'r--', '', ''}, ...
     {'b.', 'b.', 'r.', 'r.', 'b.'});

% animate(1, min.t1, min.e1, min.m1);
