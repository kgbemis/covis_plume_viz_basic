function test_viz_par_func(matfilename,bathyfilename,boxb,setupvals)
% test_viz_par
%   combines COVIS imaging data and bathymetric data to visualize seafloor,
%   chimney and plume at Inferno
%
%   inputs
%       matfilename = COVIS imaging data in a .mat file (contains the structure
%   covis)
%       bathyfilename = bathymetry file
%       boxb
%       setupvals = specs for visualization
%           figno = specifies figure window number
%           subno = 
%           titlenote
%           alphatype
%           mycoltyp
%           legkey
%           ischim
%           bathycolor
%
%   assumes
%       bathy data file = covis_bathy_combine_rotated.mat
%       Inferno in box = [-20 -5 -5 10]
%
%   output = figure window with desired image
%
% based on test_viz_par_dullbathy.m but modified colors 
% kgb 09-25-19

% set box bounds
%boxb=[-20 0 -5 10];  % focus on Inferno
%boxb=[-40 20 -40 20]; % full box
%boxtag='inferno';
xboxmin=boxb(1);
xboxmax=boxb(2);
yboxmin=boxb(3);
yboxmax=boxb(4); 

% pull figure title information from matfilename
    fprintf('processing %s \n',matfilename)
    [~,rootname,~]=fileparts(matfilename);
    tempstrs = strsplit(rootname,{'-'});
    titlename=tempstrs{2};

% pull in setup for run
subno=setupvals.subno;
figno=setupvals.figno;
ischim=setupvals.ischim;
alphatype=setupvals.alphatype;
mycoltyp=setupvals.mycoltyp;
titlenote=setupvals.titlenote;
bathycolor=setupvals.bathycolor;
legkey=setupvals.legkey;
intensity_options=setupvals.intensity_options;

% get imaging data
load(matfilename) %#ok<LOAD>   % all COVIS data files contain ONLY the 
                               %    structre covis which always has the
                               %    same entries (well, almost always!)
    if ~exist('covis','var')
        covis=imaging;
    end
    xX=covis.grid.x;
    yY=covis.grid.y;
    zZ=covis.grid.z;
    % pull backscatter intensity data
    %   Ii used for plume 
    %   Ia used for chimney/mound
    switch intensity_options
        case 'Idfilt'
            Ii=covis.grid.Id_filt;
            Ia=covis.grid.Ia_filt;
        case 'Id'
            Ii=covis.grid.Id;
            Ia=covis.grid.Ia_filt;
        case 'Ia_filt'
            Ii=covis.grid.Ia_filt;
            Ia=covis.grid.Ia_filt;
        case 'Ia'
            Ii=covis.grid.Ia;
            Ia=covis.grid.Ia_filt;
    end
    dx=covis.grid.spacing.dx;
    [N,M,P]=size(xX);
    maxX=max(xX(:));
    mayY=max(yY(:));
    
% get bathy data
%bathy=load('../chimneys/chimneyaboveinfernoandpotentialmovementofcovis/covis_bathy_combine_rotated.mat');
%bathy=load('over_ex_grids/covis_bathy_survey_combine_2018_sensor.mat');
%bathy=load('bathy_grid_data/covis_bathy_survey_combine_2018_sensor.mat');
bathy=load(bathyfilename);
xb=bathy.covis.grid.x;
yb=bathy.covis.grid.y;
zb=bathy.covis.grid.v;

% get indicies for box bounds
    ix1n=M-round((maxX-(xboxmin))/dx);
        if ix1n<0,ix1n=1;fprintf('warning: box at data edge\n');end
    ix2n=M-round((maxX-(xboxmax))/dx);          
    iy1n=N-round((mayY-(yboxmin))/dx);
        if iy1n<0,iy1n=1;fprintf('warning: box at data edge\n');end
    iy2n=N-round((mayY-(yboxmax))/dx);

    fprintf(' indicies for box bounds \n')
    fprintf('x coor: %d %d \n',ix1n,ix2n)
    fprintf('y coor: %d %d \n',iy1n,iy2n)
    fprintf('z coor: uses full range\n')

