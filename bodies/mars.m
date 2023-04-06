function body = mars()

body = struct;
body.type = 'body';
body.name = 'mars';
body.mu = mu('mars');
body.radius = 3396200;

body.orbit = elements2orbit(227931824.974689*1000,... % SMA
            0.093500,... % eccentricity
            deg2rad(24.677),... % inclination
            deg2rad(3.367),... % right ascension
            deg2rad(333.102),... % argument of periapsis
            deg2rad(237.676),... % true anomaly
            sun());
body.orbit.epoch = datetime('01-jan-2020');
        
body.soi = hill_sphere(body);

end