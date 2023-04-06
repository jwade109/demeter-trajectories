function pos = history(orbit, timespan)

pos = zeros(numel(timespan), 3);

for i = 1:numel(timespan)
    t = timespan(i);
    new = propagate_to(orbit, t);
    pos(i,:) = new.r;
end

end