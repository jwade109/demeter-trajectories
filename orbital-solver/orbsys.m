function sys = orbsys(time, primary, secondary, spacecraft)

sys = struct;
sys.time = time;
sys.primary = primary;
sys.secondary = secondary;
sys.spacecraft = spacecraft;

end