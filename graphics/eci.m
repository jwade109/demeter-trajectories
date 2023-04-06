function eci(varargin)

for i = 1:nargin

object = varargin{i};   

if ~isfield(object, 'type')
    disp(object);
    error("Malformed struct has no 'type' field!");
end

if strcmp(object.type, 'low-thrust trajectory')
    plot3(object.path(:,1), object.path(:,2), object.path(:,3));
    eci(object.initial);
    eci(object.final);
end

if strcmp(object.type, 'body')
    r = object.radius;
    orbit = object.orbit;
end

if strcmp(object.type, 'orbit')
    r = 0;
    orbit = object;
end

R = orbit.primary_body.radius;

plot3(0, 0, 0, 'r*', 'MarkerSize', 10);
hold on;

if isnan(orbit.raan)
    orbit.raan = -orbit.nu;
end
if isnan(orbit.argp)
    orbit.argp = 0;
end

start_nu = 0;
stop_nu = 2*pi;

ROT = pqw2ijk(orbit.raan, orbit.i, orbit.argp);
THETA = real(linspace(start_nu, stop_nu, 200));

if norm(orbit.e) >= 1
    soi = orbit.primary_body.soi;
    nu_soi = acos((orbit.a - orbit.a*orbit.e^2 - soi)/(orbit.e*soi));
    THETA = real(linspace(-nu_soi, nu_soi, 200));
end

RADIUS = orbit.p./(1 + norm(orbit.e)*cos(THETA));
POS = [(RADIUS.*cos(THETA))' (RADIUS.*sin(THETA))' zeros(size(THETA))'];

for i = 1:numel(THETA)
    POS(i,:) = (ROT*POS(i,:)')';
end

[SX, SY, SZ] = sphere();
surf(SX*R, SY*R, SZ*R);
[SX, SY, SZ] = sphere();
surf(SX*r + orbit.r(1),...
     SY*r + orbit.r(2),...
     SZ*r + orbit.r(3));
axis('equal');

if ~min(isreal(POS))
    warning("oof");
end

plot3(POS(:,1),...
      POS(:,2),...
      POS(:,3),...
      'LineWidth', 1);

perigee = ROT*[orbit.rp; 0; 0];
apogee = -ROT*[orbit.ra; 0; 0];
if (norm(orbit.e) >= 1)
    apogee = [0; 0; 0];
end
hvector = orbit.h*max(orbit.rp, R*2)/norm(orbit.h);
pvector = ROT*[0; orbit.p; 0];
anv = orbit.n*orbit.p/(1+norm(orbit.e)*cos(-orbit.argp))/norm(orbit.n);
dnv = -orbit.n*orbit.p/(1+norm(orbit.e)*cos(pi-orbit.argp))/norm(orbit.n);
veq = [1; 0; 0]*max(orbit.rp, R*2);

% title('ICRF J2000 Frame');

% spacecraft point
plot3(orbit.r(1), orbit.r(2), orbit.r(3), 'red.', 'MarkerSize', 20);
  
% if isfield(orbit, 'label')
%     text(orbit.r(1), orbit.r(2), orbit.r(3), orbit.label);
% end

% spacecraft velocity
plot3([orbit.r(1) orbit.r(1) + orbit.v(1)],...
      [orbit.r(2) orbit.r(2) + orbit.v(2)],...
      [orbit.r(3) orbit.r(3) + orbit.v(3)], 'black-');
% perigee point
plot3(perigee(1), perigee(2), perigee(3), 'blue.', 'MarkerSize', 10);
% apogee point
plot3(apogee(1), apogee(2), apogee(3), 'blue*', 'MarkerSize', 10);

% % angular momentum vector
% plot3([0 hvector(1)], [0 hvector(2)], [0 hvector(3)], 'red:');

if norm(orbit.e) < 1
    % ascending and descending nodes
    plot3([anv(1) dnv(1)], [anv(2) dnv(2)], [anv(3) dnv(3)], 'black:');
    plot3(anv(1), anv(2), anv(3), 'redo');
    plot3(dnv(1), dnv(2), dnv(3), 'red.');
end

% line of apsides
plot3([apogee(1) perigee(1)], ...
      [apogee(2) perigee(2)], ...
      [apogee(3) perigee(3)], 'blue--');

% true anomaly
% plot3([0 orbit.r(1)], [0 orbit.r(2)], [0 orbit.r(3)], 'g-');

% % % parameter vector
% plot3([0 pvector(1)], [0 pvector(2)], [0 pvector(3)], 'red-');

% % vernal equinox vector
% plot3([0 veq(1)], [0 veq(2)], [0 veq(3)], 'magenta--');

rh = orbit.primary_body.soi;
X = rh.*cos(THETA);
Y = rh.*sin(THETA);
Z = THETA*0;
plot3(X, Y, Z, 'g--');

% legend('planet', 'orbit', 'spacecraft', 'velocity', 'perigee', 'apogee',...
%        'angular momentum', 'line of nodes', 'ascending node', 'descending node',...
%        'line of apsides', 'true anomaly',...
%        'parameter', 'vernal equinox',...
%        'Hill Sphere',...
%        'Location', 'eastoutside');

xlabel("X");
ylabel("Y");
zlabel("Z");

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

end
   
end