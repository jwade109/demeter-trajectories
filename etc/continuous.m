clear;
clc;
figure;

%% Relative ICRF Heliocentric Classical Elements, Jan 1st, 2020
earth = earth_body();
mars = mars_body();
sol = sol_body();

%% do the thing

eci(earth);
eci(mars);

% continuous2(earth, mars, sol);


%% continuous thrust designer

function continuous2(earth, mars, sol)

r1 = earth.radius;

N = 4;
M = 3;
tof = seconds(days(220));
seed_tof_range = tof + seconds(days(linspace(-60, 60, M)));

routes = cell(M, 1);
choices = paths(N, M);

for m = 1:M

seed_tof = seed_tof_range(m);

mars_at_tof = mars; % propagate_to(mars, mars.epoch + seed_tof);
seed = rv2orbit(r1, intercept2(r1, mars_at_tof.radius, ...
    seed_tof, sol.mu), sol, earth.epoch);
seed.epoch = earth.epoch;
timespace = linspace(seed.epoch, seed.epoch + seed_tof, N+1);
routes{m} = history(seed, timespace);

end

for p = 1:size(choices, 1)

curr_choice = choices(p, :);
line = zeros(N+1, 3);

for y = 1:numel(curr_choice)

cr = routes{curr_choice(y)};
line(y,:) = cr(y,:);

end

plot3(line(:,1), line(:,2), line(:,3), 'r-');

for n = 1:N
    r1 = line(n,:);
    r2 = line(n+1,:);
    v1 = intercept2(r1, r2, tof/N, sol.mu);
    transfer = rv2orbit(r1, v1, sol, earth.epoch);
    transfer.epoch = 0;
    transfer.stop = transfer.epoch + tof/N;
    eci(transfer);
end

end

end

function res = paths(N, M)

elem = cell(1, N+1);
elem{1} = 1;
elem{N+1} = 1;

for n = 2:N
    elem{n} = 1:M;
end

combinations = cell(1, numel(elem));
[combinations{:}] = ndgrid(elem{:});
combinations = cellfun(@(x) x(:), combinations,'uniformoutput',false);
res = [combinations{:}];

end