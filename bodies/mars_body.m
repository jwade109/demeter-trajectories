function body = mars_body()

body = astronomical_body();
body.name = 'Mars';
body.mu = 4.282e13;
body.radius = 3396200;

body.orbit = elements2orbit(227931824.974689*1000,... % SMA
            0.093500,... % eccentricity
            deg2rad(24.677),... % inclination
            deg2rad(3.367),... % right ascension
            deg2rad(333.102),... % argument of periapsis
            deg2rad(237.676),... % true anomaly
            sol_body());
body.orbit.epoch = datetime('01-jan-2020');

body.soi = hill_sphere(body);

end