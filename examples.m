% example calls for COVIS visualization

% notes on inputs
%   bounds specified by boxb
%      [-40 20 -40 20] encapsulates all COVIS data collected at ASHES
%      [-20 0 -5 10] focuses on Inferno
%   plume colormaps incorportated
%       parula
%       adjusted parula
%       lilac
%       dark lilac
%       modified lilac
%       rose lilac
%       red-lilac-blue
%       picked lilac
%       orange
%       rose
%       flipud hsv
%       std
%       upsidedown
% transparency schemes incorportated
%       constant
%       simple
%       fancy
%       std
%       med
%       faint
% colormaps for bathymetry incorporated
%       midpinksflipped
%       summer
%       ltgray
%       cbrewer


% set up inputs for test_viz_par_func.m
matfilename='../covis_data/COVIS-20230101T000002-imaging1.mat';
bathyfilename='../bathy_grid_data/covis_bathy_2019b.mat';
boxb=[-40 20 -40 20]; % for max range
setupvals.figno=1;
setupvals.subno=[1 1 1];
setupvals.titlenote='testing - max range';
setupvals.alphatype='std';
setupvals.mycoltyp='dark lilac';
setupvals.legkey=1;
setupvals.ischim=1;
setupvals.bathycolor='midpinksflipped';
setupvals.intensity_options='Idfilt';

% run test_viz_par_func.m for max range
test_viz_par_func(matfilename,bathyfilename,boxb,setupvals)

% run  test_viz_par_func.m to focus on Inferno
boxb=[-20 0 -5 10]; % to focus on Inferno
setupvals.figno=2;
test_viz_par_func(matfilename,bathyfilename,boxb,setupvals)

% run  test_viz_par_func.m without chimney visualized
boxb=[-20 0 -5 10]; % to focus on Inferno
setupvals.figno=3;
setupvals.ischim=0;
test_viz_par_func(matfilename,bathyfilename,boxb,setupvals)
