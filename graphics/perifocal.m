function perifocal(orbit, R)

if nargin < 2
    R = 0;
end

clear pi
THETA = 0:pi/1024:2*pi; % true anomaly
if norm(orbit.e) >= 1
    THETA = -acos(-1/norm(orbit.e))+0.05:...
        pi/1024:acos(-1/norm(orbit.e))-0.05;
end

PX = R.*cos(0:pi/1024:2*pi)';
PY = R.*sin(0:pi/1024:2*pi)';

CTR = zeros(2*numel(PX),1);
CTR(2:2:end) = PX;
PX = CTR;
CTR(2:2:end) = PY;
PY = CTR;

RADIUS = orbit.p./(1 + norm(orbit.e)*cos(THETA));

figure(1);
hold on;
plot(PX, PY, 'LineWidth', 2, 'Color', [0.2, 0.2, 0.2]);
plot(RADIUS.*cos(THETA), RADIUS.*sin(THETA), 'b', 'LineWidth', 3);
plot([0 orbit.rp], [0, 0], 'Color', [0.9 0.1 0.1], 'LineWidth', 1);
plot(orbit.rp, 0, 'g.', 'MarkerSize', 20);
plot(-orbit.ra, 0, 'g.', 'MarkerSize', 20);
plot([0 0], [0 orbit.p], 'Color', [0.2 0.2 0.7], 'LineWidth', 3);

sr = orbit.p./(1 + norm(orbit.e)*cos(orbit.nu));
sx = sr*cos(orbit.nu);
sy = sr*sin(orbit.nu);

plot([0 sx], [0 sy], 'Color', [0.9 0.1 0.1], 'LineWidth', 1);
plot(sx, sy, 'r.', 'MarkerSize', 30);
grid on;
axis equal;

end