function masses = sandchart(tables, vehicle_names, option)

if numel(tables) ~= numel(vehicle_names)
    error("Number of tables must equal number of vehicle names!");
end

if ~strcmp(option, 'total') && ~strcmp(option, 'prop') &&...
   ~strcmp(option, 'both')
    error("Option must be 'total', 'prop', or 'both'!");
end

locations = [{'IMLEO'}; tables{1}.Properties.RowNames];

masses = zeros(numel(locations), numel(vehicle_names));

if strcmp(option, 'both')
    masses = zeros(numel(locations), numel(vehicle_names)*2);
    tmp = cell(numel(vehicle_names)*2, 1);
    for i = 1:numel(vehicle_names)
        name = vehicle_names{i};
        tmp{(i-1)*2+1} = strcat(name, ' (Dry Mass)');
        tmp{(i-1)*2+2} = strcat(name, ' (Propellant)');
    end
    vehicle_names = tmp;
end

for i = 1:numel(tables)
    tab = tables{i};
    if strcmp(option, 'total')
        masses(1,i) = tab.mi(1)/1000;
        masses(2:end,i) = tab.mf(:)/1000;
    elseif strcmp(option, 'prop')
        masses(1,i) = tab.pmi(1)/1000;
        masses(2:end,i) = tab.pmf(:)/1000;
    elseif strcmp(option, 'both')
        masses(1,(i-1)*2+1) = tab.md(1)/1000;
        masses(2:end,(i-1)*2+1) = tab.md(:)/1000;
        masses(1,(i-1)*2+2) = tab.pmi(1)/1000;
        masses(2:end,(i-1)*2+2) = tab.pmf(:)/1000;
    end
end

area(masses);
set(gca,'XTick', 1:numel(locations))
set(gca,'XTickLabel', locations)
legend(vehicle_names);
if strcmp(option, 'prop')
    ylabel("Vehicle Propellant Mass (metric tons)");
elseif strcmp(option, 'total')
    ylabel("Vehicle Total Mass (metric tons)");
elseif strcmp(option, 'both')
    ylabel("Vehicle Propellant and Dry Mass (metric tons)");
end
xlabel("Chronological Sequence of Maneuvers");

end