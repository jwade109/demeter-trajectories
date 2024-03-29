function body = luna_body()

body = astronomical_body();
body.name = 'Luna';
body.mu = 4.904e12;
body.radius = 1738100;

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
body.orbit = elements2orbit(384399.4*1000,... % SMA
            0.0549,... % eccentricity
            deg2rad(1),... % inclination
            deg2rad(10),... % right ascension
            deg2rad(120),... % argument of periapsis
            deg2rad(56),... % true anomaly
            earth_body());
body.orbit.epoch = datetime('01-jan-2020');

body.soi = hill_sphere(body);

end