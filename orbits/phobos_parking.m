function orbit = phobos_parking()

p = phobos();
orbit = elements2orbit(p.radius + 3*1000,...
    0, 0.01, 0, 0, 0, p);
orbit.epoch = p.orbit.epoch;

end