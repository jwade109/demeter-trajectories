function [sim, iters] = orbsim(system, endtime)

sim = struct;
sim.evolution = [system];
sim.begin = system.time;
sim.end = endtime;
sim.first = system;

fprintf("Simulation:\n");
fprintf("Begin: %s\n", sim.begin);
fprintf("End: %s\n", sim.end);

now = sim.begin;
iters = 1;

while now < sim.end

    priori = sim.evolution(end);
    posteriori = priori;
    
    dt = seconds(1);
    
    for i = 1:numel(posteriori.spacecraft)
        sc = posteriori.spacecraft(i);
        primary = posteriori.primary;
        acc = gacc(sc.position, primary.position, primary.mass);
        for j = 1:numel(posteriori.secondary)
            second = posteriori.secondary(j);
            acc = acc + gacc(sc.position, second.position, second.mass);
        end
        
        h = 5/norm(acc);
        dt = seconds(h);
        
        sc.position = sc.position + sc.velocity*h;
        sc.velocity = sc.velocity + acc*h;
        posteriori.spacecraft(i) = sc;
    end
    
    posteriori.time = priori.time + dt;
    now = posteriori.time;
    sim.evolution(end+1) = posteriori;
    iters = iters + 1;
end

sim.last = sim.evolution(end);

end