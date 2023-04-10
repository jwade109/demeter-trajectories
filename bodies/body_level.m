function level = body_level(body)

level = 0;

b = body;
while ~isempty(b.orbit)
    b = b.orbit.primary_body;
    level = level + 1;
end

end