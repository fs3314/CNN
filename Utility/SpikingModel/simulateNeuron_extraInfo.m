function [net, newSpike] = simulateNeuron_extrainfo(net, ts, fin, i)
	net.I = net.IPSC + net.strengthFB*(net.E*net.z) - net.BIAS + fin; %Neuronal Current 
	
%FS chge the way tlast is done
%SS push after if SS ~=0 only
%FS add more thing in the if(newSpike)
    if(net.SS ~= 0)
        net.v = net.v + sqrt(ts.dt/net.tm)*net.SS*randn(net.N,1);
    end
	
	if(strcmp(net.firingType, 'IZHI'))
        test = net.v;	
        test2 = net.dv;	
		% 2 differential equations IZHI
		net.IZHI.du = net.IZHI.a .* (net.IZHI.b .* net.v - net.IZHI.u);
		net.dv = 0.04 * net.v.^2 + 5 * net.v + 140 - net.IZHI.u + net.I;  
	
		net.v = net.v + ts.dt*(net.dv); %Euler integration.
		net.IZHI.u = net.IZHI.u + ts.dt*(net.IZHI.du); %Euler integration .  
		%newSpike = find(net.v >= net.vpeak);  %Find the neurons that have spiked 
        spikeMask = (net.v >= net.vpeak);  %Find the neurons that have spiked
		newSpike = find(spikeMask);
		
        
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
        newSpike_E = find(spikeMask(net.indexE));
		newSpike_I = find(spikeMask(net.indexI));
		net.tlast = net.tlast + (ts.dt*i - net.tlast).*(spikeMask);  %Used to set the refractory period of LIF neurons 
        
		%Reset the voltage if bigger then the peak, prevent the voltage from
		%becoming arbitrarily negative 
		net.v = net.v + (net.vreset - net.v).*(spikeMask); 
		net.v = net.v + (net.vreset - net.v).*(net.v<net.vreset);
        

	end

	%Store spike times, and get the weight matrix column sum of spikers 
	if ~isempty(newSpike)
		if(strcmp(params.architectureType, 'Random'))
			spikesProjection = net.OMEGA_E(:,newSpike_E);
			spikesE = spikesProjection >0 ;
			net.JD_E = sum(spikesProjection(spikesE), 2);
			net.JD_I = sum(spikesProjection(~spikesE), 2);
		else
			net.JD_E = sum(net.OMEGA_E(:,newSpike_E), 2); %compute the increase in current due to spiking
			net.JD_I = sum(net.OMEGA_I(:,newSpike_I), 2); %compute the increase in current due to spiking
		end
	end


	%Synaptic current
	% Code if the rise time is 0, and if the rise time is positive 
	if net.tr == 0  
        %TBC
		net.IPSC_E = net.IPSC_E * net.decaytd ;
		net.IPSC_I = net.IPSC_I * net.decaytd ;   
			if ~isempty(newSpike)
				net.IPSC_E = net.IPSC_E + net.JD_E / (net.td);
				net.IPSC_I = net.IPSC_I + net.JD_I / (net.td);
			end
        net.IPSC = net.IPSC_E + net.IPSC_I;
		net.r = net.r * net.decaytd + (spikeMask)/net.td;
		
    else
        %Postsynaptic current received by neurons (from all the other neurons)
		%Splitted E/I
		net.IPSC_E = net.IPSC_E * net.decaytr + net.h_E*ts.dt;
		net.h_E = net.h_E * net.decaytd;  %Integrate the current
		
		net.IPSC_I = net.IPSC_I * net.decaytr + net.h_I*ts.dt;
		net.h_I = net.h_I * net.decaytd;  %Integrate the current
		
		net.IPSC = net.IPSC_E + net.IPSC_I;
		
        %Postsynaptic current produced by each neuron
		net.r = net.r*net.decaytr + net.hr*ts.dt; 
		net.hr = net.hr*net.decaytd;

		if ~isempty(newSpike)
            net.h_E = net.h_E + net.JD_E/(net.tr*net.td);
			net.h_I = net.h_I + net.JD_I/(net.tr*net.td);
            
			net.hr = net.hr + (spikeMask)/(net.tr*net.td);
		end
	end

	net.z(:) = net.BPhi' * net.r; %This is the equation for the approximant 
	



end
