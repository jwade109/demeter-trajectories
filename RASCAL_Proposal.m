% Johnny Jaffee 

% March 3, 2020

%RASC-AL Mars Short Stay

%The following script is used to simulate the interplanetary transit
%vehicle for the crew for a round trip mars mission. 
% The Vehicle Breakdown is as Follows:
% 1. Orbiter - Carries crew to mars, and back
% 2. MAV - lands crew on mars, and provides the intial boost for TEI, then
    % is left behind
% Orbiter has an electric propulsion system
% The MAV carries methane propellant to land on mars, and uses isru to get
% propellant back to orbiter, as well as provide a boost to TEI (part of
% it)

clc
clear
close all

% Some basic constants
g = 9.81; %earth gravity, m/s^2
e = exp(1); %eulers number

% ---------- Misc -----------------------------
% cost to LEO based on falcon heavy
costLEO = (((62*(10^6))/22800) + ((90*10^6)/63800))/2; %usd/kg

% -------------- Electric Engine Stats ----------------------------
% This is based on Busek BST-8000 Hall Effect Thrusters
busek = engine_type('busek', 2210, 0.449, 25, 35e6, 8); % isp, thrust, mass, cost, power
busek_block = engine_block(busek, 125);

% ---------------- Chemical Engine Stats --------------------------
% Based on SpaceX Raptor
raptor = engine_type('raptor', 380, 2e6, 1500, 2e6, 0); % isp, thrust, mass, cost, power
raptor_block = engine_block(raptor, 1);

% values based on Northrup Grumman Ultra Flex Panels
ultraflex = solar_panel_type(61, 1, 5); % power/mass, power/area, cost/power

% ----------- Base Masses --------------------------------

orbiter = ship(26500, busek_block); % dry mass, engine block
mav = ship(22000, raptor_block);

% the EDL mass
EDLmass = 12500; % kg
mavS1 = 0.7; % decimal percent of mass for mav stage 1
mav2stage = mav.dry_mass*(1-mavS1); % tons
mav1stage = mavS1*mav.dry_mass; % tons
massSolar = busek_block.power_req/ultraflex.power_per_mass; % kg for solar panels
ISRUprop = 125000; % mass of ISRU propellant produced, kg

% ---------------- Atmospheric Interface Velocities -----
mars_ATM = 5600; % m/s
earth_ATM = 1865; % m/s

% ------------- Orbit Velocities --------------------------
LEO_vel = 7800; % m/s
LMO_vel = 3310; % m/s

% --------------- Aerocapture Velocities ----------------
capM = 5000; % m/s, at mars
capE = 13000; % m/s, earth

%------------------Trajectory dV reqs -------------------------
%From LEO to Lunar L2
LEO_L2 = 3330; % m/s
% From Lunar L2 to TMI
L2_TMI = 1300; % m/s
%From TMI to LMO, the total dV needed
LMO_Total = mars_ATM - LMO_vel; % m/s
%the propulsive required dV after aerocapture
LMO_Prop = mars_ATM - capM; % m/s
if (LMO_Prop < 0)
    LMO_Prop = 0;
end
%LMO to Landing on Mars
LMO_Mars = 700; % m/s
%LMO to Mars L1
LMO_L1 = 500; % m/s
%Mars Surface to L1
Mars_L1 = 4000 + LMO_L1; %km/s
%L1 to TEI
L1_TEI = 3690; % m/s
%TEI to LEO
TEI_LEO_Total = earth_ATM - LEO_vel; %km/s, total dV
TEI_LEO_Prop = earth_ATM - capE %propulsive Dv req, km/s
if (TEI_LEO_Prop < 0)
    TEI_LEO_Prop = 0;
end

% --------------- Propellant Required to Land MAV ------------------
mfLand = mass_fraction(raptor, LMO_Mars); % mass fraction to land, all chemical
MAV_PropLand = ((mav.dry_mass+EDLmass)*mfLand) - mav.dry_mass; %metric tons, propellant needed to land mav on mars
btLanding = ((MAV_PropLand)/raptor_block.mass_flow_rate)*(1/(60*60*24)); %days
MAV_PropLand = 0; % INCLUDED IN EDL BUDGET 
disp('EDL budget includes Landing');

