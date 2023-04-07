clear;
clc;
close all;

luna = luna_body();

dt = minutes(30);
acc = 50/(200*1000)*seconds(dt);

parking = parking_orbit(earth_body(), km(400));
impulsive = prograde(parking, 3700);
crew = continuous_escape(parking, impulsive.vinf, dt, acc);

eci({parking, luna, crew});