function signal = freqSpikes(nt, dt, tr, td, freq, scale)
% gen spikes with 
	signal = zeros(nt, 1);
	stepSpike = ceil(1/(freq * dt));
	
	if (tr>0)
		h = scale/(tr * td);
		signal(1) = 0;
		for i = 2:1:nt
			signal(i) = signal(i-1)*exp(-dt/tr) + h*dt;
			h = h*exp(-dt/td);  
			if(mod(i, stepSpike)==0)
				h = h + scale/(tr *td);  %Integrate the current
			end
		end

	else
		% TobeCompleted
    end

end