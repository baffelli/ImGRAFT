%% Batura Glacier, Karakoram
%
% CIAS is another free feature tracking software. This is a GUI written in 
% IDL by K��b & Vollmer. Here we use ImGRAFT to track one of the CIAS example
% data sets using orthorectified Landsat 7 images from Batura. 
% Here's how you might track it in ImGRAFT. 
% 
% Note: this example needs the mapping toolbox in order to read the
% geo-tiffs.

datafolder=downloadDemoData('cias');

%%load data
%
% Here we use imread instead of geotiffread, to avoid having a dependency
% between ImGRAFT and the mapping toolbox. But if you have the mapping toolbox
% then I recommend loading the landsat scenes using geoimread.m from here:
% http://www.mathworks.com/matlabcentral/fileexchange/46904-geoimread

A=imread(fullfile(datafolder,'batura_2001.tif')); 
B=imread(fullfile(datafolder,'batura_2002.tif')); %normally you would use geotiffread
x=(0:size(A,2)-1)*15+451357.50; %if you have mapping toolbox then you would use pixcenters here. 
y=(0:size(A,1)-1)*15+4060432.50;
deltax=15;%m/pixel


%make regular grid of points to track:
[pu,pv]=meshgrid(1:20:size(A,2),1:20:size(A,1));

%... but restricted to points inside this region of interest polygon
roi=[387 452;831 543;1126 899;1343 1006;1657 1022;2188 1330;...
     2437 1220;2564 1359;2483 1473;2188 1489;1693 1320;1563 1181; ...
     1061 1168;663 718;456 686;25 877;28 627;407 465];
 
mask=inpolygon(pu,pv,roi(:,1),roi(:,2));
punan=pu; 
punan(~mask)=nan; %inserting nans at some locations will tell template match to skip these locations

[du,dv,C,Cnoise,pu,pv]=templatematch(A,B,punan,pv,'showprogress',{'2001' '2002'});
close all

%visualize the results
%turn the intensity image into an RGB image
%so that it does not interfere with colorbar:
image(repmat(A,[1 1 3]),'CDataMapping','scaled') %the cdatamapping is a workaround for a bug in R2014+
axis equal off tight ij
hold on
signal2noise=C./Cnoise;
keep=(signal2noise>2.3)&(C>.65);
V=(du+dv*1i)*deltax; %m/yr
Vn=abs(V);
alphawarp(pu,pv,Vn,.2+keep*.5)
quiver(pu(keep),pv(keep),real(V(keep))./Vn(keep),imag(V(keep))./Vn(keep),0.2,'k') %arrows show direction. 
caxis([0 200])
colorbar('southoutside');