% ---------------- Maneveurs ----------------------------
%Starting from last to first

%TEI into LEO:at this stage it's just the orbiter and it's solar panels and
%engines/fuel. No chemical engines available (so assumed)
TEI_LEO_empty = orbiter.dry_mass + (busek_block.mass) + massSolar % metric tons, empty mass
%the mass fraction required to perform the maneveur
mf_TEI_LEO = mass_fraction(busek, penalize(TEI_LEO_Prop, 'interplanetary'));
%the mass full before executing the maneveur
TEI_LEO_full = TEI_LEO_empty*mf_TEI_LEO %metric tons
%the amount of propellant that it takes to perform this maneveur, and just
%this maneveur
TEI_LEO_propMass = TEI_LEO_full - TEI_LEO_empty %metric tons
%the burn time required to perform this maneveur
bt_TEI_LEO = ((TEI_LEO_propMass)/busek_block.mass_flow_rate)*(1/(60*60*24)) %days

%---------------------Mars to L1 --------------------------------------
%The MAV going from Mars to L1, including all the extra isru propellant
%starting with mass full because of this. This is pruely chemical
%assumed 80% mass for stage 1, 20% for stage 2
Mars_L1_full = mav.dry_mass + (ISRUprop); %metric tons
%empty mass required for mav before getting to L1 from surface
Mars_L1_empty = Mars_L1_full - (ISRUprop*mavS1); %metric tons
%deltaV from the first stage
dV1_MAV = (raptor.isp*g*log(Mars_L1_full/Mars_L1_empty)); %km/s
%find the remaining dV needed
dV2_MAV = Mars_L1 - dV1_MAV; %km/s
if (dV2_MAV < 0)
    disp('Error: Mav stage 1 is too big, completes at dV reqs');
end
%mass fraction required for remainder of maneveur to L1
mf_Mars_L1 = mass_fraction(raptor, dV2_MAV);
%the mass full for the second stage MAV
Mars_L1_2full = Mars_L1_empty - mav1stage; %metric tons
%the required mass empty for this maneveur
Mars_L1_2empty = Mars_L1_2full/mf_Mars_L1; %metric tons
%additional left over propellant
Mars_L1_extra = Mars_L1_2empty - mav2stage %metric tons
if Mars_L1_extra < 0
    disp('Fuck: not enough ISRU Propellant');
end
%the mass of propellant required for this maneveur
Mars_L1_prop = Mars_L1_full - (Mars_L1_empty + Mars_L1_extra); %metric tons
%solve for burn time, chemical portion
bt_L1c = ((Mars_L1_prop)/raptor_block.mass_flow_rate)*(1/(60*60*24)); %days
%--------------------------------------------------------------------

%L1 to TEI with MAV Kick
%we'll need to set up an equation to solve for Xenon mass required for
%after the mav kick
syms xMass %xenon mass
%equation for mass full for mav kick
fullKick = orbiter.dry_mass + massSolar + (busek_block.mass)  + mav2stage + Mars_L1_extra + xMass + TEI_LEO_propMass; %metric tons
%mass Empty for kick
emptyKick = fullKick - Mars_L1_extra; %metric tons
%equation for the kick provided by the MAV
dVkick = raptor.isp*g*log((fullKick/emptyKick)); %m/s
%equation for mass full for TEI after kick
fullTEI = massSolar + orbiter.dry_mass + xMass + TEI_LEO_propMass + (busek_block.mass); %metric tons
%equation for mass empty after TEI
emptyTEI = fullTEI - xMass; %metric tons
dVtei = penalize(busek.isp*g*log(fullTEI/emptyTEI), 'gravity well');
eq = (L1_TEI) == dVtei + dVkick; %eq to solve for mass
L1_TEI_propMass = vpasolve(eq, xMass) % metric tons
L1_TEIfull = vpa(subs(fullTEI, xMass, L1_TEI_propMass))
L1_TEIempty = vpa(subs(emptyTEI, xMass, L1_TEI_propMass))
%solve for burn time, chemical portion
bt_L1_TEIc = ((Mars_L1_extra)/raptor_block.mass_flow_rate)*(1/(60*60*24)); %days
%burn time ep
bt_L1_TEIe = ((L1_TEI_propMass)/busek_block.mass_flow_rate)*(1/(60*60*24)) %days

