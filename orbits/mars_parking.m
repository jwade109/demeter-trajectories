function orbit = mars_parking(radius)

if nargin < 1
    radius = 500;
end

m = mars_body();
orbit = elements2orbit(m.radius + radius*1000,...
    0, 0, 0, 0, 0, m);
orbit.epoch = m.orbit.epoch;

end