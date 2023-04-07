function orbit = mars_stationary(index)

m = mars_body();
orbit = elements2orbit(204262.51*1000,...
    0.3, 0.1, index*deg2rad(120), 0, pi, m);
orbit.epoch = m.orbit.epoch;

end