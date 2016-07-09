function signal = genIO(type, ts)
	signal = cell(0);
	
	% 1 Spike, no fOut
	if(type == 0)	
		signal.fin = zeros(ts.nt, 1);
		signal.fin(1) = 1
		tr = 0.02;
		td = 0.002;
		h = 1/(tr * td);
		signal.fin(1) = 1;
		for i = 2:1:ts.nt
			    signal.fin(i) = signal.fin(i-1)*exp(-ts.dt/tr) + h*ts.dt;
			    h = h*exp(-ts.dt/td);  %Integrate the current
		end
		signal.fout = zeros(ts.nt, 1);
		
	% No fIn, fOut = triangle
	elseif(type == 1)
		signal.fin = zeros(ts.nt, 1);
		signal.fout = 0.3*asin(sin(2*pi*(1:1:ts.nt)'*ts.dt*2)); %The target function to be learned, feel free to play with this 	
    
	% Simple sinusoidal
	elseif(type == 2)
		freq =5;
		signal.fin = zeros(ts.nt, 1);
		signal.fout = sin(2 * pi * (1:1:ts.nt)' * freq * ts.dt); %The target function to be learned, feel free to play with this 	
		
	end

	%% To incorporate (tasks from Abbot [MAIN])
	% simtime = 0:dt:nsecs-dt;
	% simtime_len = length(simtime);
	% simtime2 = 1*nsecs:dt:2*nsecs-dt;

	% amp = 1.3;
	% freq = 1/60;
	% ft = (amp/1.0)*sin(1.0*pi*freq*simtime) + ...
     % (amp/2.0)*sin(2.0*pi*freq*simtime) + ...
     % (amp/6.0)*sin(3.0*pi*freq*simtime) + ...
     % (amp/3.0)*sin(4.0*pi*freq*simtime);
	% ft = ft/1.5;

	% ft2 = (amp/1.0)*sin(1.0*pi*freq*simtime2) + ...
      % (amp/2.0)*sin(2.0*pi*freq*simtime2) + ...
      % (amp/6.0)*sin(3.0*pi*freq*simtime2) + ...
      % (amp/3.0)*sin(4.0*pi*freq*simtime2);
	% ft2 = ft2/1.5;

	
	
end
