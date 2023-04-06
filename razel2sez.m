function X = razel2sez(R)

% converts a range, azimuth, and elevation
% to coordinates in the SEZ frame

r = R(1);
az = R(2);
el = R(3);

S = -r*cos(el)*cos(az);
E = r*cos(el)*sin(az);
Z = r*sin(el);

X = [S E Z];

end