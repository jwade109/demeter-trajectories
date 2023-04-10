function eci(elements)

if ~iscell(elements(1))
    error("eci() requires heterogeneous elements provided via cell array.")
end

% warning("Plotting %d elements.", numel(elements));

frame_body = get_common_body(elements);

bodies = [];
orbits = [];
low_thrust = [];

for orbit_index = 1:numel(elements)

    object = elements{orbit_index};
    
    if isa(object, 'astronomical_body')
        bodies = [bodies, object];
    elseif isa(object, 'keplerian_orbit')
        orbits = [orbits, object];
    elseif isa(object, 'low_thrust_trajectory')
        low_thrust = [low_thrust, object];
    else
        error("Unsupported object: %s", class(object))
    end

end % end iteration over varargs

hold on;

for b = bodies
    plot_astronomical_body(b, frame_body);
    if numel(b.orbit) && ~isequal(b, frame_body)
        plot_orbit(b.orbit, frame_body);
    end
end

for o = orbits
    plot_orbit(o, frame_body);
end

for lt = low_thrust
    plot_continuous_thrust(lt, frame_body);
end

make_plot_look_nice(frame_body);

end % end function

%% plot orbit -- not the parent body!

function plot_orbit(orbit, reference_body)

% warning("Plotting orbit around %s wrt %s", ...
%     orbit.primary_body.name, reference_body.name);

xyzoff = frame_translate(orbit.primary_body, reference_body);

start_nu = 0;
stop_nu = 2*pi;

THETA = real(linspace(start_nu, stop_nu, 400));
ROT = pqw2ijk(orbit.raan, orbit.i, orbit.argp);

if norm(orbit.e) >= 1
    soi = orbit.primary_body.soi;
    nu_soi = acos((orbit.a - orbit.a*orbit.e^2 - soi)/(orbit.e*soi));
    THETA = real(linspace(-nu_soi, nu_soi, 200));
end

RADIUS = orbit.p./(1 + norm(orbit.e)*cos(THETA));
POS = [(RADIUS.*cos(THETA))' (RADIUS.*sin(THETA))' zeros(size(THETA))'];

for i = 1:numel(THETA)
    POS(i,:) = (ROT*POS(i,:)')' + xyzoff';
end

% spacecraft point
plot3(orbit.r(1) + xyzoff(1), ...
      orbit.r(2) + xyzoff(2), ...
      orbit.r(3) + xyzoff(3), 'red.', 'MarkerSize', 20);

plot3(POS(:,1), POS(:,2), POS(:,3), 'LineWidth', 1);

if numel(orbit.label)
    text(orbit.r(1) + xyzoff(1), ...
         orbit.r(2) + xyzoff(2), ...
         orbit.r(3) + xyzoff(3), orbit.label);
end

if norm(orbit.e) < 1
    anv = orbit.n*orbit.p/(1+norm(orbit.e)*cos(-orbit.argp))/norm(orbit.n);
    dnv = -orbit.n*orbit.p/(1+norm(orbit.e)*cos(pi-orbit.argp))/norm(orbit.n);
    anv = anv + xyzoff;
    dnv = dnv + xyzoff;
    plot3([anv(1) dnv(1)], [anv(2) dnv(2)], [anv(3) dnv(3)], 'black:');
end

if norm(orbit.e) < 1
    periapsis = ROT*[orbit.rp; 0; 0] + xyzoff;
    apoapsis = -ROT*[orbit.ra; 0; 0] + xyzoff;
    plot3(periapsis(1), periapsis(2), periapsis(3), 'blue.', 'MarkerSize', 10);
    plot3(apoapsis(1), apoapsis(2), apoapsis(3), 'blue*', 'MarkerSize', 10);
end

% not sure what this was for
% if isnan(orbit.raan)
%     orbit.raan = -orbit.nu;
% end
% if isnan(orbit.argp)
%     orbit.argp = 0;
% end

end

%% plot astronomical body, but not its orbit
function plot_astronomical_body(body, reference_body)

warning("Plotting surface of %s", body.name);
offset = frame_translate(body, reference_body);
draw_a_sphere(offset, body.radius);
text(offset(1), offset(2), offset(3) + body.radius, body.name);

end

%% plot a continuous thrust trajectory
function plot_continuous_thrust(traj, reference_body)

plot3(traj.path(:,1), traj.path(:,2), traj.path(:,3));
plot_orbit(traj.initial, reference_body);
plot_orbit(traj.final, reference_body);

end

%% make it look real good
function make_plot_look_nice(reference_body)

xlabel("X");
ylabel("Y");
zlabel("Z");

grid on;

axis('equal');
view([37.5 10]);

title(sprintf("%s-Centered Inertial Frame", reference_body.name));

end

%% draw a sphere of a given radius and position
function draw_a_sphere(position, radius)

[SX, SY, SZ] = sphere();
surf(SX*radius + position(1), ...
     SY*radius + position(2), ...
     SZ*radius + position(3));

end

%% periapsis, apoapsis
% if norm(orbit.e) < 1
%     periapsis = ROT*[orbit.rp; 0; 0];
%     apoapsis = -ROT*[orbit.ra; 0; 0];
%     plot3(periapsis(1), periapsis(2), periapsis(3), 'blue.', 'MarkerSize', 10);
%     plot3(apoapsis(1), apoapsis(2), apoapsis(3), 'blue*', 'MarkerSize', 10);
% end

% hvector = orbit.h*max(orbit.rp, R*2)/norm(orbit.h);
% pvector = ROT*[0; orbit.p; 0];
% veq = [1; 0; 0]*max(orbit.rp, R*2);

% title('ICRF J2000 Frame');

% spacecraft velocity
% plot3([orbit.r(1) orbit.r(1) + orbit.v(1)],...
%       [orbit.r(2) orbit.r(2) + orbit.v(2)],...
%       [orbit.r(3) orbit.r(3) + orbit.v(3)], 'black-');

% % angular momentum vector
% plot3([0 hvector(1)], [0 hvector(2)], [0 hvector(3)], 'red:');

% true anomaly
% plot3([0 orbit.r(1)], [0 orbit.r(2)], [0 orbit.r(3)], 'g-');

% % % parameter vector
% plot3([0 pvector(1)], [0 pvector(2)], [0 pvector(3)], 'red-');

% % vernal equinox vector
% plot3([0 veq(1)], [0 veq(2)], [0 veq(3)], 'magenta--');

% rh = orbit.primary_body.soi;
% X = rh.*cos(THETA);
% Y = rh.*sin(THETA);
% Z = THETA*0;
% plot3(X, Y, Z, 'g--');

% legend('planet', 'orbit', 'spacecraft', 'velocity', 'perigee', 'apogee',...
%        'angular momentum', 'line of nodes', 'ascending node', 'descending node',...
%        'line of apsides', 'true anomaly',...
%        'parameter', 'vernal equinox',...
%        'Hill Sphere',...
%        'Location', 'eastoutside');

% this stuff is useful, but it's cluttering up this function.
% get it working robustly first before adding bells and whistles

% view([0, 0, 1]);

% aabs = abs(orbit.a);

% if isfinite(orbit.primary_body.soi)
%     xlim([-orbit.primary_body.soi/3, orbit.primary_body.soi/3]);
%     ylim([-orbit.primary_body.soi/3, orbit.primary_body.soi/3]);
%     zlim([-orbit.primary_body.soi/3, orbit.primary_body.soi/3]);
% else
%     xlim([-aabs*2, aabs*2]);
%     ylim([-aabs*2, aabs*2]);
%     zlim([-aabs*2, aabs*2]);
% end
