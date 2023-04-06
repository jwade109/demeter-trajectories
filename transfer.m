clear;
clc;
close all;

initial = elements2orbit(7E+06, 0.2, 0, -0.4, 2, 1, mars());
initial.epoch = datetime('01-Jan-2020');
target = elements2orbit(17E+06, 0.3, 0.8, -0.4, 0.3, 2, mars());
target.epoch = datetime('01-Jan-2020');

maneuvers = transfer_do(initial, target);
eci(initial, target, maneuvers{:});

function [maneuvers, dv] = transfer_do(initial, target)

[in_plane, pcdv] = match_inclination(initial, target);
[maneuvers, cdv] = coplanar_transfer(in_plane, target);
dv = sum([pcdv, cdv]);

for i = 2:numel(maneuvers)
    man = maneuvers{i};
    bef = maneuvers{i-1};
    bef.stop_nu = signed_angle(bef.e_vector, man.r, man.h);
    if bef.stop_nu < 0
        bef.stop_nu = bef.stop_nu + 2*pi;
    end
    maneuvers{i} = man;
    maneuvers{i-1} = bef;
end

end

function [orbit, dv] = match_inclination(initial, target)

cr = cross(initial.h, target.h);
if norm(cr) < 1E-05
    warning("Orbits are not mutually inclined");
    orbit = initial;
    dv = 0;
    return;
end

cr = cr/norm(cr);
plane_change_nu_1 = mod(initial.nu + ...
    signed_angle(initial.r, -cr, initial.h), 2*pi);
plane_change_nu_2 = mod(initial.nu + ...
    signed_angle(initial.r, cr, initial.h), 2*pi);
in_plane_1 = propagate_to_nu(initial, plane_change_nu_1);
in_plane_2 = propagate_to_nu(initial, plane_change_nu_2);

% hold on;
% line = cr*(linspace(-norm(in_plane_1.r), norm(in_plane_2.r), 100)')';
% plot3(line(:,1), line(:,2), line(:,3), 'r--');

if norm(in_plane_1.v) < norm(in_plane_2.v)
    in_plane = in_plane_1;
else
    in_plane = in_plane_2;
end

target = propagate_to_nu(target, target.nu + ...
    signed_angle(target.r, in_plane.r, target.h));

disp(in_plane.r);
disp(target.r);
% eci(target, in_plane);

dinc = signed_angle(in_plane.h, target.h, in_plane.r);
[orbit, dv] = plane_change(in_plane, dinc);

end

function theta = signed_angle(u, v, n)

n = n/norm(n);
costheta = dot(u, v)/(norm(u)*norm(v));
sintheta = dot(cross(n, u), v)/(norm(u)*norm(v));

if sintheta < 0
    theta = 2*pi - acos(costheta);
else
    theta = acos(costheta);
end

end
