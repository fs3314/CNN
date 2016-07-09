function rate = rollingMeanFiringRate(tSpike, step, windows)
	% Assume tspike is sorted by T, N
	% mod(step, 

    tmp = tSpike(tSpike(:, 1) ~= 0, :); 
    maxTime = max(tmp(:,2));
    nbStepPerW = windows/step;
    nbStep = ceil(double(maxTime)/step);
    tmpArray = zeros(nbStepPerW, 1);    
    rate = zeros(max(nbStep - nbStepPerW + 1,1), 1);
    nbSpike = size(tmp, 1);

    j = 1; % index step
    k = 1;
    accuTmp = 0;

    for i = 1:1:nbSpike
        if(tmp(i, 2) < j*step)
            accuTmp = accuTmp + 1;
        else		
            while(tmp(i, 2) >= j*step)
                tmpArray(k) = accuTmp;            
                if (j >= nbStepPerW)
                    rate(j - nbStepPerW + 1) = sum(tmpArray);
                end
                j = j+1;
                k = mod(j-1, nbStepPerW)+1;
                accuTmp = 0;
            end
            accuTmp=1;
        end	

    end
    
    % 
    if(nbStep - nbStepPerW + 1 > 1)
        rate(nbStep - nbStepPerW + 1) = rate(nbStep - nbStepPerW);
    elseif (j == 1)
        rate(j) = accuTmp;
    end
    
end
