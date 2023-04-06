function block = engine_block(engine, number)

block = struct;
block.type = 'engine block';
block.base_engine_type = engine;

block.name = engine.name;
block.number = number;
block.isp = engine.isp;
block.thrust = engine.thrust*number;
block.mass = engine.mass*number;
block.cost = engine.cost*number;
block.mass_flow_rate = engine.mass_flow_rate*number;
block.power_req = engine.power_req*number;

end