function orbit = random_orbit_around(primary_body)

sma = primary_body.radius * (rand() * 30 + 1.5);
ecc = sqrt(rand() * 0.85) + 0.1;
inc = rand() * pi - pi/2;
raan = rand() * 2 * pi;
argp = rand() * 2 * pi;
nu = rand() * 2 * pi;

orbit = elements2orbit(sma, ecc, inc, raan, argp, nu, primary_body);

end