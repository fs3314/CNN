function CVperNeuron = CV(tSpike, nbNeurons, dt)
	% Assume tspike is sorted by T, N
       
	%clean tspike
    tmp = tSpike(tSpike(:, 1) ~= 0, :); 
	nbSpike = size(tmp, 1);
	tmp = sortrows(tmp);
	
	CVperNeuron = zeros(nbNeurons, 1);
	
    ISI = diff(tmp(:, 2));
    
    nbTemp = 0;
	indexTmp = 1;
	sumTmp = 0;
	sumSquareTmp = 0;
  
	for i = 2:1:nbSpike
		if(tmp(i, 1) == indexTmp)
			nbTemp = nbTemp + 1;
            ISITmp = double(ISI(i-1))*dt; % ISI in s
			sumTmp = sumTmp + ISITmp;
			sumSquareTmp = sumSquareTmp + ISITmp^2;
		
		else %New neuron don't add anything
			CVperNeuron(indexTmp) = nbTemp * sumSquareTmp/(sumTmp^2) - 1;
            
			nbTemp = 0;
			indexTmp = tmp(i, 1);
			sumTmp = 0;
			sumSquareTmp = 0;
		end
	end
  
    
end
