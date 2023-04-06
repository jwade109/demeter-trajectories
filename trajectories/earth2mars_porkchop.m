clear;
clc;
close all;

%% orbit definitions

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
epoch = datetime('01-jan-2020');
earth = earth(epoch);
earth_parking = elements2orbit((6378+500)*1000,...
    0, 0, 0, 0, 0, mu('earth'));
mars = mars(epoch);
mars_parking = elements2orbit(6000*1000,...
    0, 0, 0, 0, 0, mu('mars'));

%% comb the desert

global_min = Inf;
epoch = datetime('01-jan-2020');

launch_date_vec = ...
        datetime('01-Jan-2035'):5:datetime('31-Dec-2035');
    
dtof_vec = days(60:5:330);

Z = ones(numel(launch_date_vec), numel(dtof_vec))*NaN;
C = zeros(numel(launch_date_vec), numel(dtof_vec));

for i = 1:numel(launch_date_vec)
    
launch_date = launch_date_vec(i);

e1 = propagate_to(earth, launch_date);

for j = 1:numel(dtof_vec)
    
dtof = dtof_vec(j);

cycle_tof = years(2) - dtof;
ecycle = propagate_to(earth, launch_date + years(2));
    
m2 = propagate_to(mars, launch_date + dtof);

[v1, ~, v2, ~] = intercept2(e1.r, m2.r, dtof, mu('sun'));
[v3, ~, v4, ~] = intercept2(m2.r, ecycle.r, cycle_tof, mu('sun'));

if norm(v1 - e1.v) < norm(v2 - e1.v)
    t1 = rv2orbit(e1.r, v1, mu('sun'), e1.epoch);
else
    t1 = rv2orbit(e1.r, v2, mu('sun'), e1.epoch);
end

if norm(v3 - m2.v) < norm(v4 - m2.v)
    t3 = rv2orbit(m2.r, v3, mu('sun'), m2.epoch);
else
    t3 = rv2orbit(m2.r, v4, mu('sun'), m2.epoch);
end

if sum(isnan(t1.v)) || strcmp(t1.type, 'hyperbolic')
    continue;
end

if sum(isnan(t3.v)) || strcmp(t3.type, 'hyperbolic')
    continue;
end

t2 = propagate_to(t1, m2.epoch);
t4 = propagate_to(t3, ecycle.epoch);

dv1 = dvreq(norm(t1.v - e1.v), earth_parking);
dv2 = max(dvreq(norm(t2.v - m2.v), mars_parking) - 4500, 0);

cycledv = norm(t3.v - t2.v);

dv = dv1 + dv2;

Z(i, j) = dv;
C(i, j) = cycledv;
 
fprintf("%s: D: %0.1f = " +...
    "%0.1f km/s (T: %0.1f)\n",...
    datestr(launch_date),...
    days(dtof),...
    dv/1000, cycledv/1000);

end

end

%%

figure;
ZZ = Z/1000;
ZZ(ZZ > 10) = NaN;
[X, Y] = meshgrid(launch_date_vec - epoch, dtof_vec);
contourf(days(X)/365 + 2020, days(Y), ZZ', 30);
view([0, 90]);
colorbar;
grid on;
shading interp;
set(gca, 'FontName', 'Times New Roman')
xlabel("Departure Date",...
    'FontSize', 16)
ylabel("Time of Flight (days)",...
    'FontSize', 16);
title("Total \Delta{V}, One Way Transit from Earth to Mars (km/s)",...
    'FontSize', 20)

hold on;
CC = C/1000;
CC(CC > 3) = NaN;
[X, Y] = meshgrid(launch_date_vec - epoch, dtof_vec);
contourf(days(X)/365 + 2020, days(Y), CC');
view([0, 90]);
colorbar;
% grid on;
shading flat;
% set(gca, 'FontName', 'Times New Roman')
% xlabel("Departure Date",...
%     'FontSize', 16)
% ylabel("Time of Flight (days)",...
%     'FontSize', 16);
% title("\Delta{V} to Enter Cycler Trajectory",...
%     'FontSize', 20)

%%

figure;
CC = C/1000;
CC(CC > 1) = NaN;
K = (C + Z)/1000;
K(K > 30) = NaN;
[X, Y] = meshgrid(launch_date_vec - epoch, dtof_vec);
contourf(days(X)/365 + 2020, days(Y), K', 30);
hold on;
contour(days(X)/365 + 2020, days(Y), CC', 1, 'LineColor', 'red');
% shading flat;
view([0, 90]);
colorbar;
grid on;
set(gca, 'FontName', 'Times New Roman')
xlabel("Departure Date",...
    'FontSize', 16)
ylabel("Time of Flight (days)",...
    'FontSize', 16);
title("Total \Delta{V}, One Way Transit from Earth to Mars (km/s)",...
    'FontSize', 20)


%% compute required DV to achieve vinf from a given orbit

function dv = dvreq(vinf, orbit)

dv = sqrt(vinf.^2 + orbit.vesc.^2) - norm(orbit.v);

end