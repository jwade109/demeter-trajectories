function body = deimos()

body = struct;
body.type = 'body';
body.name = 'deimos';
body.mu = mu('deimos');
body.radius = 6200;

% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
body.orbit = elements2orbit(23463.2*1000,... % SMA
            0.00033,... % eccentricity
            deg2rad(-2),... % inclination
            deg2rad(34),... % right ascension
            deg2rad(260),... % argument of periapsis
            deg2rad(45),... % true anomaly
            mars());
body.orbit.epoch = datetime('01-jan-2020');

body.soi = hill_sphere(body);

end