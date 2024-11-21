function plotHVDC(Data,Tsim)
%UNTITLED2 Summary of this function goes here
PS1 = getsamples(Data.PST1,find(Data.tout==0.2):find(Data.tout==Tsim))/1e6;
PS2 = getsamples(Data.PST2,find(Data.tout==0.2):find(Data.tout==Tsim))/1e6;
PS3 = getsamples(Data.PST3,find(Data.tout==0.2):find(Data.tout==Tsim))/1e6;
PS4 = getsamples(Data.PST4,find(Data.tout==0.2):find(Data.tout==Tsim))/1e6;
PS5 = getsamples(Data.PST5,find(Data.tout==0.2):find(Data.tout==Tsim))/1e6;
PS6 = getsamples(Data.PST6,find(Data.tout==0.2):find(Data.tout==Tsim))/1e6;
V1 = getsamples(Data.Vabc,find(Data.tout==0.2):find(Data.tout==Tsim));
I1 = getsamples(Data.Iabc,find(Data.tout==0.2):find(Data.tout==Tsim));
V = getsamples(Data.Vmag,find(Data.tout==0.2):find(Data.tout==Tsim));
F = getsamples(Data.f,find(Data.tout==0.2):find(Data.tout==Tsim));
aboveLinev = (V.Data>1.1 | V.Data<0.9);
% Create 2 copies of v
bottomLinev = V.Data;
topLinev = V.Data;
% Set the values you don't want to get drawn to nan
bottomLinev(aboveLinev) = NaN;
topLinev(~aboveLinev) = NaN;
%%
aboveLinef = (F.Data>61.2 | F.Data<58.8);
% Create 2 copies of v
bottomLinef = F.Data;
topLinef = F.Data;
% Set the values you don't want to get drawn to nan
bottomLinef(aboveLinef) = NaN;
topLinef(~aboveLinef) = NaN;
c=figure;
subplot(2,2,1)
plot(PS1)
hold on;
plot(PS2);
plot(PS3);
xlim([0.5 Tsim])
ylim([0 500])
ylabel('MW');
grid on;
legend('P_{Station 1}','P_{Station 2}','P_{Station 3}',Location='best');
title('Real Power From Onshore Stations')
subplot(2,2,2)
plot(PS4)
hold on;
plot(PS5);
plot(PS6);
xlim([0.5 Tsim])
ylabel('MW');
grid on;
legend('P_{Station 4}','P_{Station 5}','P_{Station 6}',Location='best');
title('Real Power From Offshore Stations')
subplot(2,2,3)
plot(V.Time,bottomLinev,V.time,topLinev);
hold on;
plot(Data.tout,1.1*ones(size(Data.tout)),'--g');
plot(Data.tout,0.9*ones(size(Data.tout)),'--g');
xlim([0.5 Tsim]);
xlabel('Time (sec)');
ylabel('PU');
grid on;
d=find(V.Data>1.1 | V.Data<0.9);
if(length(d)>0)
     lgd=legend('V_{mag}','V_{out of limit}','V_{limits}',Location='best'); 
else
    lgd=legend('V_{mag}','','V_{limits}',Location='best');
end
title('Volatge Magnitude at Onshore Station 1')
subplot(2,2,4)
plot(F.Time,bottomLinef,F.time,topLinef);
hold on;
plot(Data.tout,61.2*ones(size(Data.tout)),'--g');
plot(Data.tout,58.8*ones(size(Data.tout)),'--g');
xlim([0.5 Tsim]);
xlabel('Time (sec)');
ylabel('Hz');
grid on;
df=find(F.Data>61.2 | F.Data<58.8);
if(length(df)>0)
     lgd=legend('F','F_{out of limit}','F_{limits}',Location='best'); 
else
    lgd=legend('F','','F_{limits}',Location='best');
end
title('Onshore Frequency at POI')
set(c,'position',[0,0,700,400]); 
d=figure;
subplot(2,1,1)
plot(V1);
xlim([0.5 Tsim])
ylim([-2 2])
ylabel('PU');
grid on;
title('Volatges at Onshore Station 1')
subplot(2,1,2)
plot(I1);
xlim([0.5 Tsim])
ylim([-2 2])
ylabel('PU');
grid on;
title('Currents at Onshore Station 1')
end