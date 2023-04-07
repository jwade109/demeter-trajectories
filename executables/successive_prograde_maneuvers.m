clear;
clc;
close all;

earth = earth_body();

dv = 5;
N = 1000;
dt = minutes(5);
orbits(1:N) = keplerian_orbit();
for i = 1:N
    if i == 1
        orbits(i) = random_viable_orbit(earth);
        eci(orbits(i));
    else
        prev = orbits(i-1);
        next = propagate_to(prograde(prev, dv), prev.epoch + dt);
        orbits(i) = next;
        plot3(next.r(1), next.r(2), next.r(3), 'k.');
        if mod(i, 20) == 0
            eci(next);
        end
        pause(0.1);
        if next.e > 1
            break;
        end
    end
end

% eci(orbits);