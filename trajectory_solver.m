function min = trajectory_solver(...
    to, from, dtof_vec, stay_vec, rtof_vec, minimize)

global_min = Inf;
epoch = datetime('01-jan-2020');

for launch_date = linspace(...
        datetime('15-Feb-2033'), datetime('30-Apr-2033'), 50)
    
e1 = propagate_to(earth, launch_date);

for dtof = days(140:10:200)
    
m2 = propagate_to(mars, launch_date + dtof);

for stay_time = days(45)
    
m3 = propagate_to(mars, launch_date + dtof + stay_time);
    
for rtof = days(200:10:280)
    
e4 = propagate_to(earth, launch_date + dtof + stay_time + rtof);

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

t1.stop = t2.epoch;
t2.stop = t3.epoch;
t3.stop = t4.epoch;

dv1 = dvreq(norm(t1.v - e1.v), earth_parking);
dv2 = dvreq(norm(t2.v - m2.v), mars_parking);
dv3 = dvreq(norm(t3.v - m3.v), mars_parking);
dv4 = dvreq(norm(t4.v - e4.v), earth_parking);

dv = dv1 + dv2 + dv3 + dv4;
minimize = dv1 + max(dv2 - reentry_limit, 0) + ...
           dv3 + max(dv4 - reentry_limit, 0);

total_time = dtof + rtof + stay_time;
 
fprintf("%s: D: %0.1f, S: %0.1f, R: %0.1f = " +...
    "%0.3f km/s, %0.2f days\n",...
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
    min.m2 = m2;
    min.m3 = m3;
    min.e4 = e4;
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
