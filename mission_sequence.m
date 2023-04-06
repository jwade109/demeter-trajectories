clear;
close all;
clc;

% isp, thrust, mass, cost, power
busek = engine_type('busek', 2210, 0.449, 25, 35e6, 8); 
busek_block = engine_block(busek, 125);
raptor = engine_type('raptor', 380, 2e6, 1500, 2e6, 0);
raptor_block = engine_block(raptor, 1);

orbiter = stage('Orbiter', 26500, busek_block);
MDV = stage('MDV', 22000+15000, raptor_block);
S2 = stage('MAV S2', 6400, raptor_block);
S1 = stage('MAV S1', 15400, raptor_block);

nodes = [];
nodes = add_maneuver(nodes, [orbiter, MDV], orbiter, 'DSG', 6600);
nodes = add_maneuver(nodes, [orbiter, MDV], MDV, 'TMI', 1900);
nodes = add_maneuver(nodes, [S1, S2], S1, 'MSA1', 3000);
nodes = add_maneuver(nodes, S2, S2, 'MSA2', 2500);
nodes = add_maneuver(nodes, [orbiter, S2], S2, 'TEI (Chem)', 500);
nodes = add_maneuver(nodes, orbiter, orbiter, 'TEI (SEP)', 7000);
nodes = add_maneuver(nodes, orbiter, orbiter, 'LEO', 6000);

tables = compile(nodes);
[imleo, burn_time] = simple_report(tables);

