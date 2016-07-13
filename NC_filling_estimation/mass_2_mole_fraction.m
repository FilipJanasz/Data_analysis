function mole_fr=mass_2_mole_fraction(mol_m,mass_fr)
average_factor=sum(mass_fr./mol_m);
for i=1:length(mol_m)
    mole_fr(i)=mass_fr(i)/mol_m(i)/average_factor;
end