% setup matricies for values wish to store    
newN=iy2n-iy1n+1;
newM=ix2n-ix1n+1;
newInten=zeros(newN,newM,P);
newIntenCHIM=zeros(newN,newM,P);
newX=zeros(newN,newM,P);
newY=zeros(newN,newM,P);
newZ=zeros(newN,newM,P);
mymaxes=zeros(P,2);
mymaxX=zeros(P,2);
mymaxY=zeros(P,2);
for i=1:P
    % extract level data
    levelInten=Ii(:,:,i);
    maxInten=max(levelInten(:));
    
    % extract box data
    boxInten=Ii(iy1n:iy2n,ix1n:ix2n,i);
    boxIntenCHIM=Ia(iy1n:iy2n,ix1n:ix2n,i);
    boxX=xX(iy1n:iy2n,ix1n:ix2n,i);
    boxY=yY(iy1n:iy2n,ix1n:ix2n,i);
    [maxboxInten,indmax]=max(boxInten(:));
    maxboxX=boxX(indmax);
    maxboxY=boxY(indmax);

    % store box data for viz and saving
    newInten(:,:,i)=boxInten;
    newIntenCHIM(:,:,i)=boxIntenCHIM;
    newX(:,:,i)=boxX;
    newY(:,:,i)=boxY;
    newZ(:,:,i)=zZ(iy1n:iy2n,ix1n:ix2n,i);
   
    % store max data for viz and saving
    mymaxes(i,:)=[maxInten maxboxInten];
    mymaxX(i,:)=maxboxX;
    mymaxY(i,:)=maxboxY;
end
        
% visualize plume
figure(figno)
subplot(subno(1),subno(2),subno(3))
%subplot(subno)
hold on
%maxIntenNew=max(newInten(:));
%isovalues=[0.001 0.01 0.05 0.1 0.5].*maxIntenNew;
% 0.000000001 = 1e-9 is below noise level
isovalues=[0.000001 0.00001 0.0001];
Nisos=length(isovalues);
% values I>0.001 are rock ... actually boundary might be slightly smaller
% values I<1e-7 seem to be ambient/noise
switch mycoltyp
    case 'parula'
        layercolors=parula(length(isovalues));
    case 'adjusted parula'
        layercolors=[112  89 219; ... 
                       8 166 161; ... 
                     148 148  10]./255; 
    case 'lilac'
        layercolors=[224 236 244; ...
                     158 188 218; ...
                     136 86 167]./255;
    case 'dark lilac'
        layercolors=[179 205 227; ...
                     140 150 198; ...
                     136  65 157]./255;
    case 'modified lilac'
        layercolors=[179 205 227; ...
                     140 150 198; ...
                     129  15 124]./255;
    case 'rose lilac'
        layercolors=[174 175 253; ...
                     169  87 254; ...
                     253   0 255]./255;
    case 'red-lilac-blue'
        layercolors=[126 112 191; ...
                     128   0 120; ...
                     130   0  13]./255;
    case 'picked lilac'
        layercolors=[ 77 153 204; ...
                     128  77 128; ...
                     153   5  13]./255;        
    case 'orange'
        layercolors=[253 204 138; ...
                     252 141  89; ...
                     215  48  31]./255;
    case 'rose'
        layercolors=[215 181 216; ...
                     223 101 176; ...
                     206  18  86]./255;
    case 'flipud hsv'
        layercolors=flipud(hsv(length(isovalues)));
    case 'std'
        layercolors=[0 0 1; ...
                     0.5 0 0.5; ...
                     1 0 0];
    case 'upsidedown'
        layercolors=[1 0 0; ...
                     0.5 0 0.5; ...
                     0 0 1];end
% pick alpha variations
switch alphatype
    case 'constant'
        layeralphas=0.10*ones(size(isovalues));
    case 'simple'
        layeralphas=0.05*(1:length(isovalues));
    case 'fancy'
        layeralphas=0.10+0.05*((1:length(isovalues))-1);
    case 'std'
        %layeralphas=0.20*ones(size(isovalues));
        layeralphas=0.20*(1:length(isovalues));
    case 'med'
        layeralphas=0.10*(1:length(isovalues));
    case 'faint'
        layeralphas=0.02*(1:length(isovalues));
