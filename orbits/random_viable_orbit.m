function orbit = random_viable_orbit(primary_body)

sma = primary_body.radius * (rand() * 12 + 1.5);
ecc = (rand() * 0.8 + 0.1)^2;
inc = rand() * pi - pi/2;
raan = rand() * 2 * pi;
argp = rand() * 2 * pi;
nu = rand() * 2 * pi;

orbit = elements2orbit(sma, ecc, inc, raan, argp, nu, primary_body);
orbit.label = "random";

end