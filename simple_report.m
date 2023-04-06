function [imleo, burn_time] = simple_report(list_of_tables)

imleo = 0;
burn_time = 0;

for i = 1:numel(list_of_tables)
    tab = list_of_tables{i};
    imleo = imleo + tab.mi(1);
    burn_time = burn_time + sum(tab.t);
end

burn_time = days(days(seconds(burn_time)));

end