end
% loop over isovalues to create multilayered object
for j=1:Nisos
    p = patch(isosurface(newX,newY,newZ,newInten,isovalues(j)));
    isonormals(newX,newY,newZ,newInten,p)
    p.FaceColor = layercolors(j,:);
    p.EdgeColor = 'none';
    p.FaceAlpha = layeralphas(j);
    p.SpecularStrength = 0.5;
end
daspect([1,1,1])
view(115,20); axis tight
camlight 
lighting gouraud
grid on
% add chimney
if ischim
    % original isovalue = 0.002
pchim = patch(isosurface(newX,newY,newZ,newIntenCHIM,0.003));
%pchim = patch(isosurface(newX,newY,newZ,newIntenCHIM,0.0001));
    isonormals(newX,newY,newZ,newIntenCHIM,pchim)
    %pchim.FaceColor = [0.7500    0.8750    0.4000];
    %pchim.FaceColor = [0.8    0.8    0.8];
    switch bathycolor
        case 'midpinksflipped'
            temp=pink(16);
            pchim.FaceColor=temp(6,:);
        case 'summer'
            temp=summer(16);
            pchim.FaceColor=temp(16,:);
        case 'ltgray'
            % bone and gray give similar effect but bone is bluer
            %temp=bone(16);
            temp=gray(16);
            pchim.FaceColor=temp(16,:);
        case 'cbrewer'
            temp=cbrewer('seq','YlGn',9);
            pchim.FaceColor=temp(9,:);
    end
    pchim.EdgeColor = 'none';
    pchim.FaceAlpha = 1;
    pchim.DiffuseStrength=0.5;
    pchim.BackFaceLighting='lit';
    pchim.SpecularColorReflectance=0;
    pchim.SpecularExponent=20;
    pchim.SpecularStrength=0.1;
end

% add bathy
pbathy=surf(xb,yb,zb);
    pbathy.FaceColor='interp';
    pbathy.EdgeColor='none';
    pbathy.DiffuseStrength=0.9;
    pbathy.BackFaceLighting='lit';
    pbathy.SpecularColorReflectance=0;
    pbathy.SpecularExponent=20;
    %pbathy.SpecularStrength=0.3;
    pbathy.SpecularStrength=0.9;
    switch bathycolor
        case 'midpinksflipped'
            temp=pink(16);
            mymap=flipud(temp(6:13,:));
        case 'summer'
            mymap=summer(16);
        case 'ltgray'
            % bone and gray give similar effect but bone is bluer
            %temp=bone(16);
            temp=gray(16);
            mymap=temp(12:16,:);
        case 'cbrewer'
            mymap=cbrewer('seq','YlGn',9);
    end
    colormap(mymap)
hold on
contour3(xb,yb,zb,20,'LineColor',[0.4 0.4 0.4])

% add COVIS
plot3([0 0],[0 0],[0 4],'y','LineWidth',3)
%xlim([min(xX(:)) 5]);
xlim([xboxmin xboxmax]);
%ylim([min(yY(:)) max(yY(:))]);
ylim([yboxmin yboxmax]);
% plot box bounds
%plot3([xboxmin xboxmax xboxmax xboxmin xboxmin],...
%        [yboxmin yboxmin yboxmax yboxmax yboxmin],...
%        [0.1 0.1 0.1 0.1 0.1],':')
hold off
if legkey==1
    %hmm3=cell(length(isovalues));
    hmm3=cell(Nisos,1);
    for i=1:Nisos, hmm3(i)={num2str(isovalues(i))}; end
    if ischim
        hmm3(i+1)={'chim (0.002)'}; 
        hmm3(i+2)={'bathy'}; hmm3(i+3)={''}; hmm3(i+4)={'covis'};
    else
    	hmm3(i+1)={'bathy'}; hmm3(i+2)={''};  hmm3(i+3)={'covis'};
    end
    legend(hmm3,'Location','northeast')
end
if sum(subno(1:2))>3
    labelfontsize=5;
else
    labelfontsize=10;
end
xlabel('East of COVIS (m)','FontSize',labelfontsize)
ylabel('North of COVIS (m)','FontSize',labelfontsize)
zlabel('Height above COVIS base (m)','FontSize',labelfontsize)
title([titlenote ':' datestr(datenum(titlename,'yyyymmddTHHMMSS'))],'FontSize',labelfontsize)