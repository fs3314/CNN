clear all
addpath(genpath('..\..\Utility')) % access to all the folders inside Utility


%% Custom NW for one neuron
 ts = timeSimulation(2, 0, 0, 0.00005, 1);
 params = genParamsNetwork(2, ts);
 params.N = 1;
 params.G = 0;
 params.strengthFB = 0;
 nw = genNetwork(params, ts);
 nw.BIAS = 0;
 nw.BPhi = 1;
 nw.v = nw.IZHI.c;
 
% Storage
current = zeros(ts.nt,1);  %storage variable for output current/approximant 
tspike = zeros(25 * ts.nt, 2, 'uint32'); %Storage variable for spike times 
ns = 0; %Number of spikes, counts during simulation  
RECV = zeros(ts.nt,1);   %Storage matrix for 1 Membrane potential


 rheobase = 4
 

%%
for i = 1:1:ts.nt 
	[nw, newSpike] = simulateNeuron(nw, ts, rheobase , i);
	
    %store1
    current(i,1) = nw.r;
	RECV(i,1) = nw.v(1);
    if (size(newSpike, 1) > 0)
        tspike((ns+1):(ns+length(newSpike)),:) = [newSpike,repmat(i, size(newSpike, 1), 1)];
    end
    ns = ns + length(newSpike);  % total trefnumber of psikes so far

end

%% Analysis firing
figure(1)
plot(ts.timeRange, current * 1000), hold on
plot(ts.timeRange, rheobase*ones(ts.nt,1)), hold off
legend('currentOut * 1000', 'currentIn')
%plot4main( i, ts.dt, io.fout, ns, tspike, current, RECB, RECV)


figure(3)
plot(RECV)

