function params = genParamsNetwork(type, ts)
	params = cell(0);
	
	%Current
		params.td = 0.02; %Synaptic decay time in seconds 
		params.tr =  0.002; %Synaptic rise time in seconds 
	
	%Learning with FORCE
		params.learningType = 'FORCE';
		params.alpha = ts.dt * 0.01;  %Sets the rate of weight change, too fast is unstable, too slow is bad as well.  
	
	%Strength of the feedback
		params.strengthFB = 200; % Strength of the feedback
	
% LIF / RandomlyConnected
	if (type == 1)
		
		params.N = 2000;	
		params.nbOutput = 1;		
		
		%Params Neurons
		params.firingType = 'LIF';
		
		%Topo
		params.architectureType = 'Random';
		params.G = 0.4; %Set the level of connection strength/chaos in the network.  
		params.p = 0.1; %Set the network sparsity 
	
	
% IZHI RS (RegularSpiking Izhikevich 2003) 
% RandomlyConnected	
	elseif (type == 2)	 
		params.firingType = 'IZHI';
		params.architectureType = 'Random';
		
		params.N = 2000;	
		params.nbOutput = 1;		
		
		%Params Neurons
		params.IZHI.a = 0.02;
		params.IZHI.b = 0.2;
		params.IZHI.c = -65;
		params.IZHI.d = 8;
		
		%Topo

		params.G = 0.4; %Set the level of connection strength/chaos in the network.  
		params.p = 0.1; %Set the network sparsity 

% IZHI RESONATOR (Savin paper) 
% RandomlyConnected	
	elseif (type == 20)	 
		params.firingType = 'IZHI';
		params.architectureType = 'Random';
		
		params.N = 2000;	
		params.nbOutput = 1;		
		
		%Params Neurons
		params.IZHI.a = 0.1;
		params.IZHI.b = 0.26;
		params.IZHI.c = -70;
		params.IZHI.d = 2;
		
		%Topo

		params.G = 0.4; %Set the level of connection strength/chaos in the network.  
		params.p = 0.1; %Set the network sparsity 
		
% IZHI FAST SPIKING (IZHIKEVICH) 
% RandomlyConnected	
	elseif (type == 21)	 
		params.firingType = 'IZHI';
		params.architectureType = 'Random';
		
		params.N = 2000;	
		params.nbOutput = 1;		
		
		%Params Neurons
		params.IZHI.a = 0.02;
		params.IZHI.b = 0.25;
		params.IZHI.c = -65;
		params.IZHI.d = 2;
		
		%Topo

		params.G = 0.4; %Set the level of connection strength/chaos in the network.  
		params.p = 0.1; %Set the network sparsity 
	
	
	% LIF 
	% Balanced
	elseif (type == 3)	 
		% General
		params.firingType = 'LIF';
		params.architectureType = 'Balanced';		
		params.N = 2000;	
		params.nbOutput = 1;		
		
		% Params Neurons
		params.Excit.tref = 0.002; %Refractory time constant in seconds 
		params.Excit.tm = 0.01; %Membrane time constant 
		params.Excit.vreset = -65; %Voltage reset 
		params.Excit.vpeak = -40; %Voltage peak. 

		params.Inhib.tref = 0.002;  
		params.Inhib.tm = 0.01;  
		params.Inhib.vreset = -65;  
		params.Inhib.vpeak = -42;  % easier to fire
		

		
		% Topologie
		params.ratioE = 0.8;
		params.p = 0.1; %Set the network sparsity
		params.G = 1;
		params.G_EE = 1;
		params.G_EI = -3.90;
		params.G_II = -3.4;
		params.G_IE = 1; 
		

		

	elseif (type == 4)	 
		% General
		params.firingType = 'IZHI';	
		params.architectureType = 'Balanced';
		params.N = 2000;	
		params.nbOutput = 1;		
		
		%Params Neurons
		params.IZHI.Excit.a = 0.02;
		params.IZHI.Excit.b = 0.2;
		params.IZHI.Excit.c = -65;
		params.IZHI.Excit.d = 8;

		params.IZHI.Inhib.a = 0.02;
		params.IZHI.Inhib.b = 0.25;
		params.IZHI.Inhib.c = -65;
		params.IZHI.Inhib.d = 2;
		
		%Topo

		params.ratioE = 0.8;
		params.p = 0.1; %Set the network sparsity
		params.G = 1;
		params.G_EE = 1;
		params.G_EI = -2;
		params.G_II = -1.8;
		params.G_IE = 1; 
	
	% Type=5 Unbalanced / Izhikevich New
	elseif (type == 5)	 
		params.firingType = 'IZHI_2';	
		params.architectureType = 'Random';
		params.N = 2000;	
		params.nbOutput = 1;		
		
		%Params Neurons
		params.IZHI.C = 250;  %capacitance
		params.IZHI.vr = -60;   %resting membrane 
		params.IZHI.b = 0;  %resonance parameter 
		params.IZHI.ff = 2.5;  %k parameter for Izhikevich, gain on v 
		params.IZHI.vpeak = 30;  % peak voltage
		params.IZHI.vreset = -65; % reset voltage 
		params.IZHI.a = 0.01; %adaptation reciprocal time constant 
		params.IZHI.d = 200; %adaptation jump current 


		
		
		%Topo

		params.G = 35000; %Set the level of connection strength/chaos in the network.  
		params.p = 0.1; %Set the network sparsity 

		

	end
	

end
