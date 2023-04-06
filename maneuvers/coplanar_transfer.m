function [maneuvers, dv] = coplanar_transfer(initial, target)

match_apoapsis = propagate_to_nu(initial, 0);
[match_apoapsis, dv1] = change_apoapsis(match_apoapsis, target.ra);
circular = propagate_to_nu(match_apoapsis, pi);
[circular, dv2] = circularize(circular);

target_apoapsis = propagate_to_nu(target, pi);

rendezvous_nu = mod(circular.nu + ...
    signed_angle(circular.r, target_apoapsis.r, initial.h), 2*pi);

final = propagate_to_nu(circular, rendezvous_nu);
[final, dv3] = change_periapsis(final, target.rp);

maneuvers = {initial, match_apoapsis, circular, final};
dv = [dv1, dv2, dv3];

end