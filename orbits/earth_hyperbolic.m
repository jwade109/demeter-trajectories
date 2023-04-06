function orbit = earth_hyperbolic()

e = earth();
ep = earth_parking();
orbit = rv2orbit(ep.r, ep.v*sqrt(2), e, e.orbit.epoch);

end