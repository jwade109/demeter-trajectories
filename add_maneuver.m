function list = add_maneuver(list, stages, burning_stage, name, dv)

event = maneuver(name, stages, dv, burning_stage);
list = [list; event];

end