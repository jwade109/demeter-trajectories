function bodies = gravity_family_tree(orbital)

if numel(orbital) > 1
    error("Don't pass more than one object into this function.")
end

body = get_primary_body(orbital);

bodies(1:3) = astronomical_body();
bodies(1) = body;

i = 2;
while ~isempty(body.orbit) && i <= 3
    body = body.orbit.primary_body;
    bodies(i) = body;
    i = i + 1;
end

bodies = bodies(1:i-1);

end
