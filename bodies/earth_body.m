function body = earth_body()

body = astronomical_body();
body.name = 'Earth';
body.mu = 3.986e14;
body.radius = 6371000;

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
body.orbit = elements2orbit(149654521.711853*1000,... % SMA
            0.017126,... % eccentricity
            deg2rad(23.437),... % inclination
            deg2rad(0.002),... % right ascension
            deg2rad(104.051),... % argument of periapsis
            deg2rad(355.687),... % true anomaly
            sol_body());
body.orbit.epoch = datetime('01-jan-2020');

body.soi = hill_sphere(body);

end