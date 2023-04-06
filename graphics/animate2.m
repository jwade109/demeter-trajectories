function animate2(orbits, timespans, colors)

o = numel(orbits);
n = 1000;
pos_history = zeros(n, 3, o)*NaN;
% filename = 'animation.gif';

min_min = datetime(Inf, Inf, Inf);
max_max = datetime(0, 0, 0);
for i = 1:o
    min = timespans(i, 1);
    max = timespans(i, 2);
    if min < min_min
        min_min = min;
    end
    if max > max_max
        max_max = max;
    end
end

for i = 1:o
    min = timespans(i, 1);
    max = timespans(i, 2);
    lower = floor((min - min_min)/(max_max - min_min)*n) + 1;
    upper = floor((max - min_min)/(max_max - min_min)*n);
    pos_history(lower:upper,:,i) = history(orbits{i},...
        linspace(min, max, upper - lower + 1));
end

for i = 1:o
    eci2(orbits{i});
    if strcmp(colors{i}, '')
        an = animatedline('Color', 'red', 'LineWidth', 10,...
            'MaximumNumPoints', 1);
    else
        an = animatedline('Color', colors{i}, 'LineWidth', 12);
    end
    orbits{i}.an = an;
    orbits{i}.sc = scatter(NaN, NaN, 180, 'filled');
end

set(gcf, 'Position', get(0, 'Screensize'));
view([0, 90]);
set(gca,'visible','off');
set(gca, 'Color', 'black');
set(gcf, 'Color', 'black');
% gif(filename, 'DelayTime', 1/30, 'frame', gcf);

for i = 1:n
    for j = 1:o
        pt = pos_history(i,:,j);
        addpoints(orbits{j}.an, pt(1), pt(2), pt(3));
        set(orbits{j}.sc, 'xdata', pt(1),...
            'ydata', pt(2), 'zdata', pt(3))
    end
%     if mod(i, 4) == 0
%         drawnow;
%         gif;
%     end
end

% for i = 1:50
% gif;
% end
drawnow;

end