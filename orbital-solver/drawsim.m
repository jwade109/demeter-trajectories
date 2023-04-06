function drawsim(sim)

figure;
hold on;
grid on;
daspect([1, 1, 1]);
last = sim.last;

bodies = [last.primary, last.secondary];

for i = 1:numel(bodies)
    body = bodies(i);
    r = body.radius;
    pos = body.position;
    t = 0:pi/32:2*pi;
    x = r*cos(t) + pos(1);
    y = r*sin(t) + pos(2);
    plot(x, y);
end

for i = 1:numel(last.spacecraft)
    trajectory = [0, 0, 0];
    for j = 1:numel(sim.evolution)
        trajectory(j,:) = sim.evolution(j).spacecraft(i).position;
    end
    plot(trajectory(:,1), trajectory(:,2), 'k.-');
end

end