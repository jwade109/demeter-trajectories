clear;
close all;
clc;

% isp, thrust, mass, cost, power
busek = engine_type('busek', 2210, 0.449, 25, 35e6, 8); 
busek_block = engine_block(busek, 125);
fprintf("Cargo\tIMLEO\tProp\tBurn Time\tDays\n");

for i = 1:4

transfer_stage = stage('Transfer Stage', 30000, busek_block);
cargo = stage('Cargo', i*30000, busek_block);
acc = 1/5000;
R_earth = 6378000;
parking_radius = R_earth + km(1000);

nodes = [];
nodes = add_maneuver(nodes, [transfer_stage, cargo], transfer_stage, 'LEO-LOPG',...
    spiral(parking_radius, radius('moon'), acc, 'earth'));
nodes = add_maneuver(nodes, [transfer_stage, cargo], transfer_stage, 'LOPG-TMI',...
    spiral(radius('earth'), radius('mars'), acc, 'sun'));

[tables, time, imleo, prop] = compile(nodes);

fprintf("%d\t%d\t%d\t%d\t%d%%\n",...
    round(cargo.dry_mass/1000),...
    round(imleo/1000),...
	round(prop/1000),...
    round(days(time)),...
    round(cargo.dry_mass/imleo*100))
end


for i = 1:200

transfer_stage = stage('Transfer Stage', 30000, busek_block);
cargo = stage('Cargo', i*1000, busek_block);
acc = 1/5000;
R_earth = 6378000;
parking_radius = R_earth + km(1000);

nodes = [];
nodes = add_maneuver(nodes, [transfer_stage, cargo], transfer_stage, 'LEO-LOPG',...
    spiral(parking_radius, radius('moon'), acc, 'earth'));
nodes = add_maneuver(nodes, [transfer_stage, cargo], transfer_stage, 'LOPG-TMI',...
    spiral(radius('earth'), radius('mars'), acc, 'sun'));

[tables, time, imleo, prop] = compile(nodes);

fprintf("%f\t%f\n",...
    cargo.dry_mass/1000,...
    cargo.dry_mass/imleo*100)
end