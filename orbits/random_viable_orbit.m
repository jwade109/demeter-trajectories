function orbit = random_viable_orbit(primary_body)

apsides = [rand() * km(20000) + primary_body.radius + km(500),...
           rand() * km(200000) + primary_body.radius + km(500)];
semi_major = mean(apsides);
semi_minor = sqrt(prod(apsides));

ecc = sqrt(1 - semi_minor^2 / semi_major^2);
inc = rand() * pi - pi/2;
raan = rand() * 2 * pi;
argp = rand() * 2 * pi;
nu = rand() * 2 * pi;

orbit = elements2orbit(semi_major, ecc, inc, raan, argp, nu, primary_body);

end