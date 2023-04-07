clear;
clc;
close all;

luna = luna_body();
parking = parking_orbit(earth_body(), km(400));
impulsive = prograde(parking, 3600);

dt = minutes(10);
acc = 50/(200*1000)*seconds(dt);

mav_kick = prograde(parking, 2000);
crew = continuous_escape(mav_kick, impulsive.vinf, dt, acc);

eci(parking, impulsive, mav_kick, luna.orbit, crew);