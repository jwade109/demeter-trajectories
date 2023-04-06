function m = mu(primary_body)

if strcmp(primary_body, 'earth')
    m = 3.986e14;
elseif strcmp(primary_body, 'luna')
    m = 4.904e12;
elseif strcmp(primary_body, 'mars')
    m = 4.282e13;
elseif strcmp(primary_body, 'sun')
    m = 1.327e20;
elseif strcmp(primary_body, 'kalliope')
    m = 5.446e8;
elseif strcmp(primary_body, 'phobos')
    m = 716100;
elseif strcmp(primary_body, 'deimos')
    m = 104100;
elseif strcmp(primary_body, 'venus')
    m = 1; % not true
else
    error("%s not implemented", primary_body);
end

end