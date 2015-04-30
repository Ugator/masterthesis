close all;
clear all;
pathin = './';
pathout= './';
filein = [pathin,'init_tend_enkf'];
filein2 = [pathin,'wrfout_d01_2000-01-24_12:00:00']

%-------------------------
% General constants
pbuf=5  % cut out lateral boundary tendencies
avg_time=1 % in h
dt=180; %s
%dt = getnc(filein,'DT');
%-------------------------

VarName   = {'T' 'U' 'V'}
XLab      = {'K/h' 'm/(s*h)' 'm/(s*h)'}

np=0; % panel number
for nvar=1:numel(VarName);

if char(VarName(nvar))=='T'
  TendNames = {'RTHCUTEN_ACC' 'RTHBLTEN_ACC' 'RTHRATEN_ACC' 'H_DIABATIC_ACC' 'T_TEND_DYN_ACC' };
  LgNames1 ={ 'RTHCUTEN' 'RTHBLTEN' 'RTHRATEN' 'H\_DIABATIC' 't\_tend\_phys'};
  LgNames2 ={ 'T\_inc/dt' 't\_tend\_dyn' 't\_tend\_phys' 't\_tend\_tot'};
elseif char(VarName(nvar))=='U'
  TendNames = {'RUCUTEN_ACC' 'RUBLTEN_ACC' 'RU_TEND_DYN_ACC' };
  LgNames1 ={ 'RUCUTEN' 'RUBLTEN' 'u\_tend\_phys'}
  LgNames2 ={ 'U\_inc/dt' 'u\_tend\_dyn' 'u\_tend\_phys' 'u\_tend\_tot'};
elseif char(VarName(nvar))=='V'
  TendNames = {'RVCUTEN_ACC' 'RVBLTEN_ACC' 'RV_TEND_DYN_ACC' };
  LgNames1 ={ 'RVCUTEN' 'RVBLTEN' 'v\_tend\_phys'}
  LgNames2 ={ 'V\_inc/dt' 'v\_tend\_dyn' 'v\_tend\_phys' 'v\_tend\_tot'};
end


lineStyles1 ={ 'b-';...
               'g-' ; ...
               'm-';...
               'c-';...
               'r-' };


%-------------------------
% Read in tendency data from file 'init_tend_enkf'
%-------------------------
inum=numel(TendNames);
for i=1:inum
x = getnc(filein, char(TendNames(i)));
if i==inum;
if char(VarName(nvar))=='U'; x=(x(:,:,:,1:end-1)+x(:,:,:,2:1:end))/2;end
if char(VarName(nvar))=='V'; x=(x(:,:,1:end-1,:)+x(:,:,2:end,:))/2;end
end;
tend(i,:,:,:) = squeeze(x(avg_time+1,:,pbuf:end-pbuf+1,pbuf:end-pbuf+1));
numfields= avg_time*3600/dt; 
tendprof = mean(mean(tend,3),4)*3600/avg_time; % tendency profile in hours 
end
[ntend nlev nlat nlon]=size(tend);
P = [1:nlev];

%-------------------------
% Read in variable increment from wrfout files 
%-------------------------
Var = getnc(filein2,char(VarName(nvar)));
if char(VarName(nvar))=='U'; Var=Var(:,:,:,1:end-1);end
if char(VarName(nvar))=='V'; Var=Var(:,:,1:end-1,:);end
avg_timevar=3600*avg_time/dt;
Var1 =squeeze(Var(1,:,pbuf:end-pbuf+1,pbuf:end-pbuf+1)); Var2 =squeeze(Var(avg_timevar+1,:,pbuf:end-pbuf+1,pbuf:end-pbuf+1));
Var_inc=zeros(nlev,1);
Var_inc = mean(mean(Var2-Var1,2),3);
Var_inc=Var_inc/dt*3600/avg_time;

%-------------------------
% Compute and plot physcs' tendencies
%-------------------------
% Compute physical tendencies as sum over  
% radiation (RTHRATEN), cumulus (RTHCUTEN), boundary layer (RTHBLTEN) and micro-physics (H_DIABATIC);
%TendNames = {'RTHCUTEN_ACC' 'RTHRATEN_ACC' 'RTHBLTEN_ACC' 'H_DIABATIC_ACC'  'T_TEND_DYN_ACC' };

np=np+1;
subplot(3,2,np)
tend_phys=zeros(1,nlev);
hold on
for i=1:inum-1
  plot(tendprof(i,:),P,char(lineStyles1(i)))
  tend_phys=tend_phys+tendprof(i,:);
end
plot(tend_phys,P,'r--')
xlabel(char(XLab(nvar)))
ylabel('Model Level')
tl=line([0 0],[1 nlev]); set(tl,'Color','k')
axis tight
hl=legend(char(LgNames1),'Location','NorthEast'); 
title(['Physics Tendencies, ' VarName(nvar)])

%-------------------------
% Plot main budhget tendencies
%-------------------------
np=np+1;
subplot(3,2,np)

% plot profile
plot(Var_inc,P,'k');
hold on
plot(tendprof(inum,:),P,'b');
hold on
plot(tend_phys,P,'r--');
hold on
plot(tend_phys+tendprof(inum,:),P,'g--');
hold on
line([0 0],[1 nlev])
title(['Total Tendencies, ' VarName(nvar)])
axis tight
xlabel(char(XLab(nvar)))
hl=legend(char(LgNames2),'Location','NorthEast'); 

end % VarName nvar

orient tall 
wysiwyg
pnam =[pathout,'initial_tendencies'];
print('-dpng',[pnam '.png']);

