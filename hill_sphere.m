function rh = hill_sphere(body)

mu1 = body.mu;
mu2 = body.orbit.mu;
rp = body.orbit.a;

rh = rp*(mu1/mu2)^(2/5);

end