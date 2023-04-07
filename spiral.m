function [dv, tof] = spiral(initial_radius, final_radius, acc, primary_body)

tof = days(days(seconds(...
    abs(sqrt(primary_body.mu)/acc * (initial_radius^-0.5 - final_radius^-0.5)))));
dv = acc*seconds(tof);

end
