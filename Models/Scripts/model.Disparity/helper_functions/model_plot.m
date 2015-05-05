function [] = model_plot(disps,env_inc,env_dec,env_all,pop,warp,N,prefs,resp_inc,resp_dec,gain,fnON,fnOFF)

set(0,'DefaultFigureWindowStyle','docked')
set(0,'defaultlinelinewidth',1)

figure; hold on;
subplot(2,3,1); hold on; title('environmental probability distributions');
plot( disps ,  env_inc , 'r' );
plot( disps ,  env_dec , 'b:' );
plot( disps ,  env_all , 'k--' );
plot( disps ,  pop     , 'm:' );


subplot(2,3,2); hold on; title('cell density warping function');
xlabel('new preference');
ylabel('original preference');
plot(disps , warp ,      'k')
plot(prefs , min(disps) ,'k.')


subplot(2,3,3); hold on;
colors  = jet(N);

for d = 1:N
    
    plot(disps,resp_inc(d,:) + 0.5,'color',colors(d,:),'linewidth',1)
    plot(disps,resp_dec(d,:) - 0.5,'color',colors(d,:),'linewidth',1)
    plot(prefs(d), -0.5,'k.')
    
end

ylim([-0.5 1.5]);
xlim([-60 60]);

subplot(2,3,4); hold on; title('population activity sum');
plot(disps,sum(resp_inc,1),'r-','linewidth',1)
plot(disps,sum(resp_dec,1),'b:','linewidth',1)
plot(disps,sum([resp_inc ; resp_dec],1),'k--','linewidth',1)

subplot(2,3,5); hold on;
plot(disps(1:end-1),(max(fnON)/max(fnON + fnOFF))*fnON/max(fnON),'r-','linewidth',1)
plot(disps(1:end-1),(max(fnOFF)/max(fnON + fnOFF))*fnOFF/max(fnOFF),'b:','linewidth',1)
plot(disps(1:end-1),(fnOFF + fnON)/max(fnOFF + fnON),'y-','linewidth',1)

plot( disps ,  (max(env_inc)/max(env_all))*(env_inc.^2)/max(env_inc.^2) , 'r' );
plot( disps ,  (max(env_dec)/max(env_all))*(env_dec.^2)/max(env_dec.^2) , 'b:' );
plot( disps ,  (env_all.^2)/max(env_all.^2) , 'k--' );

title('scene priors (squared) and fisher information');


