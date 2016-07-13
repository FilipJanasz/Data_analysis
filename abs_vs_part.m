NC_part=[0.1314	0.1708	0.2965];
NC_abs=[0.1011	0.1951	0.2788];
Press_part=[2.201	2.481	2.84];
Press_abs=[4.979	4.979	4.978];
Mflow_part=[0.0001688	0.0002058	0.0002833];
Mflow_abs=[0.0003225	0.000271	0.00007969];
Press_parth2o_part=(1-NC_part).*Press_part;
Press_parth2o_abs=(1-NC_abs).*Press_abs;

figure
hold on
plot3(Press_part,Press_parth2o_part,Mflow_part,'-b')
plot3(Press_abs,Press_parth2o_abs,Mflow_abs,'-r')
plot3(Press_part,Press_parth2o_part,Mflow_part,'xb')
plot3(Press_abs,Press_parth2o_abs,Mflow_abs,'xr')
xlabel('Absolute pressure')
ylabel('Partial pressure')
zlabel('Mass flow')
hold off

figure
hold on
plot3(Press_part,NC_part,Mflow_part,'-b')
plot3(Press_abs,NC_abs,Mflow_abs,'-r')
plot3(Press_part,NC_part,Mflow_part,'xb')
plot3(Press_abs,NC_abs,Mflow_abs,'xr')
xlabel('Absolute pressure')
ylabel('Mole Frac NC')
zlabel('Mass flow')

figure
hold on
plot3(Press_parth2o_part,NC_part,Mflow_part,'-b')
plot3(Press_parth2o_abs,NC_abs,Mflow_abs,'-r')
plot3(Press_parth2o_part,NC_part,Mflow_part,'xb')
plot3(Press_parth2o_abs,NC_abs,Mflow_abs,'xr')
xlabel('Partial pressure')
ylabel('Mole Frac NC')
zlabel('Mass flow')

