function orbit = parking_orbit(primary_body, radius)

if nargin < 2
    radius = 500000;
end

orbit = elements2orbit(primary_body.radius + radius,...
    0, 0, 0, 0, 0, primary_body);
orbit.epoch = primary_body.orbit.epoch;

end