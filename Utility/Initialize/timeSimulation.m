function ts =  timeSimulation(trest, ttrain, ttest, dt, stepLearning)
	ts = cell(0);
	
	ts.trest = trest;  %Total simultion time, seconds
	ts.ttrain = ttrain;  %Total simultion time, seconds
	ts.ttest = ttest;  %Total simultion time, seconds
	ts.dt = dt;  % Integration time step 
	ts.nt = round((trest+ttrain+ttest)/dt);
	ts.imin = round(trest/dt); %.  
	ts.stepLearning = stepLearning; %Only adjust weights every 10th time step, this is primarily for speed.
	ts.icrit = round((trest+ttrain)/dt);  %Stop the FORCE method learning
	
	ts.timeIndex = (1:1:ts.nt);
	ts.timeRange = ts.dt * ts.timeIndex;
	
end