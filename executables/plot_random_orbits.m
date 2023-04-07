clear;
clc;
close all;

body = earth_body();

N = 30;
orbits(1:N) = keplerian_orbit();
for i = 1:N
    orbits(i) = random_viable_orbit(body);
end

eci(orbits);
