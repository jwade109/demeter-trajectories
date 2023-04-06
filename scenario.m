clear;
clc;
close all;

earth = earth();
mars = mars();
deimos = deimos();
phobos = phobos();
luna = luna();

% scenario_do({deimos, phobos, mars_parking(),...
%     mars_stationary(1), mars_stationary(2), mars_stationary(3)});

% scenario_do({luna, earth_elliptical()});

patched_propagate(earth_elliptical(), luna, days(35));

function scenario_do(objects, varargin)

frames = cell(0, 0);

for i = 1:numel(objects)
    obj = objects{i};
    if ~isfield(obj, 'type')
        disp(obj);
        error("Malformed struct has no 'type' field!");
    end
    
    if strcmp(obj.type, 'body')
        frames = [frames obj.orbit.primary_body.name];
    end
    
    if strcmp(obj.type, 'orbit')
        frames = [frames obj.primary_body.name];
    end
end

frames = unique(frames);

for i = 1:numel(frames)

    current_frame = frames{i};
    figure;
    
    for j = 1:numel(objects)
        obj = objects{j};
        if ~isfield(obj, 'type')
            disp(obj);
            error("Malformed struct has no 'type' field!");
        end

        if strcmp(obj.type, 'body') && ...
           strcmp(obj.orbit.primary_body.name, current_frame)
            eci(obj);
        elseif strcmp(obj.type, 'orbit') && ...
           strcmp(obj.primary_body.name, current_frame)
            eci(obj);
        end
    end
    
    title(upper(current_frame));
end

end

function patched_propagate(orbit, secondary, period)

fprintf("%f\n", seconds(period));

N = 100;
orbit_pos = history(orbit, linspace(orbit.epoch,...
    orbit.epoch + period, N));
secondary_pos = history(secondary.orbit, linspace(orbit.epoch,...
    orbit.epoch + period, N));

% eci(orbit);
% eci(secondary);

% hold on;
% grid on;

for i = 1:N

    op = orbit_pos(i,:);
    sp = secondary_pos(i,:);
    dist = norm(op - sp);
    fprintf("%0.1f %0.1f %0.1f / %0.1f %0.1f %0.1f / %0.1f\n", ...
        op, sp, dist);
    
    if dist < secondary.soi
%         plot3(op(:,1), op(:,2), op(:,3), 'k*');
%         plot3(sp(:,1), sp(:,2), sp(:,3), 'r*');
        warning("Too close! %d\n", i);
        break;
    end
    
end
    
% plot3(orbit_pos(1:i,1), orbit_pos(1:i,2), orbit_pos(1:i,3), 'k-');
% plot3(secondary_pos(1:i,1), secondary_pos(1:i,2), secondary_pos(1:i,3), 'r-');

plot_distance(orbit, secondary.orbit, secondary.orbit.epoch, ...
    secondary.orbit.epoch + secondary.orbit.T);

animate({orbit, secondary.orbit},...
    [[orbit.epoch, orbit.epoch + period*i/N]; ...
     [orbit.epoch, orbit.epoch + period*i/N]],...
     {'', ''});
 


end

function plot_distance(o1, o2, t1, t2)

N = 100;
X = linspace(0, seconds(t2 - t1), N);
Y = zeros(N,1);

for i = 1:N
    x = X(i);
    Y(i) = distance_between(o1, o2, seconds(x) + t1);
end

plot(X, Y);
title(sprintf("Distance between two orbits, %s to %s", ...
    datestr(t1), datestr(t2)));

end

function dist = distance_between(o1, o2, time)

o1 = propagate_to(o1, time);
o2 = propagate_to(o2, time);

dist = norm(o1.r - o2.r);

end



