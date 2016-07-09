function [net, newSpike] = simulateNeuron(net, ts, fin, i)
	net.I = net.IPSC + net.strengthFB*(net.E*net.z) - net.BIAS + fin; %Neuronal Current 
	
%FS chge the way tlast is done
%SS push after if SS ~=0 only
%FS add more thing in the if(newSpike)
    if(net.SS ~= 0)
        net.v = net.v + sqrt(ts.dt/net.tm)*net.SS*randn(net.N,1);
    end
	
	if(strcmp(net.firingType, 'IZHI'))
	%% Special Izhi (everything is expressed in ms instead of s)
		dt = ts.dt * 1000;
		td = net.td * 1000;
		tr = net.tr * 1000;
    
	%% 2 differential equations IZHI
    	net.IZHI.du = net.IZHI.a .* (net.IZHI.b .* net.v - net.IZHI.u);
		net.dv = 0.04 * net.v.^2 + 5 * net.v + 140 - net.IZHI.u + net.I;  
	
		net.v = net.v + dt*(net.dv); %Euler integration.
		net.IZHI.u = net.IZHI.u + dt*(net.IZHI.du); %Euler integration .  
		%newSpike = find(net.v >= net.vpeak);  %Find the neurons that have spiked 
        spikeMask = (net.v >= net.vpeak);  %Find the neurons that have spiked
		newSpike = find(spikeMask);
		
        
		%Reset after spike		
		net.v = net.v + (net.IZHI.c - net.v).*(spikeMask); 
		net.IZHI.u = net.IZHI.u + (net.IZHI.d).*(spikeMask); 
		% net.v = net.v + (net.IZHI.c - net.v).*(net.v<net.IZHI.c);
	
	elseif(strcmp(net.firingType, 'IZHI_2'))
        %% Special Izhi (everything is expressed in ms instead of s)
		dt = ts.dt * 1000;
		td = net.td * 1000;
		tr = net.tr * 1000;
        
        % Equations are given per ms in the paper??
		net.dv =  (net.IZHI.ff.*(net.v - net.IZHI.vr).*(net.v - net.IZHI.vt) - net.IZHI.u + net.I)/net.IZHI.C ;
		net.IZHI.du = net.IZHI.a *(net.IZHI.b * (net.v - net.IZHI.vr) - net.IZHI.u);  
	
		net.v = net.v + dt*(net.dv); %Euler integration.
		net.IZHI.u = net.IZHI.u + dt*(net.IZHI.du); %Euler integration .  
		%newSpike = find(net.v >= net.vpeak);  %Find the neurons that have spiked 
        spikeMask = (net.v >= net.IZHI.vpeak);  %Find the neurons that have spiked
		newSpike = find(spikeMask);
		
        
		%Reset after spike		
		net.v = net.v + (net.IZHI.vreset - net.v).*(spikeMask); 
		net.IZHI.u = net.IZHI.u + (net.IZHI.d).*(spikeMask); 



	elseif(strcmp(net.firingType, 'LIF'))
	%% All the temporal constants are kept in ms
		dt = ts.dt;
		td = net.td;
		tr = net.tr;
		
	%Voltage equation with refractory period 
		net.dv = (dt*i>net.tlast + net.tref).*(-net.v+net.I)./net.tm; 	
		%Euler integration plus refractory period.  
		net.v = net.v + dt*(net.dv) + sqrt(dt/net.tm)*net.SS*randn(net.N,1); 
		spikeMask = (net.v >= net.vpeak);  %Find the neurons that have spiked
		newSpike = find(spikeMask);
        	net.tlast = net.tlast + (dt*i - net.tlast).*(spikeMask);  %Used to set the refractory period of LIF neurons 
        
		%Reset the voltage if bigger then the peak, prevent the voltage from
		%becoming arbitrarily negative 
		net.v = net.v + (net.vreset - net.v).*(spikeMask); 
		net.v = net.v + (net.vreset - net.v).*(net.v<net.vreset);
        

	end

	%Store spike times, and get the weight matrix column sum of spikers 
	if ~isempty(newSpike)
		net.JD = sum(net.OMEGA(:,newSpike),2); %compute the increase in current due to spiking

	end


	%Synaptic current
	% Code if the rise time is 0, and if the rise time is positive 
	if net.tr == 0  
		net.IPSC = net.IPSC * net.decaytd + net.JD*(sum(spikeMask)>0)/(td);
		net.r = net.r * net.decaytd + (spikeMask)/td;
    else		
		net.IPSC = net.IPSC * net.decaytr + net.h*dt;
		net.h = net.h*net.decaytd;  %Integrate the current
		net.r = net.r*net.decaytr + net.hr*dt; 
		net.hr = net.hr*net.decaytd;

		if ~isempty(newSpike)
			net.h = net.h + net.JD/(tr*td);
			net.hr = net.hr + (spikeMask)/(tr*td);
		end
	end
	% to cope with the fact that IZHI equations are for a dt in ms
% 	if (strcmp(net.firingType, 'IZHI_2') | strcmp(net.firingType, 'IZHI'))
% 		net.IPSC = net.IPSC/1000;
% 	end
	
	
	net.z(:) = net.BPhi' * net.r; %This is the equation for the approximant 
	



end
