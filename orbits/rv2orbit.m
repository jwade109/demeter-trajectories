function orbit = rv2orbit(r, v, primary_body, time)

if ~isa(primary_body, 'astronomical_body')
    error("primary_body is of invalid type %s", class(primary_body));
end

orbit = keplerian_orbit();
orbit.r = real(r);
orbit.v = real(v);
clear r v;
orbit.mu = primary_body.mu;
orbit.epoch = time;
orbit.primary_body = primary_body;

I = [1; 0; 0];
K = [0; 0; 1];

orbit.h = cross(orbit.r, orbit.v);

if norm(orbit.r) == 0
    error("Degenerate orbit: r is zero vector");
end

if norm(orbit.v) == 0
    error("Degenerate orbit: v is zero vector");
end

if norm(orbit.h) == 0
    error("Degenerate orbit: r and v are colinear");
end

orbit.e_vector = cross(orbit.v, orbit.h)/orbit.mu - orbit.r/norm(orbit.r);
if norm(orbit.e_vector) == 0
    orbit.e = 0;
    orbit.e_vector = [1; 0; 0];
else
    orbit.e = norm(orbit.e_vector);
end
orbit.p = norm(orbit.h)^2/orbit.mu;
orbit.B = orbit.e*orbit.mu;

orbit.P = orbit.e_vector/orbit.e;
if orbit.e == 0
    orbit.P = [1; 0; 0];
end
orbit.W = orbit.h./norm(orbit.h);
orbit.Q = cross(orbit.W, orbit.P);

orbit.a = orbit.p/(1 - orbit.e^2);
orbit.rp = orbit.a*(1 - orbit.e);
orbit.ra = orbit.a*(1 + orbit.e);
orbit.n = cross(K, orbit.h);
orbit.i = real(acos(dot(K, orbit.h/norm(orbit.h))));
orbit.raan = real(acos(dot(I, orbit.n/norm(orbit.n))));

orbit.in_track = orbit.v/norm(orbit.v);
orbit.radial = orbit.r/norm(orbit.r);
orbit.cross_track = cross(orbit.radial, orbit.in_track)/...
    norm(cross(orbit.radial, orbit.in_track));

if orbit.n(2) < 0
    orbit.raan = 2*pi - orbit.raan;
end

orbit.argp = real(acos(dot(orbit.n/norm(orbit.n), orbit.e_vector/orbit.e)));
if orbit.e == 0
    orbit.argp = 0;
elseif orbit.e_vector(3) < 0
    orbit.argp = 2*pi - orbit.argp;
end

if orbit.e == 0 && norm(orbit.n) == 0
    orbit.nu = acos(orbit.r(1)/norm(orbit.r));
    if orbit.v(1) > 0
        orbit.nu = 2*pi - orbit.nu;
    end
elseif orbit.e == 0
    orbit.nu = real(acos(dot(orbit.n, orbit.r)/ ...
        (norm(orbit.n)*norm(orbit.r))));
else
    orbit.nu = real(acos(dot(orbit.e_vector/orbit.e, orbit.r/norm(orbit.r))));
end

if dot(orbit.r, orbit.Q) < 0
    orbit.nu = 2*pi - orbit.nu;
end

orbit.phi = real(acos(norm(orbit.h)/(norm(orbit.r)*norm(orbit.v))));
if orbit.nu > pi
    orbit.phi = -orbit.phi;
end

if norm(orbit.n) == 0
    try
        orbit.argp = atan2(orbit.e_vector(2), orbit.e_vector(1));
    catch
        disp("uh oh");
    end
    orbit.raan = 0;
end

orbit.energy = norm(orbit.v)^2/2 - orbit.mu/norm(orbit.r);
orbit.vesc = sqrt(2*orbit.mu/norm(orbit.r));

if orbit.e == 0
    orbit = circular(orbit);
elseif orbit.e < 1
    orbit = elliptical(orbit);
elseif orbit.e == 1
    orbit = parabolic(orbit);
elseif orbit.e > 1
    orbit = hyperbolic(orbit);
end

end

function orbit = circular(orbit)

orbit.class = 'circular';
orbit.mm = sqrt(orbit.mu/orbit.a^3);
orbit.E = atan2(sqrt(1 - orbit.e^2)*sin(orbit.nu),...
    orbit.e + cos(orbit.nu));
if orbit.E < 0
    orbit.E = orbit.E + 2*pi;
end
orbit.M = orbit.E - orbit.e*sin(orbit.E);
orbit.T = seconds(sqrt(4*pi^2*orbit.a^3/orbit.mu));
orbit.x = orbit.e*sqrt(orbit.a);

end

function orbit = elliptical(orbit)

orbit.class = 'elliptical';
orbit.mm = sqrt(orbit.mu/orbit.a^3);
orbit.E = atan2(sqrt(1 - orbit.e^2)*sin(orbit.nu),...
    orbit.e + cos(orbit.nu));
if orbit.E < 0
    orbit.E = orbit.E + 2*pi;
end
orbit.M = orbit.E - orbit.e*sin(orbit.E);
orbit.T = seconds(sqrt(4*pi^2*orbit.a^3/orbit.mu));
orbit.x = orbit.e*sqrt(orbit.a);

end

function orbit = parabolic(orbit)

orbit.class = 'parabolic';
orbit.D = tan(orbit.nu/2);
orbit.M = orbit.D + orbit.D^3/3;
orbit.vinf = 0;
orbit.T = seconds(norm(orbit.v)/norm(orbit.r));
orbit.x = 0;

end

function orbit = hyperbolic(orbit)

orbit.class = 'hyperbolic';
orbit.mm = sqrt(orbit.mu/-orbit.a^3);
orbit.F = acosh((orbit.e+cos(orbit.nu))/(1+orbit.e*cos(orbit.nu)));
orbit.M = orbit.e*sin(orbit.F) - orbit.F;
orbit.vinf = sqrt(2*orbit.energy);
orbit.T = seconds(norm(orbit.v)/norm(orbit.r));
orbit.l = orbit.a*(orbit.e^2 - 1);
orbit.x = orbit.F*sqrt(-orbit.a);

end
