function res = get_common_body(orbits_and_bodies)

common_bodies = [];

for i = 1:numel(orbits_and_bodies)
    obj = orbits_and_bodies{i};
    body = get_primary_body(obj);
    tree = gravity_family_tree(body);
    if i == 1
        common_bodies = tree;
    else
        common_bodies = astro_intersection(tree, common_bodies);
    end
end

res = common_bodies(1);

end


%% computes the members of A which are also in B
function inter = astro_intersection(A, B)

for i = 1:numel(A)
    names_A{i} = A(i).name;
end

for i = 1:numel(B)
    names_B{i} = B(i).name;
end

ism = ismember(names_A, names_B);
inter = A(ism);

end

