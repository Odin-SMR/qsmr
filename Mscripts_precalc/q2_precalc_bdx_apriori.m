% Q2_PRECALC_CLIMATOLOGY   Compiles the Bordeaux species a priori data
%
%    The Bordeaux climatology is imported and compiled to an atmdata structure
%    for each species.
%
%    The input data shall follow the format used in Qsmr1. The path to these
%    data are taken from P.BDX_INFOLDER.
%
%    Final files are stored in Q.FOLDER_BDX
%
% FORMAT   q2_precalc_bdx_apriori(Q,P)
%        
% IN    Q   Q structure
%       P   P structure

% 2015-05-20   Created by Patrick Eriksson.

function q2_precalc_bdx_apriori(Q,P)
  
  
%- Where to save files
%
outfolder = Q.FOLDER_BDX;


%- Data describing the input database
%
species = { 'BrO','Cl2O2','HCN','N2','OClO','C2H2','ClO','HCOOH','N2O',...	
            'OH','C2H6','ClONO2','HCl','NH3','SF6','CH3CN','ClOOCl','HF',...
            'NO','SO2','CH3Cl','H2CO','HI','NO2','CH4','H2O','HNO3','O2',...
            'CO','H2O2','HO2','O3','CO2','H2S','HOBr','OBrO','COF2','HBr',...
            'HOCl','OCS' };
%
latitudes = [ -85 : 10 : 85 ]';
%
months    = { 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', ...
              'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC' };
%
np = 41;


%- Output format
%
pgrid    = q2_pgrid( [], [], true );
%
Bdx           = atmdata_empty( 4 );
%  
Bdx.SOURCE    = 'Qsmr Bordeaux a priori database';
%
Bdx.DATA_NAME = 'Volume mixing ratio';
Bdx.DATA_UNIT = '1';
%
Bdx.GRID1     = pgrid;
Bdx.GRID2     = latitudes;
Bdx.GRID3     = NaN;
%
dm           = daysinmonth( 2001, 1:12 );
Bdx.GRID4      = [0 round(dm/2)+cumsum([0 dm(1:end-1)]) 367]';
Bdx.GRID4_NAME = 'DOY';
Bdx.GRID4_UNIT = 'DOY';


for s = 1:length(species)
  
  Bdx.NAME = sprintf( 'Climatology of %s', species{s} );
  Bdx.DATA = repmat( NaN, [length(pgrid),length(latitudes),1,14] );
  
  for m = 1:12
    for l = 1:length(latitudes)
    
      infile = fullfile( P.BDX_DATA_INFOLDER, months{m}, sprintf('%.2f',latitudes(l)),...
                         'DAY', sprintf('atm.%s.aa', species{s}) );
      
      A = read_arts1file( infile, 'Matrix' );
      
      Bdx.DATA(:,l,1,m+1) = interp1( [10;log10(A(:,1));-99], ...
                                   [A(1,2);A(:,2);A(end,2)], log10(pgrid) );
    end
  end
  
  % Put in DOY 0 and 367
  Bdx.DATA(:,:,:,1)  = ( Bdx.DATA(:,:,:,2) + ...
                             Bdx.DATA(:,:,:,13) ) / 2; 
  Bdx.DATA(:,:,:,14) = Bdx.DATA(:,:,:,1);
  
  save( fullfile(outfolder,sprintf('apriori_%s.mat',species{s})), ...
                                                            'Bdx', '-v6' );
end


%- Create a simple README
%
fid = fopen( fullfile( outfolder, 'README' ), 'w' );
fprintf( fid, 'The a priori files in this folder were created\n' );
fprintf( fid, sprintf( 'by the function *%s*.', mfilename ) );
fclose( fid );
