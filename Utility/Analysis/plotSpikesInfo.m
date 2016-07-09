function plotSpikesInfo(tspike, nw, ts)
	% pspike(:,2) is expressed in time indices (instead of s or ms)

	%ISI%
	ISI = ISIperN(tspike);
	figure(41)
	histogram((ISI(:,2) * ts.dt).^(-1));
	title('Histo ISI^(-1)')

	%Average Firing per period of time
	stepFreq = 0.25;
	windowFreq = 0.5;
	rollingMean = rollingMeanFiringRate(tspike, stepFreq/ts.dt, windowFreq/ts.dt);
	fRate = rollingMean /(nw.N*windowFreq);
	timeFreqAxis = (1:size(fRate, 1)) * stepFreq;
	figure(42)
	plot(timeFreqAxis, fRate)
	title('Mean Frequ of firing over time')


	% Histo mean frequ of Firing per Neuron
	figure(43)
	fperN = nbFiringPerNeuron(tspike, nw.N);
	period = ts.dt * double(max(tspike(:,2)) - min(tspike(:,2)));
	meanFreq = fperN / period;
	histogram(meanFreq(meanFreq>1),50);
	title('Histo Mean Frequ by Neuron')
	print('mean Frequ')
	mean(meanFreq)

	figure(44)
	CVperN = CV(tspike, nw.N, ts.dt);
	histogram(CVperN);
	title('Histo CV per Neuron')
	print('mean CV')
	mean(CVperN(~isnan(CVperN) & CVperN ~= 0))

    figure(45)
    plot(double(tspike(:,2))*ts.dt,tspike(:,1),'k.')
    %xlim([dt*i-5,dt*i])
    ylim([0,40])
    title('RasterPlot')
    
end
