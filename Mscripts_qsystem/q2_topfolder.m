% Q2_TOPFOLDER  Returns path to Qsmr's top folder
%
% FORMAT   topfolder = q2_topfolder
%        
% OUT   topfolder   Full path to top folder of qsmr

% 2015-05-21   Patrick Eriksson.

function topfolder = q2_topfolder

topfolder = folder_of_fun( mfilename, 1 );

