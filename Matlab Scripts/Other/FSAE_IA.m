clear all
%websites
    %http://www.hexcel.com/Products/Aerospace/AHoneycomb-Key
    %http://www.plascore.com/products/energy-absorbtion/crushlite/
    %http://www.plascore.com/products/honeycomb-cores/aluminum/pcga-xr1-3003-aluminum-honeycomb/
massStandard = 0.662; %kg mass of standard attenuator 

rho = 5.7/2.2/12^3/2.54^3*100^3;
%Constants
g = 9.81; %m/s^2 accelleration due to gravity

%Aluminum Honeycomb Properties
precrushMax = 1/4*2.54/100; %m max precrush distance
Ks = 0.7; %Stroke(crush) efficiency HexWeb Brochure assumes 70%
fCrStatic = 375 * 6894.76; %Pa (psi * Pa/psi) crush strength - average load/initial area
fCrDynamic = fCrStatic*1.1; %Pa crush strength use fig 2 in HexWeb brochure

%Actual Dimensions
h = 4*25.4/1000;
w = 8 * 25.4/1000;
l = 8 * 25.4/1000;
mass = h*w*l*rho;

%IA Properties
hmin = 0.1; %m minimum IA height
wmin = 0.2; %m minimnum IA width
lmin = 0.2; %m minimum IA length

%FSAE Test Values
v = 7.0; %m/s test velocity requirement
m = 300; %kg test mass requirement
aAveMax = 20 * g; %m/s^2 maximum average deccelleration
aPeakMax = 40 * g; %m/s^2 maximum average deccelleration
EabsMin = 7350; %J minimum energy absorption

%Calculations as per HexWeb Honeycomb Energy Absorption Brochure
sreq = v^2 / (2*aAveMax); %m required stopping distance
Treq = (sreq + precrushMax) / Ks; %m required thickness

Acr = 1/2 * m * v^2 / (fCrDynamic * sreq); %m^2 crush area required

if (hmin * wmin >= Acr)
    fprintf('FSAE minimum crush area is sufficient.\n')
    fprintf('Calculated crush area: %f mm^2 or %f times minimum.\n', Acr * 1000^2, Acr / (hmin * wmin))
else
    fprintf('Crush area must be: %f mm^2 or %f times minimum.\n', Acr * 1000^2, Acr / (hmin * wmin))
    fprintf('Supplier Proposed Crush area: %f mm^2 or %f times minimum.\n', h*w*1000^2, h*w / (hmin * wmin))
end

if (Treq <= lmin)
    fprintf('FSAE minimum length is sufficient.\n')
    fprintf('Energy absorbed is %f J\n', (lmin*Ks-precrushMax)*aAveMax*m)
else
    fprintf('Length must be:%f mm.\n', Treq * 1000)
end

fprintf('Mass of standard AI = %f kg\n',massStandard)
fprintf('Mass of new AI = %f kg or %f pct of standard\n',mass, ...
    mass/massStandard*100)
fprintf('Mass Saving = %f kg = %f lbs or %f pct\n', massStandard-mass,...
    (massStandard-mass)*2.2,(massStandard-mass)/massStandard*100)
    