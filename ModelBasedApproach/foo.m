close all;
clear all;

N           = 15;                              % number of neurons for simulation
Nplot       = 15;                               % number of neurons for visuals
R           = 50;                               % mean population firing rate

popDensity  = 'optimal';                        % cell population density ('uniform' or 'optimal'
popGain     = 'optimal';                        % cell population response gain ('uniform' or 'optimal')

showPlots   = 0;                                % don't plot individual simulations

feature     = 'disp';

% uniform population for plotting
model = build_model_cell_population(popDensity,popGain,showPlots,R,N,feature);

figure;  hold on;
plot_tuning_curves(model)
    
keyboard

% optimal density, uniform gain population for plotting
[~,~,~,fnON,fnOFF,prefs_new,resp_inc,resp_dec,~,env_inc,env_dec,env_all,~] = SPLModelBuild_complexCells(popType,popGain1,showPlots,Rplot,Nplot,dp,r_inc,gDiff,feature);
[MI,MIBr,MIDk,minDisc,minDiscON,minDiscOFF] = calc_effect_of_firing_rate(popType,popGain1,Rsim,Nsim,dp,r_inc,gDiff,feature);

% optimal density, optimal gain
[~,~,~,fnON2,fnOFF2,prefs_new2,resp_inc2,resp_dec2,~,~,~,~,~] = SPLModelBuild_complexCells(popType,popGain2,showPlots,Rplot,Nplot,dp,r_inc,gDiff,feature);
[MI2,MIBr2,MIDk2,minDisc2,minDiscON2,minDiscOFF2] = calc_effect_of_firing_rate(popType,popGain2,Rsim,Nsim,dp,r_inc,gDiff,feature);

if(1)
    
    % plot environmental probabilities
    subaxis(2,4,1,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
    plot_env_probabilities(disps,r_inc,env_inc,env_dec,env_all,prefs_new,feature)
    
    
    % overall tuning density for uniform and optimized population
    subaxis(4,4,9,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
    %plot_tuning_curves(Nplot,disps,0.5*resp_dec,-0.15,prefs_new,'k',[],[],[],1)
    plot_tuning_curves(Nplot,disps,0.5*resp_dec_orig,0.35,prefs_orig,'k',[],[],[],1)
    
    
    % tuning functions for equal and learned gains
    subaxis(4,3,2,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
    plot_tuning_curves(Nplot,disps,0.5*resp_dec,0.25,[],'b--','Equal Weights',feature,'OFF',1)
    plot_tuning_curves(Nplot,disps,0.5*resp_inc,-0.25,prefs_new,'r',[],[],'ON',1)
    axis square
    
    subaxis(4,3,3,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
    plot_tuning_curves(Nplot,disps,0.5*resp_dec2,0.25,[],'b--','Unequal Weights',feature,'OFF',1)
    plot_tuning_curves(Nplot,disps,0.5*resp_inc2,-0.25,prefs_new2,'r',[],[],'ON',1)
    axis square
    
    
    % Fisher info for equal and learned gains
    fnMax = max([fnON fnOFF fnON2 fnOFF2]) + 0.05*range([fnON fnOFF fnON2 fnOFF2]);
    fnMin = min([fnON fnOFF fnON2 fnOFF2]) - 0.05*range([fnON fnOFF fnON2 fnOFF2]);
    subaxis(4,3,5,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
    plot_fisher(disps,fnON,'r',[fnMin fnMax],feature)
    plot_fisher(disps,fnOFF,'b--',[fnMin fnMax],feature)
    
    subaxis(4,3,6,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
    plot_fisher(disps,fnON2,'r',[fnMin fnMax],feature)
    plot_fisher(disps,fnOFF2,'b--',[fnMin fnMax],feature)
    
    
    % % discrimination thresholds for equal and learned gains
    % discMax = max(1./sqrt([fnON fnOFF fnON2 fnOFF2])) + 0.05*range(1./sqrt([fnON fnOFF fnON2 fnOFF2]));
    % discMin = min(1./sqrt([fnON fnOFF fnON2 fnOFF2])) - 0.05*range(1./sqrt([fnON fnOFF fnON2 fnOFF2]));
    % subaxis(4,6,10,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
    % plot_discrimination(disps,fnON,'r',[discMin discMax],feature)
    % plot_discrimination(disps,fnOFF,'b--',[discMin discMax],feature)
    %
    % subaxis(4,6,12,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
    % plot_discrimination(disps,fnON2,'r',[discMin discMax],feature)
    % plot_discrimination(disps,fnOFF2,'b--',[discMin discMax],feature)
    
    
    % mutual info as a function of spike rate
    miMax = max([MI MI2 MIBr MIBr2 MIDk MIDk2]) + 0.05*range([MI MI2 MIBr MIBr2 MIDk MIDk2]);
    miMin = min([MI MI2 MIBr MIBr2 MIDk MIDk2]) - 0.05*range([MI MI2 MIBr MIBr2 MIDk MIDk2]);
    subaxis(4,3,8,'Spacing',spac, 'Padding',pad, 'Margin',marg);
    plot_X_for_Rs(Rsim,MI,MIBr,MIDk,[miMin miMax],'mutual information')
    
    subaxis(4,3,9,'Spacing',spac, 'Padding',pad, 'Margin',marg);
    plot_X_for_Rs(Rsim,MI2,MIBr2,MIDk2,[miMin miMax],'mutual information')
    
    
    % % minimum discrimination as a function of spike rate
    % dMax = max([minDisc minDiscON minDiscOFF minDisc2 minDiscON2 minDiscOFF2]) + 0.05*range([minDisc minDiscON minDiscOFF minDisc2 minDiscON2 minDiscOFF2]);
    % dMin = min([minDisc minDiscON minDiscOFF minDisc2 minDiscON2 minDiscOFF2]) - 0.01*range([minDisc minDiscON minDiscOFF minDisc2 minDiscON2 minDiscOFF2]);
    % subaxis(4,6,16,'Spacing',spac, 'Padding',pad, 'Margin',marg);
    % plot_X_for_Rs(Rsim,minDisc,minDiscON,minDiscOFF,[dMin dMax],'discrimination')
    %
    % subaxis(4,6,18,'Spacing',spac, 'Padding',pad, 'Margin',marg);
    % plot_X_for_Rs(Rsim,minDisc2,minDiscON2,minDiscOFF2,[dMin dMax],'discrimination')
    
end

if(0)
    figure(); hold on;
    set(gcf,'color','w');
    
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [2 1 6 3]);
    
    
    subaxis(2,4,1,'Spacing', 0.01, 'Padding', 0.01, 'Margin', 0.1);
    
    colors = {'k','m','g'};
    ps = [0.5 0.4 0.3];
    
    
    for j = 1:3
        [gains,spike_gain,spike_gain_disc] = calc_efficiency_increase_by_gain(popType,popGain1,popGain2,Nsim,dp,ps(j),feature);
        
        h(1) = plot(1 - gains,spike_gain,[colors{j} '-']); hold on;
        plot(1 - [ps(j) ps(j)],[min(spike_gain) spike_gain(gains == 1 - ps(j))],[colors{j} ':'])
        plot([min(1 - gains) 1 - ps(j)],[spike_gain(1 - gains == 1 - ps(j)) spike_gain(1 - gains == 1 - ps(j))],[colors{j} ':'])
        
        
        xlim([min(1 - gains) max(1 - gains)]);
        
    end
    
    plot(1 - gains,zeros(1,length(gains)),'k--');
    ylim([-40 10]);
    xlabel('wf/2');
    ylabel('% fewer input spikes');
    
    features = {'f','orientation','freq','disp'};
    
    subaxis(2,4,2,'Spacing', 0.01, 'Padding', 0.01, 'Margin', 0.1); title(feature);
    
    
    for f = 1:4
        [gains,spike_gain,spike_gain_disc] = calc_efficiency_increase_by_gain(popType,popGain1,popGain2,Nsim,dp,r_inc,features{f});
        
        perc(f) = spike_gain(gains == r_inc);
        
    end
    
    hb = bar(perc);
    axis square;
    
end


if(0)
    
    figure(); hold on;
    set(gcf,'color','w');
    
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [2 1 6 3]);
    
    features = {'orientation','freq','disp'};
    
    for f = 1:3
        
        [~,~,~,fnON2,fnOFF2,prefs_new2,resp_inc2,resp_dec2,disps,~,~,~,~] = SPLModelBuild_complexCells(1,popGain2,showPlots,Rplot,Nplot,dp,r_inc,gDiff,features{f});
        
        subaxis(2,4,f,'Spacing', 0.01, 'Padding', 0.01, 'Margin', 0.1); hold on;
        
        plot_discrimination_difference(disps,fnON2,fnOFF2,'k',features{f});
        ylim([0.8 1.8]);
        plot(disps,ones(1,length(disps)),'k:')
        
        axis square
        
    end
      
    
end


if(0)
    figure(); hold on;
    set(gcf,'color','w');
    
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [2 1 6 3]);
    
    
    subaxis(2,4,1,'Spacing', 0.01, 'Padding', 0.01, 'Margin', 0.1);
    
    colors = {'k','m','g'};
    ps = [0.5 0.4 0.3];
    
    
    for j = 1:3
        [gains,spike_gain,spike_gain_disc] = calc_efficiency_increase_by_gain(popType,popGain1,popGain2,Nsim,dp,ps(j),feature);
        
        h(1) = plot(1 - gains,spike_gain_disc,[colors{j} '-']); hold on;
        plot(1 - [ps(j) ps(j)],[min(spike_gain_disc) spike_gain_disc(gains == 1 - ps(j))],[colors{j} ':'])
        plot([min(1 - gains) 1 - ps(j)],[spike_gain_disc(1 - gains == 1 - ps(j)) spike_gain_disc(1 - gains == 1 - ps(j))],[colors{j} ':'])
        
        
        xlim([min(1 - gains) max(1 - gains)]);
        
    end
    
    plot(1 - gains,zeros(1,length(gains)),'k--');
    ylim([-40 10]);
    xlabel('wf/2');
    ylabel('% fewer input spikes');
    
    features = {'f','orientation','freq','disp'};
    
    subaxis(2,4,2,'Spacing', 0.01, 'Padding', 0.01, 'Margin', 0.1); title(feature);
    
    
    for f = 1:4
        [gains,spike_gain_disc,spike_gain_disc_disc] = calc_efficiency_increase_by_gain(popType,popGain1,popGain2,Nsim,dp,r_inc,features{f});
        
        perc(f) = spike_gain_disc(gains == r_inc);
        
    end
    
    hb = bar(perc);
    axis square;
    
end




addpath('./helper_functions_plotting/')

font = 15;
set(0,'defaultlinelinewidth',1)
set(0,'DefaultTextFontWeight', 'normal')
set(0,'DefaultAxesFontSize', font)
set(0,'DefaultTextFontSize', font)
spac = 0.02;
pad = 0.01;
marg = 0.1;

figure(); hold on;
set(gcf,'color','w');

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [2 1 5.5 6]);


% [gains,spike_gain,spike_gain_disc] = calc_efficiency_increase_by_gain(popType,popGain1,popGain2,Nsim,dp,0.4,feature);
%
% h(1) = plot(1 - gains,spike_gain,'m-'); hold on;
% plot(1 - [r_inc r_inc],[min(spike_gain) spike_gain(gains == 1 - r_inc)],'m:')
% plot([min(1 - gains) 1 - r_inc],[spike_gain(1 - gains == 1 - r_inc) spike_gain(1 - gains == 1 - r_inc)],'m:')
%
% xlim([min(1 - gains) max(1 - gains)]);
%
%
% [gains,spike_gain,spike_gain_disc] = calc_efficiency_increase_by_gain(popType,popGain1,popGain2,Nsim,dp,0.3,feature);
%
% h(1) = plot(1 - gains,spike_gain,'g-'); hold on;
% plot(1 - [r_inc r_inc],[min(spike_gain) spike_gain(gains == 1 - r_inc)],'g:')
% plot([min(1 - gains) 1 - r_inc],[spike_gain(1 - gains == 1 - r_inc) spike_gain(1 - gains == 1 - r_inc)],'g:')
%
% xlim([min(1 - gains) max(1 - gains)]);


%xlabel('wf/2');
%ylabel('% fewer input spikes');
%legend(h,'same info','same disc');


