function animate(orbits, timespans, colors)

% orbits = varargin;

o = numel(orbits);
timespans = [];

% for i = 1:o
%     orb = orbits{i};
%     if ~isfield(orb, 'type')
%         warning("Degenerate struct lacks type information");
%     elseif strcmp(orb.type, 'low-thrust trajectory')
%         ts = [orb.initial.epoch, orb.final.epoch];
%     elseif isfield(orb, 'stop')
%         ts = [orb.epoch, orb.stop];
%     else
%         ts = [orb.epoch, orb.epoch + orb.T];
%     end
%     timespans = [timespans; ts];
% end

min_min = datetime(Inf, Inf, Inf);
max_max = datetime(0, 0, 0);
for i = 1:o
    mi = timespans(i, 1);
    ma = timespans(i, 2);
    if mi < min_min
        min_min = mi;
    end
    if ma > max_max
        max_max = ma;
    end
end

n = ceil(days(max_max - min_min)*frames_per_day);
pos_history = zeros(n, 3, o)*NaN;

for i = 1:o
    mi = timespans(i, 1);
    ma = timespans(i, 2);
    lower = max(floor((mi - min_min)/(max_max - min_min)*n), 1);
    upper = floor((ma - min_min)/(max_max - min_min)*n);
    if lower >= upper
        continue;
    end
    orb = orbits{i};
    if isfield(orb, 'type') && strcmp(orb.type, 'low-thrust trajectory')
        sample = round(linspace(1, size(orb.path, 1),...
            numel(lower:upper)));
        pos_history(lower:upper,:,i) = orb.path(sample,:);
    else
        pos_history(lower:upper,:,i) = history(orbits{i},...
            linspace(mi, ma, upper - lower + 1));
    end
end

for i = 1:o
    orb = orbits{i};
    if isfield(orb, 'type') && strcmp(orb.type, 'low-thrust trajectory')
        plot3(orb.path(:,1), orb.path(:,2), orb.path(:,3));
    else
        eci(orb);
    end
    orbits{i}.an = animatedline('Color', 'red', 'LineWidth', 5,...
        'MaximumNumPoints', 5);
    orbits{i}.sc = scatter(NaN, NaN, 'filled');
end

view([0, 90]);
% set(gca, 'visible', 'off');
fprintf("Pausing animation.\n");
waitforbuttonpress();
fprintf("Animating.\n");
set(gcf, 'CurrentCharacter', '@');

for i = 1:n
    for j = 1:o
        try
            pt = pos_history(i,:,j);
            addpoints(orbits{j}.an, pt(1), pt(2), pt(3));
            set(orbits{j}.sc, 'xdata', pt(1),...
                'ydata', pt(2), 'zdata', pt(3));
        catch
            return;
        end
    end
    curr_time = (max_max - min_min)*i/n + min_min;
    if mod(i, 3) == 0
        title(sprintf("Senario from %s to %s: %s\n", ...
            datestr(min_min), datestr(max_max), ...
            datestr(curr_time)));
        drawnow;
    end
    try
        k = get(gcf, 'CurrentCharacter');
        if k ~= '@'
            fprintf("Paused.\n");
            waitforbuttonpress();
            fprintf("Resumed.\n");
            set(gcf, 'CurrentCharacter', '@');
        end
    catch
        return;
    end
end

title(sprintf("Senario from %s to %s: %s\n", ...
    datestr(min_min), datestr(max_max), datestr(max_max)));
drawnow;

% set(gca,'visible','off')

end