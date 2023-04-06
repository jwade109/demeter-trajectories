function lowthrust = lunar_spiral(epoch)

if nargin < 1
    epoch = datetime('01-jan-2020');
end

lowthrust = struct;

lowthrust.initial = rv2orbit(...
    [6871000; 0; 0], ...
    [0; 7.616556585247121e+03; 0], ...
    earth(), epoch);
lowthrust.path = load('lunar_spiral_path.mat');
lowthrust.path = lowthrust.path.pos;
lowthrust.tof = days(days(minutes(334587)));
lowthrust.dv = 6.691680000006302e+03;
lowthrust.dt = minutes(3);
lowthrust.acc = 3.333333333333333e-04;
lowthrust.final = rv2orbit(...
    [-2.409667357384538e+08; -2.854878494382951e+08; 0], ...
    [7.686644359395175e+02; -6.892566432811055e+02; 0], ...
    earth(), lowthrust.initial.epoch + lowthrust.tof);
lowthrust.type = 'low-thrust trajectory';

end