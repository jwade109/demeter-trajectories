function R = pqw2ijk(raan, inc, argp)

R = [  cos(raan)*cos(argp)-sin(raan)*sin(argp)*cos(inc),...
      -cos(raan)*sin(argp)-sin(raan)*cos(argp)*cos(inc),...
       sin(raan)*sin(inc);...
       sin(raan)*cos(argp)+cos(raan)*sin(argp)*cos(inc),...
      -sin(raan)*sin(argp)+cos(raan)*cos(argp)*cos(inc),...
      -cos(raan)*sin(inc);...
       sin(argp)*sin(inc),...
       cos(argp)*sin(inc),...
       cos(inc)];
   
end