%---------LMO to L1------------------
%Assumed to be purely electric
%empty mass before the maneveur
LMO_L1_empty = vpa(subs(fullTEI, xMass, L1_TEI_propMass)) %metric tons
%mass fraction required
mf_LMO_L1 = mass_fraction(busek, penalize(LMO_L1, 'gravity well'));
%mass full before maneveur
LMO_L1_full = LMO_L1_empty*mf_LMO_L1 %metric tons
%propulsion mass for maneveur
LMO_L1_propMass = LMO_L1_full - LMO_L1_empty %metric tons
%burn time EP
bt_LMO_L1 = ((LMO_L1_propMass)/busek_block.mass_flow_rate)*(1/(60*60*24)) %days

%TMI to LMO: all EP
TMI_LMO_empty = LMO_L1_full + mav.dry_mass  + MAV_PropLand + EDLmass %metric tons
%mass fraction to insert into LMO
mf_TMI_LMO = mass_fraction(busek, penalize(LMO_Prop, 'gravity well'));
%mass full forTMI into LMO
TMI_LMO_full = mf_TMI_LMO*TMI_LMO_empty %metric tons
%the mass of propellant for this maneveur
TMI_LMO_prop = TMI_LMO_full - TMI_LMO_empty %metric tons
%burn time
bt_TMI_LMO = ((TMI_LMO_prop)/busek_block.mass_flow_rate)*(1/(60*60*24)) %days

%L2 to TMI: all EP
%mass empty for the maneveur
L2_TMI_empty = TMI_LMO_full %metric tons
%mass fraction to go from L2 to TMI
mf_L2_TMI = mass_fraction(busek, penalize(L2_TMI, 'interplanetary'));
%mass full before TMI
L2_TMI_full = L2_TMI_empty*mf_L2_TMI %metric tons
%mass of propellant for maneveur
L2_TMI_prop = L2_TMI_full - L2_TMI_empty %metric tons
%burn time
bt_L2_TMI = ((L2_TMI_prop)/busek_block.mass_flow_rate)*(1/(60*60*24)) %days

%------LEO to L2: All EP, unmanned----------------
LEO_L2_empty = L2_TMI_full %metric tons
%mass fraction for the spiral to L2
mf_LEO_L2 = mass_fraction(busek, penalize(LEO_L2, 'gravity well'));
%mass full for LEO_L2
LEO_L2_full = LEO_L2_empty*mf_LEO_L2 %metric tons
%propellant mass for maneveur
LEO_L2_prop = LEO_L2_full - LEO_L2_empty %metric tons
%burn time
bt_LEO_L2 = ((LEO_L2_prop)/busek_block.mass_flow_rate)*(1/(60*60*24)) %days


%-----------Totals---------------------
IMLEO = LEO_L2_full; %metric tons
%total manned burntime
bt_manned = bt_L2_TMI+bt_TMI_LMO+bt_LMO_L1+bt_L1_TEIe+bt_L1_TEIc+bt_L1c+bt_TEI_LEO+btLanding; %days

fprintf('The intial mass in LEO is %.2f metric tons \n', IMLEO);
fprintf('The total manned time of flight is %.2f days \n', bt_manned);
fprintf('The unmanned time to spiral from LEO to L2 is %.2f days \n', bt_LEO_L2);
fprintf('The power required is %.2f kW \n', busek_block.power_req);




