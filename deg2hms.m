function hms = deg2hms(deg)

clear pi;
deg_per_hr = pi/12 * 180/pi;
deg_per_min = pi/(12*60) * 180/pi;
deg_per_sec = pi/(12*60*60) * 180/pi;

hms = struct;
hms.hr = floor(deg/deg_per_hr);
hms.min = floor((deg - hms.hr*deg_per_hr)/deg_per_min);
hms.sec = (deg - hms.hr*deg_per_hr - hms.min*deg_per_min)/deg_per_sec;

end