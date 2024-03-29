function body = kalliope()

body = astronomical_body();
body.type = 'body';
body.name = 'Kalliope';
body.mu = 5.446e8;

% Relative ICRF Heliocentric Classical Elements, May 31st, 2020
body.orbit = elements2orbit(435381781.210340*1000,... % SMA
            0.098050,... % eccentricity
            deg2rad(33.919),... % inclination
            deg2rad(38.947),... % right ascension
            deg2rad(43.396),... % argument of periapsis
            deg2rad(263.529),... % true anomaly
            sol_body());
body.orbit.epoch = datetime('31-may-2020');

body.soi = hill_sphere(body);

end