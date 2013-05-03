

%First, load up some data from the directory where you saved it. 
load params;
load LIPdata;
load CARdata;
load DDMdata


%PICK ONE OF THESE:
%To run LIPdata:
data= LIPdata;
%To run simulation data from a Drift-diffusion model
data = DDMdata;
%To run simulation data from a variable rate-of-rise model
data = CARdata;



%THEN RUN THIS CODE.
params.conditional_FF = [data.phi]';
params.alignTime = data(1).pre_dot_time; %This is the time before the stimulus actually starts. 

times = [params.boxWidth/2:params.boxWidth:size(data(1).spikes,2)-((params.boxWidth/2)+1)];

%params.conditional_FF = mean(params.conditional_FF) * ones(size(params.conditional_FF));
%sprintf('warning: NO CUSTOM PHI!')
Result= compute_VarCE(data,times,params);


clf;
subplot(2,2,1)
plot(Result.times,Result.meanRateAll); hold on;
errorbar(Result.times,Result.meanRateAll,Result.stdErrOfRate);
set(gca,'box','off');xlabel('Time');ylabel('Mean Firing Rate (sp/s)');
set(gca,'xlim',[Result.times(1) Result.times(end)])

subplot(2,2,3)
plot(Result.times,Result.VarCE); hold on;
errorbar(Result.times,Result.VarCE,Result.VarCE_std_errors);
set(gca,'box','off');xlabel('Time');ylabel('VarCE');
set(gca,'xlim',[Result.times(1) Result.times(end)])

subplot(2,2,4);
imagesc(Result.CorCE,[0 1])


