clear;
clc;
close all;

%% orbit definitions

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
earth = earth();
earth_parking = elements2orbit((6378+500)*1000,...
    0, 0, 0, 0, 0, mu('earth'));

mars = mars();
mars_parking = elements2orbit(9000*1000,...
    0, 0, 0, 0, 0, mu('mars'));

%% comb the desert

global_min = Inf;
reentry_limit = 5000; % m/s

for launch_date = linspace(...
        datetime('19-Jun-2035'), datetime('19-Jun-2035'), 1)

e1 = propagate_to(earth, launch_date);

for dtof = days(130)
    
m2 = propagate_to(mars, launch_date + dtof);

for stay_time = days(45)
    
m3 = propagate_to(mars, launch_date + dtof + stay_time);
    
for rtof = days(255)
    
e4 = propagate_to(earth, launch_date + dtof + stay_time + rtof);

for linear_dv = 3500:50:3900
    
for btof = days(270:5:370)

for utof = days(300:5:370)

e5 = e4;
e8 = propagate_to(earth, launch_date + dtof + stay_time + rtof + btof + utof);

[v1, ~, v2, ~] = intercept2(e1.r, m2.r, dtof, mu('sun'));
[v3, ~, v4, ~] = intercept2(m3.r, e4.r, rtof, mu('sun'));

if sum(isnan(v1)) || sum(isnan(v2)) || sum(isnan(v3)) || sum(isnan(v4))
    error("NaN detected!");
end
    
if norm(v1 - e1.v) < norm(v2 - e1.v)
    t1 = rv2orbit(e1.r, v1, mu('sun'), e1.epoch);
else
    t1 = rv2orbit(e1.r, v2, mu('sun'), e1.epoch);
end

if norm(v3 - m3.v) < norm(v4 - m3.v)
    t3 = rv2orbit(m3.r, v3, mu('sun'), m3.epoch);
else
    t3 = rv2orbit(m3.r, v4, mu('sun'), m3.epoch);
end

t2 = propagate_to(t1, m2.epoch);
t4 = propagate_to(t3, e4.epoch);
t5 = rv2orbit(t4.r, t4.v + t4.v/norm(t4.v)*linear_dv, mu('sun'), e5.epoch);
t6 = propagate_to(t5, t5.epoch + btof);

[v5, ~, v6, ~] = intercept2(t6.r, e8.r, utof, mu('sun'));

if norm(v5 - t6.v) < norm(v6 - t6.v)
    t7 = rv2orbit(t6.r, v5, mu('sun'), t6.epoch);
else
    t7 = rv2orbit(t6.r, v6, mu('sun'), t6.epoch);
end
t8 = propagate_to(t7, e8.epoch);

t1.stop = t2.epoch;
t2.stop = t3.epoch;
t3.stop = t4.epoch;
t4.stop = t5.epoch;
t5.stop = t6.epoch;
t6.stop = t7.epoch;
t7.stop = t8.epoch;

dv1 = dvreq(norm(t1.v - e1.v), earth_parking);
dv2 = dvreq(norm(t2.v - m2.v), mars_parking);
dv3 = dvreq(norm(t3.v - m3.v), mars_parking);
dv4 = dvreq(norm(t4.v - e4.v), earth_parking);
dv5 = norm(t4.v - t5.v);
dv6 = norm(t6.v - t7.v);
dv7 = dvreq(norm(t8.v - e8.v), earth_parking);
e6 = propagate_to(earth, t6.epoch);

dv = dv1 + dv3;
rndzv_dv = dv2 + dv4;
minimize = dv5 + dv6 + max(dv7 - reentry_limit, 0);

total_time = dtof + rtof + stay_time;
 
fprintf("%s: D: %0.1f, S: %0.1f, R: %0.1f = " +...
    "%0.1f km/s, %0.1f days\n",...
    datestr(launch_date),...
    days(dtof),...
    days(stay_time),...
    days(rtof),...
    dv/1000, days(total_time));
fprintf("%0.2f km/s M: %0.1f C: %0.1f = %0.2f km/s\n",...
    linear_dv/1000,...
    days(btof),...
    days(utof), minimize/1000);
    
    
if minimize < global_min
    global_min = minimize;
    min = struct;
    min.dv = dv;
    min.dv1 = dv1;
    min.dv2 = dv2;
    min.dv3 = dv3;
    min.dv4 = dv4;
    min.dv5 = dv5;
    min.dv6 = dv6;
    min.dv7 = dv7;
    min.e1 = e1;
    min.m2 = m2;
    min.m3 = m3;
    min.e4 = e4;
    min.e5 = e5;
    min.e6 = e6;
    min.t1 = t1;
    min.t2 = t2;
    min.t3 = t3;
    min.t4 = t4;
    min.t5 = t5;
    min.t6 = t6;
    min.t7 = t7;
    min.t8 = t8;
    min.time = launch_date;
    min.dtof = dtof;
    min.rtof = rtof;
    min.linear_dv = linear_dv;
    min.btof = btof;
    min.utof = utof;
    min.stay = stay_time;
end

end % 2nd boost coast time of flight

end % boost coast time of flight

end % boost dv at earth

end % return time of flight

end % stay time

end % departure time of flight

end

%%

% eci(min.e1);
% eci(min.m2);
% eci(min.m3);
% eci(min.e4);
% eci(min.t1);
% eci(min.t3);

%%

fprintf(":: %s D %0.1f, S %0.1f, R %0.1f = (%0.1f, %0.1f, %0.1f, %0.1f) kmps, %0.1f days\n",...
    datestr(min.time),...
    days(min.dtof),...
    days(min.stay),...
    days(min.rtof),...
    min.dv1/1000, min.dv2/1000, min.dv3/1000,...
    min.dv4/1000,...
    days(min.dtof) + days(min.rtof)...
    + days(min.stay));

fprintf(":: M %0.1f C %0.1f = (%0.2f %0.2f %0.2f) kmps\n",...
    days(min.btof),...
    days(min.utof), min.dv5/1000, min.dv6/1000, min.dv7/1000);
    
animate({min.e1, min.m2, min.m3, min.t1, min.t3, min.t5, min.t7},...
    [[min.e1.epoch, min.t8.epoch];...
    [min.m2.epoch, min.m3.epoch];...
    [min.e1.epoch, min.t8.epoch];...
    [min.e1.epoch, min.m2.epoch];...
    [min.m3.epoch, min.e4.epoch];...
    [min.e5.epoch, min.t6.epoch];...
    [min.t7.epoch, min.t8.epoch]],...
    {'', 'red', '', 'blue', 'green', 'magenta', 'cyan'});


%% compute required DV to achieve vinf from a given orbit

function dv = dvreq(vinf, orbit)

dv = sqrt(vinf.^2 + orbit.vesc.^2) - norm(orbit.v);

end