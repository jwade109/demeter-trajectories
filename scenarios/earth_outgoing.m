clear;
clc;
close all;

luna = luna();

dt = minutes(30);
acc = 50/(200*1000)*seconds(dt);

parking = earth_parking();
impulsive = prograde(parking, 3700);
crew = continuous_escape(parking, impulsive.vinf, dt, acc);

eci(parking, luna.orbit, crew);