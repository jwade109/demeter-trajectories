function vreq = opposition_with_cycler()

if nargin < 1
    launch_dates = datetime('30-Jun-2035');
end


%% orbit definitions

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
e = earth_body();
e = e.orbit;
earth_parking = elements2orbit((6378+500)*1000,...
    0, 0, 0, 0, 0, earth_body());
m = mars_body();
m = m.orbit;
mars_parking = elements2orbit(3600*1000,...
    0, 0, 0, 0, 0, mars_body());

%% comb the desert

global_min = Inf;
earth_reentry_limit = 4000; % m/s
mars_reentry_limit = 3000; % m/s

for launch_date = datetime('01-June-2035'):days(1):datetime('31-Aug-2035')

e1 = propagate_to(e, launch_date);

for dtof = days(140:10:260)

m2 = propagate_to(m, launch_date + dtof);

for stay_time = days(60)

m3 = propagate_to(m, launch_date + dtof + stay_time);

for rtof = days(200:10:280)

e4 = propagate_to(e, launch_date + dtof + stay_time + rtof);

[v1, ~, v2, ~] = intercept2(e1.r, m2.r, dtof, mu('sun'));
[v3, ~, v4, ~] = intercept2(m3.r, e4.r, rtof, mu('sun'));

if norm(v1 - e1.v) < norm(v2 - e1.v)
    t1 = rv2orbit(e1.r, v1, sol_body(), e1.epoch);
else
    t1 = rv2orbit(e1.r, v2, sol_body(), e1.epoch);
end

if norm(v3 - m3.v) < norm(v4 - m3.v)
    t3 = rv2orbit(m3.r, v3, sol_body(), m3.epoch);
else
    t3 = rv2orbit(m3.r, v4, sol_body(), m3.epoch);
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

dv = dv1 + max(dv2 - mars_reentry_limit, 0) + ...
     dv3 + max(dv4 - earth_reentry_limit, 0);

minimize = dv1*6 + max(dv2 - mars_reentry_limit, 0) + ...
           dv3 + max(dv4 - earth_reentry_limit, 0);
% minimize = norm(t2.v - t3.v);

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

animate(2, min.e1, min.m1, min.t1, min.t2, min.t3, min.t4);


%%

% radius = johnny_plot({min.e1, min.m2, min.t1, min.t3},...
%     min.e1.epoch, eabort.epoch);
% writetable(radius, 'radius.txt');

%% compute required DV to achieve vinf from a given orbit

vreq = [min.dv1, min.dv2, min.dv3, min.dv4];

end

end
