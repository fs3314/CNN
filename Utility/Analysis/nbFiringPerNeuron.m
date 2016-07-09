function firings = nbFiringPerNeuron(tSpike, N)
	% Assume tspike is sorted by T, N
	% mod(step, 

	tmp = tSpike(tSpike(:, 1) ~= 0, :); 
	nbSpike = size(tmp, 1);
	tmp = sortrows(tmp);
  
    firings = zeros(N, 1);    
	iNeuron = 1;
	accuTmp = 0;
       
	
    for i = 1:1:nbSpike
        if (tmp(i, 1) == iNeuron)
			accuTmp = accuTmp + 1;
		else
			firings(iNeuron) = accuTmp;
			iNeuron = tmp(i, 1);
			accuTmp = 1;
		end
    end


    
end
