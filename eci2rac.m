function R = eci2rac(X)

x = X(1);
y = X(2);
z = X(3);

clear pi;
r = sqrt(x^2 + y^2 + z^2);
ra = atan2(y, x);
if ra < 0
    ra = 2*pi + ra;
end
dec = asin(z/r);

R = [r, ra, dec]';

end