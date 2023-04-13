clear;
clc;
close all;

%% orbit definitions

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
earth = earth_body();
earth_parking = parking_orbit(earth, km(500));
mars = mars_body();
mars_parking = parking_orbit(mars, km(500));
sol = sol_body();

%% comb the desert

abort_out_vec = days(5:100);
rtof_vec = days(10:5:850);

global_min = Inf;
reentry_limit = 5000;
epoch = datetime('01-jan-2020');
Z = zeros(numel(abort_out_vec), numel(rtof_vec))*NaN;

for launch_date = datetime('07-July-2035')

e1 = propagate_to(earth.orbit, launch_date);

for dtof = days(106)

m2 = propagate_to(mars.orbit, launch_date + dtof);

for i = 1:numel(abort_out_vec)

abort_out = abort_out_vec(i);

for j = 1:numel(rtof_vec)

rtof = rtof_vec(j);

e3 = propagate_to(earth.orbit, launch_date + abort_out + rtof);

[v1, ~, v2, ~] = intercept2(e1.r, m2.r, dtof, sol.mu);

if norm(v1 - e1.v) < norm(v2 - e1.v)
    t1 = rv2orbit(e1.r, v1, sol, e1.epoch);
else
    t1 = rv2orbit(e1.r, v2, sol, e1.epoch);
end

t2 = propagate_to(t1, launch_date + abort_out);

[v3, ~, v4, ~] = intercept2(t2.r, e3.r, rtof, sol.mu);

if norm(v3 - t2.v) < norm(v4 - t2.v)
    t3 = rv2orbit(t2.r, v3, sol, t2.epoch);
else
    t3 = rv2orbit(t2.r, v4, sol, t2.epoch);
end

if sum(isnan(v1)) || sum(isnan(v2)) || sum(isnan(v3)) || sum(isnan(v4))
    warning("NaN detected!");
    continue;
end

if strcmp(t1.class, 'hyperbolic') || strcmp(t3.class, 'hyperbolic')
    continue
end

t4 = propagate_to(t3, e3.epoch);

% t1.stop = t2.epoch;
% t3.stop = t4.epoch;

dv = norm(t2.v - t3.v) + ...
     max(dvreq(norm(t4.v - e3.v), earth_parking) - reentry_limit, 0);

minimize = dv;
Z(i, j) = dv;

fprintf("%s D %0.1f, A %0.1f, R %0.1f = " +...
    "%0.1f km/s\n",...
    datestr(launch_date),...
    days(dtof),...
    days(abort_out),...
    days(rtof),...
    dv/1000);

if minimize < global_min
    global_min = minimize;
    min = struct;
    min.dv = dv;
    min.e1 = e1;
    min.m2 = m2;
    min.e3 = e3;
    min.t1 = t1;
    min.t2 = t2;
    min.t3 = t3;
    min.t4 = t4;
    min.time = launch_date;
    min.dtof = dtof;
    min.rtof = rtof;
    min.abort = abort_out;
end

end

end

end

end

%%

figure;
ZZ = Z/1000;
ZZ(ZZ > 15) = NaN;
[X, Y] = meshgrid(abort_out_vec, rtof_vec);
contourf(days(X), days(Y), ZZ');
hold on;
plot3(days(abort_out_vec), 411 - days(abort_out_vec),...
    ones(size(abort_out_vec))*100000, 'r-', 'LineWidth', 2);
plot3(days(abort_out_vec), 731 - days(abort_out_vec),...
    ones(size(abort_out_vec))*100000, 'r-', 'LineWidth', 2);

view([0, 90]);
colorbar;
shading interp;
grid on;
xlabel("\color{black}Time Since Earth Departure (days)");
ylabel("\color{black}Time to Return to Earth (days)");
title("\color{black}Total Propulsive \Delta{V} Required to Abort-to-Earth (km/s)")

%%

fprintf(">> %s D %0.1f, A %0.1f, R %0.1f = %0.1f kmps, %0.1f days\n",...
    datestr(min.time),...
    days(min.dtof),...
    days(min.abort),...
    days(min.rtof),...
    min.dv/1000,...
    days(min.abort + min.rtof));

% animate({min.e1, min.m2, min.t1, min.t3},...
%     [[min.e1.epoch, min.t4.epoch];...
%     [min.e1.epoch, min.t4.epoch];...
%     [min.t1.epoch, min.t2.epoch];...
%     [min.t3.epoch, min.t4.epoch]],...
%     {'', '', 'red', 'blue'});
