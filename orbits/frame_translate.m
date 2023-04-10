function xyzoff = frame_translate(body, reference_body)

xyzoff = zeros(3, 1);

if isequal(body, reference_body)
    return
end

if body_level(body) <= body_level(reference_body)
    error("Reference body is higher in the hierarchy than subject")
end

b = body;
xyzoff = [0; 0; 0];
while ~isequal(b, reference_body) && body_level(b) > 0
%     fprintf("%s -> %s\n", b.name, b.orbit.primary_body.name);
    xyzoff = xyzoff + b.orbit.r;
    b = b.orbit.primary_body;
end

% fprintf("%s -> %s: %0.1f %0.1f %0.1f (dist %0.2f AU)\n", ...
%     body.name, reference_body.name, xyzoff, norm(xyzoff) / au(1));

end