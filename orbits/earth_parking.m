function orbit = earth_parking(radius)

if nargin < 1
    radius = 500000;
end

e = earth();
orbit = elements2orbit(e.radius + radius,...
    0, 0, 0, 0, 0, e);
orbit.epoch = e.orbit.epoch;

end