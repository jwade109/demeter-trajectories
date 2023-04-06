function stage = stage(name, dry_mass, engines)

stage = struct;
stage.type = 'stage';
stage.name = name;
stage.dry_mass = dry_mass;
stage.engines = engines;

end