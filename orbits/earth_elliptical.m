function orbit = earth_elliptical()

e = earth_body();
l = luna_body();
rp = e.radius + 500*1000;
ra = l.orbit.a*1.06;
orbit = elements2orbit((rp + ra)/2,...
    eccentricity(ra, rp), 0, 0, 0, 0, e);
orbit.epoch = e.orbit.epoch;

end