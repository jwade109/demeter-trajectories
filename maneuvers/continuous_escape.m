function trajectory = continuous_escape(initial, vinf, dt, dv)

[success, file, cache] = request_cache('continuous_escape', ...
    initial, vinf, dt, dv);
if success
    trajectory = file.trajectory;
    return;
end

max_dur = days(500);

trajectory.initial = initial;
trajectory.type = 'low-thrust trajectory';
trajectory.dt = dt;
trajectory.acc = dv/seconds(dt);

iters = ceil(max_dur/dt);
trajectory.path = zeros(iters, 3);
total_dv = 0;
hold on;

last = 1;
for i = 1:iters
    if i == 1
        new_vel = add_along_velocity(initial, dv);
        total_dv = total_dv + norm(initial.v - new_vel);
        start = rv2orbit(initial.r, new_vel, ...
            initial.primary_body, initial.epoch);
        next = propagate_to(start, start.epoch + dt);
        prev = next;
        final = next;
        trajectory.path(i,:) = next.r;
    else
        new_vel = add_along_velocity(prev, dv);
        total_dv = total_dv + norm(new_vel - prev.v);
        prev = rv2orbit(prev.r, new_vel, ...
            prev.primary_body, prev.epoch);
        next = propagate_to(prev, prev.epoch + dt);
        prev = next;
        final = next;
        trajectory.path(i,:) = next.r;
%         if norm(next.r) > initial.primary_body.soi*10
%             fprintf("Stopped -- reached infinity\n");
%             break;
%         end
        if isfield(next, 'vinf') && next.vinf >= vinf
            fprintf("Stopped -- reached required vinf\n");
            break;
        end
    end
    
%     if mod(i, 800) == 0
%         hold on;
%         plot3(trajectory.path(last:i,1), trajectory.path(last:i,2), ...
%             trajectory.path(last:i,3), 'k-');
%         drawnow;
%         last = i;
%     end

    fprintf("%0.2f %0.2f m/s %0.1f days\n", i/iters*100,...
        total_dv, days(dt*i));
    title(sprintf("%s", datestr(initial.epoch + dt*i)));
end

trajectory.path = trajectory.path(1:i,:);
trajectory.tof = days(days(dt*i));
trajectory.final = final;
trajectory.dv = total_dv;

save(cache, 'trajectory');

end

function v = add_along_velocity(initial, dv)

v = initial.v + initial.v/norm(initial.v)*dv;

end
