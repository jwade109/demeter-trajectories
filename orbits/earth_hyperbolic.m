function orbit = earth_hyperbolic()

e = earth_body();
ep = parking_orbit(e, km(400));
orbit = rv2orbit(ep.r, ep.v*sqrt(2), e, e.orbit.epoch);

end