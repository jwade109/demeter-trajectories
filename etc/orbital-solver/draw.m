function draw(body)

t = 0:pi/32:2*pi;
x = cos(t);
y = sin(t);

for i = 1:size(x, 1)
    x(i,:) = x(i,:)*body.radius + body.position(1);
    y(i,:) = y(i,:)*body.radius + body.position(2);
end

plot(x, y);

end