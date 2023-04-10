clear;
clc;
close all;

earth = earth_body();
luna = luna_body();

parking = parking_orbit(earth, km(500));
target = luna.orbit;

traj = continuous_rendezvous_do(parking, target, days(40), minutes(10), 5);

eci({traj});


function trajectory = continuous_rendezvous_do(initial, target, dur, dt, dv)

% [success, file, cache] = request_cache('continuous_rendezvous', ...
%     initial, target, dur, dt, dv);
% if success
%     trajectory = file.trajectory;
%     return;
% end

trajectory = low_thrust_trajectory();
trajectory.initial = initial;
trajectory.dt = dt;
trajectory.acc = dv/seconds(dt);

iters = ceil(dur/dt);
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
        old_vel = prev.v;
        new_vel = rendezvous(prev, dv, target);
        total_dv = total_dv + norm(new_vel - prev.v);
        prev = rv2orbit(prev.r, new_vel, ...
            prev.primary_body, prev.epoch);
        next = propagate_to(prev, prev.epoch + dt);
        prev = next;
        final = next;
        trajectory.path(i,:) = next.r;
%         if norm(old_vel - new_vel) == 0
% %             fprintf("Stopped -- circularized!\n");
%             break;
%         end
        if norm(next.r) > initial.primary_body.soi
            fprintf("Stopped -- exceeded roche limit\n");
            break;
        end
    end

    if mod(i, 500) == 0
        hold on;
        plot3(trajectory.path(last:i,1), trajectory.path(last:i,2), trajectory.path(last:i,3));
        drawnow;
        last = i;
    end

    fprintf("%d %0.2f %0.2f m/s %0.1f days\n", i, i/iters*100,...
        total_dv, days(dt*i));
    title(sprintf("%s", datestr(initial.epoch + dt*i)));
end

trajectory.path = trajectory.path(1:i,:);
trajectory.tof = days(days(dt*i));
trajectory.final = final;
trajectory.dv = total_dv;

% save(cache, 'trajectory');

end

function v = rendezvous(initial, dv, target)

if initial.ra < target.a
    v = add_along_velocity(initial, dv);
elseif abs(initial.nu - pi) < 0.1
    v = circularize(initial, dv);
else
    v = initial.v;
end

% if norm(initial.a) < target.a*0.95
%     v = add_along_velocity(initial, dv);
% % elseif initial.ra < target.a
% %     v = add_along_horizon(initial, dv);
% elseif initial.e > 0.01
%     v = circularize(initial, dv);
% else
%     v = initial.v;
% end

end

function v = circularize(initial, dv)

in_track_dir = cross(initial.h, initial.r)/norm(...
    cross(initial.h, initial.r));

desired_vel = in_track_dir*sqrt(initial.mu/norm(initial.r));
desired_dv = desired_vel - initial.v;

applied_dv = [0; 0; 0];
if norm(desired_dv) > 0
    dir = desired_dv/norm(desired_dv);
    applied_dv = dir*min(dv, norm(desired_dv));
end

v = initial.v + applied_dv;

end

function v = add_along_velocity(initial, dv)

v = initial.v + initial.v/norm(initial.v)*dv;

end

function v = add_along_horizon(initial, dv)

v = initial.v + cross(initial.h, initial.r)/...
    norm(cross(initial.h, initial.r))*dv;

end