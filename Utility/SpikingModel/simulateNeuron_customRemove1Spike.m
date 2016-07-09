function [net, newSpike, spikeRemoved] = simulateNeuron_customRemove1Spike(net, ts, fin, i, nbToRemove)
%FS chge the way tlast is done
%SS push after if SS ~=0 only
%FS add more thing in the if(newSpike)
%FS can't cope yet to the addition/deletion of more than one spike
%FS if nbToRemove > 0: remove randomly spike, if < 0 add spikes, == 0, normal behavior
	
	spikeRemoved = 0;
	net.I = net.IPSC + net.strengthFB*(net.E*net.z) - net.BIAS + fin; %Neuronal Current 

    if(net.SS ~= 0)
        net.v = net.v + sqrt(ts.dt/net.tm)*net.SS*randn(net.N,1);
    end
	
	if(strcmp(net.firingType, 'IZHI'))
		% 2 differential equations IZHI
        % Equations are given per ms in the paper: yes it seems so
		net.IZHI.du = 10^3 * (net.IZHI.a .* (net.IZHI.b .* net.v - net.IZHI.u));
		net.dv = 10^3 * (0.04 * net.v.^2 + 5 * net.v + 140 - net.IZHI.u + net.I);  
	
		net.v = net.v + ts.dt*(net.dv); %Euler integration.
		net.IZHI.u = net.IZHI.u + ts.dt*(net.IZHI.du); %Euler integration .  
		%newSpike = find(net.v >= net.vpeak);  %Find the neurons that have spiked 
        spikeMask = (net.v >= net.vpeak);  %Find the neurons that have spiked
		newSpike = find(spikeMask);
		
		% Special case if only one spike
		% Remove one spike still reset the Neuron
		if(length(newSpike) >= 1 && nbToRemove>0)
			if (length(newSpike) == 1)
				spikeRemoved = newSpike;
				newSpike = [];
			else
				spikeRemoved = randsample(newSpike,1);
				newSpike = newSpike(newSpike ~= spikeRemoved)
			end
			print('Spike removed');
        
		% Add one spike and reset the neuron
        elseif(nbToRemove < 0)
			%misleading, actually in this case, it is spike added
			tmpPotentialNeurons = 1:net.N;
			spikeRemoved = randsample(tmpPotentialNeurons(~spikeMask), abs(nbToRemove));
			newSpike = [newSpike; spikeRemoved];
			spikeMask(spikeRemoved) = 1;
			print('Spike added');
        end
		
		%Reset after spike		
		net.v = net.v + (net.IZHI.c - net.v).*(spikeMask); 
		net.IZHI.u = net.IZHI.u + (net.IZHI.d).*(spikeMask); 
		net.v = net.v + (net.IZHI.c - net.v).*(net.v<net.IZHI.c);


	elseif(strcmp(net.firingType, 'LIF'))
		%Voltage equation with refractory period 
		net.dv = (ts.dt*i>net.tlast + net.tref).*(-net.v+net.I)./net.tm; 	
		%Euler integration plus refractory period.  
		net.v = net.v + ts.dt*(net.dv) + sqrt(ts.dt/net.tm)*net.SS*randn(net.N,1); 
		spikeMask = (net.v >= net.vpeak);  %Find the neurons that have spiked
		newSpike = find(spikeMask);
		% Special case if only one spike
		if(length(newSpike) >= 1 & nbToRemove>0)
			if (length(newSpike) == 1)
				spikeRemoved = newSpike;
				newSpike = [];
			else
				spikeRemoved = randsample(newSpike,1);
				newSpike = newSpike(newSpike ~= spikeRemoved)
			end
       
        % Add one spike and reset the neuron
        elseif(nbToRemove < 0)
			%misleading, actually in this case, it is spike added
			tmpPotentialNeurons = 1:net.N;
			spikeRemoved = randsample(tmpPotentialNeurons(~spikeMask), abs(nbToRemove));
			newSpike = [newSpike, spikeRemoved];
			spikeMask(spikeRemoved) = 1;
			print('Spike added');
        end
		
		net.tlast = net.tlast + (ts.dt*i - net.tlast).*(spikeMask);  %Used to set the refractory period of LIF neurons 
        
		%Reset the voltage if bigger then the peak, prevent the voltage from
		%becoming arbitrarily negative 
		net.v = net.v + (net.vreset - net.v).*(spikeMask); 
		net.v = net.v + (net.vreset - net.v).*(net.v<net.vreset);
        
	elseif(strcmp(net.firingType, 'IZHI2'))
		% IZHI provided by Wilten
        % Equations are given per ms in the paper: yes it seems so
		net.IZHI.du = 10^3 * (net.IZHI.a .* (net.IZHI.b .* net.v - net.IZHI.u));
		net.dv = 10^3 * (0.04 * net.v.^2 + 5 * net.v + 140 - net.IZHI.u + net.I);  
	
		net.v = net.v + ts.dt*(net.dv); %Euler integration.
		net.IZHI.u = net.IZHI.u + ts.dt*(net.IZHI.du); %Euler integration .  
		%newSpike = find(net.v >= net.vpeak);  %Find the neurons that have spiked 
        spikeMask = (net.v >= net.vpeak);  %Find the neurons that have spiked
		newSpike = find(spikeMask);
		
		% Special case if only one spike
		% Remove one spike still reset the Neuron
		if(length(newSpike) >= 1 && nbToRemove>0)
			if (length(newSpike) == 1)
				spikeRemoved = newSpike;
				newSpike = [];
			else
				spikeRemoved = randsample(newSpike,1);
				newSpike = newSpike(newSpike ~= spikeRemoved)
			end
			print('Spike removed');
        
		% Add one spike and reset the neuron
        elseif(nbToRemove < 0)
			%misleading, actually in this case, it is spike added
			tmpPotentialNeurons = 1:net.N;
			spikeRemoved = randsample(tmpPotentialNeurons(~spikeMask), abs(nbToRemove));
			newSpike = [newSpike; spikeRemoved];
			spikeMask(spikeRemoved) = 1;
			print('Spike added');
        end
		
		%Reset after spike		
		net.v = net.v + (net.IZHI.c - net.v).*(spikeMask); 
		net.IZHI.u = net.IZHI.u + (net.IZHI.d).*(spikeMask); 
		net.v = net.v + (net.IZHI.c - net.v).*(net.v<net.IZHI.c);	

	end

	%Store spike times, and get the weight matrix column sum of spikers 
	if ~isempty(newSpike)
		net.JD = sum(net.OMEGA(:,newSpike),2); %compute the increase in current due to spiking
	end


	%Synaptic current
	% Code if the rise time is 0, and if the rise time is positive 
	if net.tr == 0  
		net.IPSC = net.IPSC * net.decaytd + net.JD*(sum(spikeMask)>0)/(net.td);
		net.r = net.r * net.decaytd + (spikeMask)/net.td;
	else
		net.IPSC = net.IPSC * net.decaytr + net.h*ts.dt;
		net.h = net.h*net.decaytd;  %Integrate the current
		net.r = net.r*net.decaytr + net.hr*ts.dt; 
		net.hr = net.hr*net.decaytd;

		if ~isempty(newSpike)
			net.h = net.h + net.JD/(net.tr*net.td);
			net.hr = net.hr + (spikeMask)/(net.tr*net.td);
		end
	end

	net.z(:) = net.BPhi' * net.r; %This is the equation for the approximant 
	



end
