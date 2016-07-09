function pSpike = ISIperN(tSpike)
	% Assume tspike is sorted by T, N
	% Add new params neuronMask, timeMask
    
    tmp = tSpike(tSpike(:, 1) ~= 0, :); 
	nbSpike = size(tmp, 1);
	tmp = sortrows(tmp);

    diff_neuron = diff(tmp(:, 1));
    diff_time = diff(tmp(:, 2));
    mask1 = (diff_neuron  == 0);    
  
  
    pSpike = zeros(sum(mask1), 2);
    pSpike = [tmp( [boolean(0), transpose(mask1)], 1), diff_time(mask1)];
    pSpike = double(pSpike);
    
    
end
