clear;
close all;
clc;

% isp, thrust, mass, cost, power
busek = engine_type('busek', 2210, 0.449, 25, 35e6, 8); 
busek_block = engine_block(busek, 125);

fprintf("Cargo\tIMLEO\tProp\tBurn Time\tDays\n");
for i = 1:4

orbiter = stage('Orbiter', 30000, busek_block);
cargo = stage('Cargo', 30000*i, busek_block);
acc = 1/5000;
R_earth = 6378000;
parking_radius = R_earth + km(1000);

nodes = [];
nodes = add_maneuver(nodes, [orbiter, cargo], orbiter, 'LEO-LOPG',...
    spiral(parking_radius, radius('moon'), acc, 'earth'));
nodes = add_maneuver(nodes, [orbiter, cargo], orbiter, 'LOPG-TMI',...
    spiral(radius('earth'), radius('mars'), acc, 'sun'));
nodes = add_maneuver(nodes, orbiter, orbiter, 'TMI-TEI',...
    spiral(radius('mars'), radius('earth'), acc, 'sun'));
nodes = add_maneuver(nodes, orbiter, orbiter, 'LOPG-LEO',...
    spiral(radius('moon'), parking_radius, acc, 'earth'));

[tables, time, imleo, prop] = compile(nodes);
fprintf("%d\t%d\t%d\t%d\t%d%%\n",...
    round(cargo.dry_mass/1000),...
    round((imleo-orbiter.dry_mass)/1000),...
	round(prop/1000),...
    round(days(time)),...
    round(cargo.dry_mass/(imleo-orbiter.dry_mass)*100))

end

for i = 1:200

orbiter = stage('Orbiter', 30000, busek_block);
cargo = stage('Cargo', i*1000, busek_block);
acc = 1/5000;
R_earth = 6378000;
parking_radius = R_earth + km(1000);

nodes = [];
nodes = add_maneuver(nodes, [orbiter, cargo], orbiter, 'LEO-LOPG',...
    spiral(parking_radius, radius('moon'), acc, 'earth'));
nodes = add_maneuver(nodes, [orbiter, cargo], orbiter, 'LOPG-TMI',...
    spiral(radius('earth'), radius('mars'), acc, 'sun'));
nodes = add_maneuver(nodes, orbiter, orbiter, 'TMI-TEI',...
    spiral(radius('mars'), radius('earth'), acc, 'sun'));
nodes = add_maneuver(nodes, orbiter, orbiter, 'LOPG-LEO',...
    spiral(radius('moon'), parking_radius, acc, 'earth'));

[tables, time, imleo, prop] = compile(nodes);
fprintf("%f\t%f\n",...
    cargo.dry_mass/1000,...
    cargo.dry_mass/(imleo-orbiter.dry_mass)*100)

end

