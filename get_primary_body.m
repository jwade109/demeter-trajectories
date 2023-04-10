function body = get_primary_body(orbit_or_body)

if isa(orbit_or_body, 'keplerian_orbit')
    body = orbit_or_body.primary_body;
elseif isa(orbit_or_body, 'astronomical_body')
    body = orbit_or_body;
elseif isa(orbit_or_body, 'low_thrust_trajectory')
    body = orbit_or_body.initial.primary_body;
else
    error("Unsupported object type: %s", class(orbit_or_body))
end

end
