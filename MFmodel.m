% Recover from model parameters to ah and aw, calculate model mfh and mfw, save results

clear;
addpath('./src/');
starttime = [2021 1 1 0 0 0];  % epoch of start
endtime   = [2021 1 7 0 0 0];  % epoch of end
% path of parameter file
savetextdatadir = './data/';
% loading grid point information
griddata_5x5file = './data/gridpoint_coord_5x5.txt';
gridinfo_55 = importdata(griddata_5x5file); 
gridinfo_55 = gridinfo_55.data;
% geight and elevation angles
h_ell = [0:200:4000,4300:300:14000];
el    = [3,5,7,10,15,30,70];
% grid coordinates
lat_range = 87.5:-5:-87.5;
lon_range = 2.5:5:357.5;
[X,Y]=meshgrid(lat_range,lon_range);
% exponential fitting function
func_exp1 = @(a,x) a(1)*exp(a(2)*x);
func_exp2 = @(a,x) a(1)*exp(a(2)*x+a(3)*x.^2);
func_exp3 = @(a,x) a(1)*exp(a(2)*x+a(3)*x.^2+a(4)*x.^3);

% beginning of the epoch cycle
for loopmjd  = cal2mjd(starttime):1:cal2mjd(endtime)
    % time
    time = mjd2cal(loopmjd);
    mjd = loopmjd;
    % file path
    ymdfilename = [num2str(time(1),'%4d'),num2str(time(2),'%02d'),num2str(time(3),'%02d'),'00'];
    disp(['Start processing data at epoch ',ymdfilename]);
    load([savetextdatadir,ymdfilename,'\','paras.mat'])
    
    Poly2_mfh = nan(length(gridinfo_55)*length(el),length(h_ell)); Poly2_mfw = nan(length(gridinfo_55)*length(el),length(h_ell));
    Poly3_mfh = nan(length(gridinfo_55)*length(el),length(h_ell)); Poly3_mfw = nan(length(gridinfo_55)*length(el),length(h_ell));
    Exp1_mfh = nan(length(gridinfo_55)*length(el),length(h_ell));  Exp1_mfw = nan(length(gridinfo_55)*length(el),length(h_ell));
    Exp2_mfh = nan(length(gridinfo_55)*length(el),length(h_ell));  Exp2_mfw = nan(length(gridinfo_55)*length(el),length(h_ell));
    Exp3_mfh = nan(length(gridinfo_55)*length(el),length(h_ell));  Exp3_mfw = nan(length(gridinfo_55)*length(el),length(h_ell));
    
    % recovery from model parameters to ah and aw
    for pointID = 1:length(gridinfo_55)
        Poly2_ah       = polyval(paras.para_Poly2_ah(pointID,:),h_ell/1000)/1000;
        Poly2_aw       = polyval(paras.para_Poly2_aw(pointID,:),h_ell/1000)/1000;
        Poly3_ah       = polyval(paras.para_Poly3_ah(pointID,:),h_ell/1000)/1000;
        Poly3_aw       = polyval(paras.para_Poly3_aw(pointID,:),h_ell/1000)/1000;
        Exp1_ah        = func_exp1(paras.para_Exp1_ah(pointID,:),h_ell/1000)/1000;
        Exp1_aw        = func_exp1(paras.para_Exp1_aw(pointID,:),h_ell/1000)/1000;
        Exp2_ah        = func_exp2(paras.para_Exp2_ah(pointID,:),h_ell/1000)/1000;
        Exp2_aw        = func_exp2(paras.para_Exp2_aw(pointID,:),h_ell/1000)/1000;
        Exp3_ah        = func_exp3(paras.para_Exp3_ah(pointID,:),h_ell/1000)/1000;
        Exp3_aw        = func_exp3(paras.para_Exp3_aw(pointID,:),h_ell/1000)/1000;
        
        for k = 1:length(h_ell)
            for m = 1:length(el)
                [ Poly2_mfh(length(el)*(pointID-1)+m,k) , Poly2_mfw(length(el)*(pointID-1)+m,k) ] = vmf3 ( Poly2_ah(k) , Poly2_aw(k) , mjd , pi*gridinfo_55(pointID,1)/180 , pi*gridinfo_55(pointID,2)/180 , pi*(90-el(m))/180 );
                [ Poly3_mfh(length(el)*(pointID-1)+m,k) , Poly3_mfw(length(el)*(pointID-1)+m,k) ] = vmf3 ( Poly3_ah(k) , Poly3_aw(k) , mjd , pi*gridinfo_55(pointID,1)/180 , pi*gridinfo_55(pointID,2)/180 , pi*(90-el(m))/180 );
                [ Exp1_mfh(length(el)*(pointID-1)+m,k)  , Exp1_mfw(length(el)*(pointID-1)+m,k) ]  = vmf3 ( Exp1_ah(k)  , Exp1_aw(k)  , mjd , pi*gridinfo_55(pointID,1)/180 , pi*gridinfo_55(pointID,2)/180 , pi*(90-el(m))/180 );
                [ Exp2_mfh(length(el)*(pointID-1)+m,k)  , Exp2_mfw(length(el)*(pointID-1)+m,k) ]  = vmf3 ( Exp2_ah(k)  , Exp2_aw(k)  , mjd , pi*gridinfo_55(pointID,1)/180 , pi*gridinfo_55(pointID,2)/180 , pi*(90-el(m))/180 );
                [ Exp3_mfh(length(el)*(pointID-1)+m,k)  , Exp3_mfw(length(el)*(pointID-1)+m,k) ]  = vmf3 ( Exp3_ah(k)  , Exp3_aw(k)  , mjd , pi*gridinfo_55(pointID,1)/180 , pi*gridinfo_55(pointID,2)/180 , pi*(90-el(m))/180 );
            end
        end
        % raise invalid value
        Poly2_mfw(Poly2_mfw<0) = nan;
        Poly3_mfw(Poly3_mfw<0) = nan;
        Exp1_mfw(Exp1_mfw<0) = nan;
        Exp2_mfw(Exp2_mfw<0) = nan;
        Exp3_mfw(Exp3_mfw<0) = nan;
    end
    mfhmfw = struct('Exp1_mfh',Exp1_mfh,'Exp1_mfw',Exp1_mfw, ...
                    'Exp2_mfh',Exp2_mfh,'Exp2_mfw',Exp2_mfw, ...
                    'Exp3_mfh',Exp3_mfh,'Exp3_mfw',Exp3_mfw, ...
                    'Poly2_mfh',Poly2_mfh,'Poly2_mfw',Poly2_mfw, ...
                    'Poly3_mfh',Poly3_mfh,'Poly3_mfw',Poly3_mfw);
    save mfhmfw.mat mfhmfw;
    movefile('mfhmfw.mat',[savetextdatadir,ymdfilename]);
end

%% plot the results
% specify the epoch to display
ymdfilename = '2021010100';
% selected point to show
pointID = 1500;
pointID = 7*(pointID-1)+1;
load([savetextdatadir,ymdfilename,'\','mfhmfw.mat']);
% raise invalid value
index = sum([diff(mfhmfw.Poly2_mfw(pointID,:))<0; diff(mfhmfw.Poly3_mfw(pointID,:))<0; diff(mfhmfw.Exp1_mfw(pointID,:))<0; diff(mfhmfw.Exp2_mfw(pointID,:))<0; diff(mfhmfw.Exp3_mfw(pointID,:))<0],1) ~=0;
index = [0,index]; index = ~index;

% plot
figure(1)
subplot(1,2,1)
plot(mfhmfw.Poly2_mfh(pointID,:),h_ell/1000,'-','color','m','LineWidth',1); hold on;
plot(mfhmfw.Poly3_mfh(pointID,:),h_ell/1000,'-','Color','g','LineWidth',1); hold on;
plot(mfhmfw.Exp1_mfh(pointID,:),h_ell/1000,'-','Color','b','LineWidth',1); hold on;
plot(mfhmfw.Exp2_mfh(pointID,:),h_ell/1000,'-','Color','c','LineWidth',1); hold on;
plot(mfhmfw.Exp3_mfh(pointID,:),h_ell/1000,'-','Color','y','LineWidth',1); hold on;
xlabel('mfh');
ylabel('Height (km)');
grid on;
set(gca,'xminortick','on','yminortick','on');set(gca,'ticklength',[0.03 0.015]);
subplot(1,2,2)
plot(mfhmfw.Poly2_mfw(pointID,index),h_ell(index)/1000,'-','color','m','LineWidth',1); hold on;
plot(mfhmfw.Poly3_mfw(pointID,index),h_ell(index)/1000,'-','Color','g','LineWidth',1); hold on;
plot(mfhmfw.Exp1_mfw(pointID,index),h_ell(index)/1000,'-','Color','b','LineWidth',1); hold on;
plot(mfhmfw.Exp2_mfw(pointID,index),h_ell(index)/1000,'-','Color','c','LineWidth',1); hold on;
plot(mfhmfw.Exp3_mfw(pointID,index),h_ell(index)/1000,'-','Color','y','LineWidth',1); hold on;
xlabel('mfw');
ylabel('Height (km)');
grid on;
set(gca,'xminortick','on','yminortick','on');set(gca,'ticklength',[0.03 0.015]);

hl = legend('Poly2','Poly3','Exp1','Exp2','Exp3','Interpreter','none');
set(hl,'Box','off','Location','North','Orientation','horizon','NumColumns',5,'FontSize',10,'FontName','Arial','FontName','Arial','fontname','Arial');
set(hl,'Position',[0.285015090577103 0.951994111134258 0.389344266594433 0.0409836073390774],...
    'Orientation','horizontal',...
    'NumColumns',5);
