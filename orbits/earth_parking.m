function orbit = earth_parking(radius)

if nargin < 2
    radius = 500000;
end

orbit = parking_orbit(earth_body(), radius);

end