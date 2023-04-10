clear;
clc;
close all;

earth = earth_body();

eci({earth, luna_body()});

dv = 1;
N = 100000;
dt = minutes(10);
orbits(1:N) = keplerian_orbit();
for i = 1:N
    if i == 1
        orbits(i) = random_orbit_around(earth);
        eci({orbits(i)});
    else
        prev = orbits(i-1);
        next = propagate_to(prograde(prev, dv), prev.epoch + dt);
        orbits(i) = next;
        plot3(next.r(1), next.r(2), next.r(3), 'k.');
        if mod(i, 100) == 0
            eci({next});
        end
        pause(0.02);
        if next.e > 1
            break;
        end
    end
end

% eci(orbits);