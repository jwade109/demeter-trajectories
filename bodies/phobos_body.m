function body = phobos_body()

body = astronomical_body();
body.name = 'Phobos';
body.mu = 716100;
body.radius = 11100;

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
body.orbit = elements2orbit(9376*1000,... % SMA
            0.0151,... % eccentricity
            deg2rad(3),... % inclination
            deg2rad(0),... % right ascension
            deg2rad(0),... % argument of periapsis
            deg2rad(45),... % true anomaly
            mars_body());
body.orbit.epoch = datetime('01-jan-2020');

body.soi = hill_sphere(body);

end