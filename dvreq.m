%% compute required DV to achieve vinf from a given orbit

function dv = dvreq(vinf, orbit)

dv = sqrt(vinf.^2 + orbit.vesc.^2) - norm(orbit.v);

end