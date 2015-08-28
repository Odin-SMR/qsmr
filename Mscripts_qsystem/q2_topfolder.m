% Q2_TOPFOLDER  Returns path top Qsmr's top folder
%
% FORMAT   topfolder = q2_topfolder
%        
% OUT   topfolder   Full path to the Qsmr top folder

% 2015-05-21   Patrick Eriksson.

function topfolder = q2_topfolder

topfolder = folder_of_fun( mfilename, 1 );

