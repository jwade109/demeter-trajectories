function R = ijk2sez(theta_g, lat)

tg = theta_g;

R = [sin(lat)*cos(tg) sin(lat)*sin(tg) -cos(lat);
     -sin(tg) cos(tg) 0;
     cos(lat)*cos(tg) cos(lat)*sin(tg) sin(lat)];

end