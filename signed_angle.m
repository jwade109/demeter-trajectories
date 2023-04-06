function theta = signed_angle(u, v, n)

n = n/norm(n);
costheta = dot(u, v)/(norm(u)*norm(v));
sintheta = dot(cross(n, u), v)/(norm(u)*norm(v));

if sintheta < 0
    theta = 2*pi - acos(costheta);
else
    theta = acos(costheta);
end

end
