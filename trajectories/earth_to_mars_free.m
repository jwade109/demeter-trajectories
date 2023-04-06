function min = earth_to_mars_free( ...
    launch_dates, departure_tofs, stay_times, return_tofs)

if nargin < 1
    launch_dates = datetime('01-Jan-2031'):days(15):datetime('31-Dec-2032');
end
if nargin < 2
    departure_tofs = days(120:10:180);
end
if nargin < 3
    stay_times = days(0);
end
if nargin < 4
    return_tofs = years(3) - departure_tofs;
end

%% cacheing

[success, file, cache] = request_cache('earth_to_mars_free', ...
    launch_dates, departure_tofs, stay_times, return_tofs);
if success
    min = file.min;
    fprintf(":: %s D %0.1f, S %0.1f, R %0.1f = (%0.2f, %0.2f, %0.2f, %0.2f) kmps, %0.1f days\n",...
        datestr(min.time),...
        days(min.dtof),...
        days(min.stay),...
        days(min.rtof),...
        min.dv1/1000, min.dv2/1000, min.dv3/1000,...
        min.dv4/1000,...
        days(min.dtof) + days(min.rtof) + days(min.stay));
    return;
end

%% orbit definitions

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
e = earth();
e = e.orbit;
earth_parking = elements2orbit((6378+500)*1000,...
    0, 0, 0, 0, 0, earth());
m = mars();
m = m.orbit;
mars_parking = elements2orbit(3600*1000,...
    0, 0, 0, 0, 0, mars());

%% comb the desert

global_min = Inf;
earth_reentry_limit = 4000; % m/s
mars_reentry_limit = 3000; % m/s

for launch_date = launch_dates
    
e1 = propagate_to(e, launch_date);

for dtof = departure_tofs
    
m2 = propagate_to(m, launch_date + dtof);

for stay_time = stay_times
    
m3 = propagate_to(m, launch_date + dtof + stay_time);
    
for rtof = return_tofs
    
e4 = propagate_to(e, launch_date + dtof + stay_time + rtof);

[v1, ~, v2, ~] = intercept2(e1.r, m2.r, dtof, mu('sun'));
[v3, ~, v4, ~] = intercept2(m3.r, e4.r, rtof, mu('sun'));

if norm(v1 - e1.v) < norm(v2 - e1.v)
    t1 = rv2orbit(e1.r, v1, sun(), e1.epoch);
else
    t1 = rv2orbit(e1.r, v2, sun(), e1.epoch);
end

if norm(v3 - m3.v) < norm(v4 - m3.v)
    t3 = rv2orbit(m3.r, v3, sun(), m3.epoch);
else
    t3 = rv2orbit(m3.r, v4, sun(), m3.epoch);
end

if sum(isnan(v1)) || sum(isnan(v2)) || sum(isnan(v3)) || sum(isnan(v4))
    warning("NaN detected!");
    continue;
end

t2 = propagate_to(t1, m2.epoch);
t4 = propagate_to(t3, e4.epoch);
m1 = propagate_to(m2, e1.epoch);

e1.stop = t4.epoch;
m1.stop = t4.epoch;

t1.stop = t2.epoch;
t3.stop = t4.epoch;

dv1 = dvreq(norm(t1.v - e1.v), earth_parking);
dv2 = dvreq(norm(t2.v - m2.v), mars_parking);
dv3 = dvreq(norm(t3.v - m3.v), mars_parking);
dv4 = dvreq(norm(t4.v - e4.v), earth_parking);

dv = dv1 + max(dv4 - earth_reentry_limit, 0);

minimize = dv + norm(t2.v - t3.v)*20;

total_time = dtof + rtof + stay_time;

fprintf("%s: D: %0.1f, S: %0.1f, R: %0.1f = %0.3f km/s, %0.2f days\n",...
    datestr(launch_date),...
    days(dtof),...
    days(stay_time),...
    days(rtof),...
    dv/1000, days(total_time));
    
if minimize < global_min
    global_min = minimize;
    min = struct;
    min.dv = dv;
    min.dv1 = dv1;
    min.dv2 = dv2;
    min.dv3 = dv3;
    min.dv4 = dv4;
    min.e1 = e1;
    min.m1 = m1;
    min.t1 = t1;
    min.t2 = t2;
    min.t3 = t3;
    min.t4 = t4;
    min.time = launch_date;
    min.dtof = dtof;
    min.rtof = rtof;
    min.stay = stay_time;
end

end % return time of flight

end % stay time

end % departure time of flight

end

%%

fprintf(":: %s D %0.1f, S %0.1f, R %0.1f = (%0.2f, %0.2f, %0.2f, %0.2f) kmps, %0.1f days\n",...
    datestr(min.time),...
    days(min.dtof),...
    days(min.stay),...
    days(min.rtof),...
    min.dv1/1000, min.dv2/1000, min.dv3/1000,...
    min.dv4/1000,...
    days(min.dtof) + days(min.rtof) + days(min.stay));

eci(min.e1, min.m1, min.t1, min.t2, min.t3, min.t4);

%% compute required DV to achieve vinf from a given orbit

save(cache, 'min');

end

function dv = dvreq(vinf, orbit)

dv = sqrt(vinf.^2 + orbit.vesc.^2) - norm(orbit.v);

end