function man = maneuver(name, stages, dv, burning_stage)

man = struct;
man.type = 'maneuver';
man.name = name;
man.stages = stages;
man.burning_stage = burning_stage;
man.burning_stage_name = burning_stage.name;
man.dv = dv;
man.engine = burning_stage.engines;
man.engine_name = burning_stage.engines.name;
man.mass_fraction = mass_fraction(burning_stage.engines.isp, dv);

end