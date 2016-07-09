clear all
addpath('..\Initialize');
addpath('..\Neuron');
addpath('..\Learning');
addpath('..\Utilities');
addpath('..\Analysis');
clc 


%% SetUp simulation
 ts = timeSimulation(2, 12, 6, 0.00004, 50);
 params = genParamsNetwork(5, ts);
 params.G = 35000;
 params.strengthFB = 3*10^3;
 params.alpha = 2;
 params.learningType = 'FORCE_Abb';
 nw = genNetwork(params, ts);
 io = genIO(2, ts);
 nw.BIAS = -1000;
 
% Init special IZHI
 nw.v = nw.IZHI.vr + (nw.IZHI.vpeak - nw.IZHI.vr) * rand(nw.N, 1);
 
% Storage
current = zeros(ts.nt,1);  %storage variable for output current/approximant 
tspike = zeros(100 * ts.nt, 2, 'uint32'); %Storage variable for spike times 
ns = 0; %Number of spikes, counts during simulation  
RECI = zeros(ts.nt,10);
RECB = zeros(ts.nt,10);  %Storage matrix for the synaptic weights (a subset of them) 
RECV = zeros(ts.nt,1);   %Storage matrix for 1 Membrane potential
RECUaverage = zeros(ts.nt,1);
RECVaverage = zeros(ts.nt,1);
RECRaverage = zeros(ts.nt,1);
REC10V = zeros(ts.nt,10);


 
%%
for i = 1:1:ts.nt 
% Simulate
	[nw, newSpike] = simulateNeuron(nw, ts, io.fin(i), i);

% Storage
    current(i,1) = nw.z;
    RECRaverage(i,1) = mean(nw.r);
	RECV(i,1) = nw.v(1);
	RECB(i,:) = nw.BPhi(1:10);
    RECUaverage(i) = mean(nw.IZHI.u);
    RECVaverage(i) = mean(nw.v);
    REC10V(i,:) = nw.v(1:10);
    if (size(newSpike, 1) > 0)
        tspike((ns+1):(ns+length(newSpike)),:) = [newSpike,repmat(i, size(newSpike, 1), 1)];
    end
    ns = ns + length(newSpike);  % total tref number of psikes so far

    
% Learning
	if (i > ts.imin && i < ts.icrit && mod(i,ts.stepLearning)== 1)
        err = nw.z - io.fout(i); %error 
		nw = learnFORCE(nw, err);
    end

% Some prints    
	if mod(i,round(1/ts.dt))==1
		ts.dt*i

        drawnow
        iMinus3 = max(1,i - round(3000/ts.dt));  %only plot for last 3 seconds
        indexRange = 1:1:i;
        timeRange = indexRange * ts.dt;
        indexRangeBis = iMinus3:1:i;
        timeRangeBis = indexRangeBis * ts.dt;
        
        figure(10)
        plot(timeRangeBis, current(indexRangeBis,1)), hold on  
        plot(timeRangeBis, io.fout(indexRangeBis),'k--'), hold off 
        xlabel('Time (s)')
        ylabel('$\hat{x}(t)$','Interpreter','LaTeX')
        legend('Approximant','Target Signal')
        %xlim([ts.dt*i-3000,ts.dt*i]/1000)

        figure(11)
        plot(timeRange,RECB(indexRange,:))
	end
end


%% Study quality learning
afterLearningRange = (ts.icrit:1:ts.nt);
indic_error1 = std(io.fout(afterLearningRange) -current(afterLearningRange)) / std(io.fout(afterLearningRange));





%% EXTRA INFOS
% i_1sec = 1/ts.dt;
% tspike = tspike(tspike(:,2)>i_1sec,:);
if(0)
    plotSpikesInfo(tspike, nw, ts)

    figure(5)
    plot(ts.timeRange, current)

    figure(4)
    plotyy(ts.timeRange, RECVaverage, ts.timeRange, RECUaverage)
    legend('v', 'u')

    figure(5)
    plot(ts.timeRange, current)

    figure(7)
    plot(timeAxis, REC10V(timeIndex))
end


