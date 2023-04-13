function [tables, burn_time, imleo, prop] = compile(nodes)

% mi - initial mass
% mf - final mass
% pmi - initial propellant mass
% pmf - final propellant mass
% md - dry mass
% dm - delta mass
% dv - delta velocity
% t - burn time

num_nodes = numel(nodes);

tables = containers.Map;
stages = containers.Map;
node_names = cell(num_nodes, 1);

for i = 1:num_nodes
    for j = 1:numel(nodes(i).stages)
        stage = nodes(i).stages(j);
        tables(stage.name) = table;
        stages(stage.name) = stage;
    end
    node_names{i} = nodes(i).name;
end

stage_names = keys(tables);
for i = 1:numel(stage_names)
    s = stage_names{i};
    tab = tables(s);
    tab.mi = zeros(numel(node_names), 1);
    tab.mf = zeros(numel(node_names), 1);
    tab.pmi = zeros(numel(node_names), 1);
    tab.pmf = zeros(numel(node_names), 1);
    tab.md = ones(numel(node_names), 1)*stages(s).dry_mass;
    tab.mf(end) = tab.md(end);
    tab.dm = zeros(numel(node_names), 1);
    tab.dv = zeros(numel(node_names), 1);
    tab.t = zeros(numel(node_names), 1);
    tab.Properties.RowNames = node_names;
    tables(s) = tab;
end

for i = num_nodes:-1:1
    node = nodes(i);
    
    % consider all stages
    for j = 1:numel(stage_names)
        name = stage_names{j};
        stage = stages(name);
        tab = tables(name);
        
        if i < num_nodes
            tab.mf(i) = tab.mi(i+1);
            tab.pmf(i) = tab.pmi(i+1);
        end
            
        if isequal(node.burning_stage, stage)
            tab.dv(i) = node.dv;
        else
            tab.mi(i) = tab.mf(i);
            tab.pmi(i) = tab.pmf(i);
        end
        tables(name) = tab;
    end
        
    % sum of the final masses participating in this maneuver
    final_composite_mass = 0;
    % consider only the stages participating in this maneuver
    for j = 1:numel(node.stages)
        name = node.stages(j).name;
        tab = tables(name);
        
        final_composite_mass = final_composite_mass + tab.mf(i);           
        
        tables(name) = tab;
    end
    
    % consider only the burning stage
    tab = tables(node.burning_stage.name);

    initial_composite_mass = final_composite_mass*node.mass_fraction;
    propellant_mass = initial_composite_mass - final_composite_mass;
    tab.mi(i) = tab.mf(i) + propellant_mass;
    tab.pmi(i) = tab.pmf(i) + propellant_mass;

    tables(node.burning_stage.name) = tab;
    
    
    % consider all stages
    for j = 1:numel(stage_names)
        name = stage_names{j};
        stage = stages(name);
        tab = tables(name);
        tab.dm(i) = tab.mi(i) - tab.mf(i);
        tab.t(i) = tab.dm(i)/stage.engines.mass_flow_rate;
        tables(name) = tab;
    end
    
        
end

for i = 1:numel(stage_names)
    s = stage_names{i};
    fprintf("======= %s\n", s);
    disp(tables(s));
end

tables = values(tables);

burn_time = days(0);
imleo = 0;
prop = 0;
for i = 1:numel(tables)
    t = tables{i};
    burn_time = burn_time + seconds(sum(t.t));
    imleo = imleo + max(t.mi);
    prop = prop + max(t.pmi);
end
