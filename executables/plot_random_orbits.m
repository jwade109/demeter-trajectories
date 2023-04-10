clear;
clc;
close all;

earth = earth_body();

N = 20;

orbits = cell(N, 1);

for i = 1:N
    orbits{i} = random_viable_orbit(earth);
end

orbits{1} = earth;
orbits{2} = luna_body();
% orbits{3} = sol_body();

eci(orbits);
