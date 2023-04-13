function tab = johnny_plot(orbits, start, stop)

figure;
hold on;
grid on;

tab = table;
t = linspace(start, stop, 200);
tab.t = t';
tab.R = zeros(numel(t), numel(orbits));

for i = 1:numel(orbits)

o = orbits{i};
r = johnny_plot_orbit(o, t);
tab.R(:,i) = r;
plot(t, r, '.-');

end

ylabel("Radius from the Sun (km)");
title("Time History of Radius from Sun");

end

function r = johnny_plot_orbit(orbit, t)

pos_history = history(orbit, t);
r = vecnorm(pos_history, 2, 2);

end