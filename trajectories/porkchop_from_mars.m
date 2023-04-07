clear;
clc;
close all;

%% orbit definitions

earth = earth_body();
earth_parking = parking_orbit(earth, km(500));
mars = mars_body();
mars_parking = parking_orbit(mars, km(500));
sol = sol_body();

%% comb the desert

global_min = Inf;
epoch = datetime('01-jan-2020');

launch_date_vec = datetime('01-Jan-2029'):days(5):datetime('31-Dec-2035');

dtof_vec = days(100:450);

Z = ones(numel(launch_date_vec), numel(dtof_vec))*NaN;

for i = 1:numel(launch_date_vec)

launch_date = launch_date_vec(i);

m1 = propagate_to(mars.orbit, launch_date);

for j = 1:numel(dtof_vec)

dtof = dtof_vec(j);

e2 = propagate_to(earth.orbit, launch_date + dtof);

[v1, ~, v2, ~] = intercept2(m1.r, e2.r, dtof, sol.mu);

if norm(v1 - m1.v) < norm(v2 - m1.v)
    t1 = rv2orbit(m1.r, v1, sol, m1.epoch);
else
    t1 = rv2orbit(m1.r, v2, sol, m1.epoch);
end

if sum(isnan(t1.v)) || strcmp(t1.type, 'hyperbolic')
    continue;
end

t2 = propagate_to(t1, e2.epoch);

dv1 = dvreq(norm(t1.v - m1.v), mars_parking);
dv2 = dvreq(norm(t2.v - e2.v), earth_parking);

dv = dv1 + dv2;
minimize = dv;

Z(i, j) = dv;

fprintf("%s: D: %0.1f = " +...
    "%0.1f km/s\n",...
    datestr(launch_date),...
    days(dtof),...
    dv/1000);

if minimize < global_min
    global_min = minimize;
    min = struct;
    min.dv = dv;
    min.dv1 = dv1;
    min.dv2 = dv2;
    min.m1 = m1;
    min.e2 = e2;
    min.t1 = t1;
    min.t2 = t2;
    min.time = launch_date;
    min.dtof = dtof;
end

end

end

%%

ZZ = Z/1000;
ZZ(ZZ > 40) = NaN;
[X, Y] = meshgrid(launch_date_vec - epoch, dtof_vec);
contourf(years(X) + 2020, days(Y), ZZ');
view([0, 90]);
colorbar;
grid on;
shading interp;

set(gca,'FontSize',18)
xlabel("Departure Date",'FontSize',24,'FontWeight','bold','FontName','Calibri')
ylabel("Time of Flight (days)",'FontSize',24,'FontWeight','bold','FontName','Calibri')
title("\color{white}Total \Delta{V}, One Way Transit from Mars to Earth (km/s)",'FontSize',24,'FontWeight','bold','FontName','Calibri')

fprintf(">> %s: D: %0.1f = " +...
    "(%0.1f, %0.1f) km/s\n",...
    datestr(min.time),...
    days(min.dtof),...
    min.dv1/1000, min.dv2/1000);

% animate2({min.m1, min.e2, min.t1},...
%     [[min.t1.epoch, min.t2.epoch];...
%     [min.t1.epoch, min.t2.epoch];...
%     [min.t1.epoch, min.t2.epoch]],...
%     {'', '', 'blue'});
