clear;
clc;
close all;

earth = earth_body();
luna = luna_body();

N = 20;
M = 12;

orbits = cell(N + M, 1);

for i = 1:N
    orbits{i} = random_orbit_around(earth);
end

for i = 1:M
    orbits{N + i} = random_orbit_around(luna);
end

orbits{1} = earth;
orbits{2} = luna_body();

eci(orbits);
