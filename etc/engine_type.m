function eng = engine_type(name, isp, thrust, mass, cost, power_required)

g = 9.81;

eng = struct;
eng.type = 'engine';
eng.name = name;
eng.isp = isp;
eng.thrust = thrust;
eng.mass = mass;
eng.cost = cost;
eng.mass_flow_rate = eng.thrust/(eng.isp*g);
eng.power_req = power_required;

end