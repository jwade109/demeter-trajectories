function [maneuvers, dv, tof] = aerocapture(hyperbolic, maxdv, rmax, ra, rp)

[success, file, cache] = request_cache('aerocapture', ...
    hyperbolic, maxdv, rmax, ra, rp);
if success
    maneuvers = file.maneuvers;
    dv = file.dv;
    tof = file.tof;
    return;
end

hyperbolic = propagate_to_nu(hyperbolic, 0);
[highest_allowable, dv1] = change_apoapsis(hyperbolic, rmax);
if dv1 < maxdv
    [highest_allowable, dv1] = prograde(hyperbolic, -maxdv);
    if highest_allowable.ra < ra
        [highest_allowable, dv1] = change_apoapsis(hyperbolic, ra);
    end
end
maneuvers = {hyperbolic, highest_allowable};
tof = days(days(highest_allowable.T));
dv = dv1;
ellipse = highest_allowable;

while abs(ellipse.ra - ra) > 1E-02
    ellipse.epoch = ellipse.epoch + ellipse.T;
    [new, dv2] = prograde(ellipse, -maxdv);
    if new.ra < ra
        [new, dv2] = change_apoapsis(ellipse, ra);
    end
    dv = [dv, dv2];
    ellipse = new;
    maneuvers = [maneuvers ellipse];
    tof = tof + ellipse.T;
end

final = propagate_to_nu(ellipse, pi);
[final, dvf] = change_periapsis(final, rp);
dv = [dv dvf];
tof = tof + final.T/2;
maneuvers = [maneuvers final];

for i = 2:numel(maneuvers)
    man = maneuvers{i};
    bef = maneuvers{i-1};
    bef.stop = man.epoch;
    maneuvers{i} = man;
    maneuvers{i-1} = bef;
end

save(cache, 'maneuvers', 'dv', 'tof');

end