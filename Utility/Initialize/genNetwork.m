function net = genNetwork(params, ts)
	net = cell(0);

		net.N = params.N;
		net.nbOutput = params.nbOutput;
		net.G = params.G;
		net.p = params.p;
		%feedback strength(if = 0 no feedback)
		net.strengthFB = params.strengthFB;
		net.td = params.td;
		net.tr = params.tr;	
		net.alpha = params.alpha;
		net.firingType = params.firingType;
		net.learningType = params.learningType;		
		net.architectureType = params.architectureType;
		
		disp(net.N)
		disp(net.firingType)
		disp(net.learningType)
		disp(net.architectureType)

		
		%Topology
		if(strcmp(params.architectureType, 'Random'))	
		%Reservoir connections
			net.OMEGA =  net.G*(randn(net.N, net.N)).*(rand(net.N,net.N)<net.p)/sqrt(net.p*net.N);
			
		%Output (z=BPhi*r) and feedback (fb = strengthFB * E * z) - if strengthFB = 0 no feedback still z is ~= 0
			net.BPhi = zeros(net.N, net.nbOutput); %The initial matrix that will be learned by FORCE method
			net.E = (2*rand(net.N,net.nbOutput)-1);  					
			net.z = zeros(net.nbOutput,1);  %Initialize the approximant 

			
		elseif (strcmp(params.architectureType, 'Balanced'))	
		%Reservoir connections
			net.nbE = ceil(params.ratioE * net.N);
			net.nbI = net.N - net.nbE;
			%Neurons sorted [NExcit, NInhib]
			net.indexE = 1:1:net.nbE;
			net.indexI = (net.nbE+1):1:(net.nbE+net.nbI);			
			net.sparse =  (net.G/sqrt(net.p*net.N)) * (rand(net.N,net.N)<net.p);
			net.customWeights = [ones(net.nbE, net.nbE) * params.G_EE, ones(net.nbE, net.nbI) * params.G_EI; ones(net.nbI, net.nbE) * params.G_IE, ones(net.nbI, net.nbI) * params.G_II];
			net.OMEGA = net.sparse .* net.customWeights;
			net.OMEGA_E = net.OMEGA(:, net.indexE); %Synaptic weights from NExc
			net.OMEGA_I = net.OMEGA(:, net.indexI); %Synaptic weights from NInhib
			
		% Output (z=BPhi*r) and feedback (fb = strengthFB * E * z) - if strengthFB = 0 no feedback still z is ~= 0
		% Only Excitatory neurons project to z (logic appears in the Learning function - only weights from E are updated)
		% Output is only Fed back to Excitatory (E_Excit ~= 0, E_Inhib == 0):
			net.BPhi = zeros(net.N, net.nbOutput); %The initial matrix that will be learned by FORCE method
			net.E = [(2*rand(net.nbE,net.nbOutput)-1), zeros(net.nbI, net.nbOutput)];  		
			net.z = zeros(net.nbOutput,1);  %Initialize the approximant 
		end
		
		
		%Synaptic current
		net.td = 0.02; %Synaptic decay time in seconds 
		net.tr =  0.002; %Synaptic rise time in seconds 
		net.decaytd = exp(-ts.dt/net.td);		
		net.decaytr = exp(-ts.dt/net.tr);	
		net.IPSC = zeros(net.N,1); %post synaptic current storage variable 
		net.IPSC_E = zeros(net.N,1); %post synaptic current storage variable coming from E 
		net.IPSC_I = zeros(net.N,1); %post synaptic current storage variable coming from I
		net.h = zeros(net.N,1); %Storage variable for filtered firing rates
		net.h_E = zeros(net.N,1); %Storage variable for filtered firing rates
		net.h_I = zeros(net.N,1); %Storage variable for filtered firing rates
		net.r = zeros(net.N,1); %second storage variable for filtered rates 
		net.hr = zeros(net.N,1); %Third variable for filtered rates 	


		%Spiking model
		net.BIAS = 0; %Set the BIAS current, can help decrease/increase firing rates.  0 is fine. 
		net.SS = 0; %Set the noise level for the LIF neurons, keep it at 0 for now 
		net.v = zeros(net.N,1); %membrane potential
		net.dv = zeros(net.N,1); %membrane potential		
		net.JD = zeros(net.N,1); %storage variable required for each spike time 
		net.tlast = zeros(net.N,1); %This vector is used to set  the refractory times
		
		%LIF variable
		if(strcmp(net.firingType, 'LIF'))
			if (strcmp(params.architectureType, 'Balanced'))
				net.tref = [params.Excit.tref * ones(net.nbE,1); params.Inhib.tref * ones(net.nbI,1)];%Refractory time constant in seconds 
				net.tm = [params.Excit.tm * ones(net.nbE,1); params.Inhib.tm * ones(net.nbI,1)];; %Membrane time constant 
				net.vreset = [params.Excit.vreset * ones(net.nbE,1); params.Inhib.vreset * ones(net.nbI,1)]; %Voltage reset 
				net.vpeak = [params.Excit.vpeak * ones(net.nbE,1); params.Inhib.vpeak * ones(net.nbI,1)]; %Voltage peak. 
			else
				net.tref = 0.002; %Refractory time constant in seconds 
				net.tm = 0.01; %Membrane time constant 
				net.vreset = -65; %Voltage reset 
				net.vpeak = -40; %Voltage peak.
			end
			
		% IZHI variable		
		elseif(strcmp(net.firingType, 'IZHI'))
			net.vpeak = 30;
			net.IZHI.u = - ones(net.N,1);
			net.IZHI.du = zeros(net.N,1);
			
			if (strcmp(params.architectureType, 'Balanced'))
				net.IZHI.a = [params.IZHI.Excit.a * ones(net.nbE,1); params.IZHI.Inhib.a * ones(net.nbI,1)];
				net.IZHI.b = [params.IZHI.Excit.b * ones(net.nbE,1); params.IZHI.Inhib.b * ones(net.nbI,1)];
				net.IZHI.c = [params.IZHI.Excit.c * ones(net.nbE,1); params.IZHI.Inhib.c * ones(net.nbI,1)];
				net.IZHI.d = [params.IZHI.Excit.d * ones(net.nbE,1); params.IZHI.Inhib.d * ones(net.nbI,1)];
			
			else
				net.IZHI.a = params.IZHI.a * ones(net.N,1);
				net.IZHI.b = params.IZHI.b * ones(net.N,1);
				net.IZHI.c = params.IZHI.c * ones(net.N,1);
				net.IZHI.d = params.IZHI.d * ones(net.N,1);
				
			end
			
		elseif(strcmp(net.firingType, 'IZHI_2'))
			net.IZHI.vt = params.IZHI.vr + 40 -(params.IZHI.b/params.IZHI.ff); %threshold  
			net.IZHI.vpeak = params.IZHI.vpeak;
			
			net.IZHI.u = - ones(net.N,1);
			net.IZHI.du = zeros(net.N,1);
			
			if (strcmp(params.architectureType, 'Balanced'))
				%% TBC
				%net.IZHI.a = [params.IZHI.Excit.a * ones(net.nbE,1); params.IZHI.Inhib.a * ones(net.nbI,1)];
				%net.IZHI.b = [params.IZHI.Excit.b * ones(net.nbE,1); params.IZHI.Inhib.b * ones(net.nbI,1)];
				%net.IZHI.c = [params.IZHI.Excit.c * ones(net.nbE,1); params.IZHI.Inhib.c * ones(net.nbI,1)];
				%net.IZHI.d = [params.IZHI.Excit.d * ones(net.nbE,1); params.IZHI.Inhib.d * ones(net.nbI,1)];
			
			else
				net.IZHI.C = params.IZHI.C;  %capacitance
				net.IZHI.vr = params.IZHI.vr;   %resting membrane 
				net.IZHI.b = params.IZHI.b;  %resonance parameter 
				net.IZHI.ff = params.IZHI.ff;  %k parameter for IZHIkevich, gain on v 
				net.IZHI.vreset = params.IZHI.vreset; % reset voltage 
				net.IZHI.a = params.IZHI.a; %adaptation reciprocal time constant 
				net.IZHI.d = params.IZHI.d; %adaptation jump current 
					
			end
		end
		

		
		% Learning
		if(strcmp(net.learningType, 'FORCE'))
			if(strcmp(params.architectureType, 'Random'))
				net.Pinv = eye(net.N) / net.alpha; %initialize the correlation weight matrix for RLMS
				net.cd = zeros(net.N, 1);			
			
			elseif (strcmp(params.architectureType, 'Balanced'))
				net.Pinv = eye(net.nbE) / net.alpha; %initialize the correlation weight matrix for RLMS
				net.cd = zeros(net.nbE, 1);
			end	
		end
		
end
