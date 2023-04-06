function X = rac2eci(R)

r = R(1);
ra = R(2);
dec = R(3);

clear pi;
x = r*cos(ra)*cos(dec);
y = r*sin(ra)*cos(dec);
z = r*sin(dec);

X = [x, y, z]';
end