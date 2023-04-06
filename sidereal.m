function degs = sidereal(g0, days, UTC, lon)

clear pi;

days = days + hms2deg(UTC)/360;
g0.deg = hms2deg(g0);
g = mod(g0.deg + 1.0027379093*360*days, 360);

UTC.deg = hms2deg(UTC);
degs = mod(g + lon, 360);

end

