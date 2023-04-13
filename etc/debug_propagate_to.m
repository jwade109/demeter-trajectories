clear;
clc;
close all;

load('propagate_to_bug.mat');

eci({earth_body(), prev});

for i = 0
    dt = seconds(i);
    n = propagate_to(prev, prev.epoch + dt);
    eci({n});
end
