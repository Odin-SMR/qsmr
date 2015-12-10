% Q2_GET_ATM   Extracts atmospheric data 
%
%    To be written ...
%
% Off-line options are:
%   O.T_SOURCE           : CIRA 86 and MSIS90
%   O.ABS_SPECIES.SOURCE : Bdx

% 2015-05-22   Created by Patrick Eriksson.


function ATM = q2_get_atm( R, O, L1B )
  
if R.ONLINE
  error( 'On-line mode not yet handled' );
  
else
  
  % Hard-coded paths
  %
  bdxfolder = O.FOLDER_BDX;
  
  % Will STW or mjd/lat/lon be input?
  %
  mjd = L1B.MJD;
  lat = L1B.LAT;
  lon = L1B.LON;
  
  
  % T and Z field
  %
  switch upper( O.T_SOURCE )
    
   case 'CIRA86'
    %
    [ATM.Z,ATM.T] = p2z_cira86( O.P_GRID, lat, mjd2doy(mjd) );
      
   case 'MSIS90'
    arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
    if isnan( arts_xmldata_path ) 
      error( 'You need to set ARTS_XMLDATA_PATH to run this example.' );
    end
    % Temperature
    M = gf_artsxml( fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                              'MSIS90', 'climatology', 'msis90.t.xml' ), ...
                    'Temperature', 't_field' );
    G = atmdata_regrid( M, { O.P_GRID, lat, lon, mjd } );
    ATM.T = G.DATA;
    % Altitudes
    M = gf_artsxml( fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                              'MSIS90', 'climatology', 'msis90.z.xml' ), ...
                    'Altitude', 'z_field' );
    G = atmdata_regrid( M, { O.P_GRID, lat, lon, mjd } );
    ATM.Z = G.DATA;
    
    
   case 'DONALETTY'
     [ATM.T,ATM.Z]=q2_find_donaletty(O.P_GRID,L1B.ORBIT,L1B.SCAN);  
     
   case 'ERA'
       ATM=find_ERA(O.P_GRID,L1B)
     
      
   otherwise
    error( '%s is an unknown option for O.T_SOURCE.', O.T_SOURCE );
  end
  
  
  % VMR field
  %
  ATM.VMR = zeros( length(O.ABS_SPECIES), length(O.P_GRID), 1, 1 );
  %
  for i = 1 : length( O.ABS_SPECIES )

    switch O.ABS_SPECIES(i).SOURCE
    
     case 'Bdx'
      %
      species = arts_tgs2species( O.ABS_SPECIES(i).TAG{1} );
      load( fullfile(bdxfolder,sprintf('apriori_%s.mat',species)) );
      G = atmdata_regrid( Bdx, { O.P_GRID, lat, lon, mjd } );
      ATM.VMR(i,:,1,1) = G.DATA;

     otherwise
      error( '%s is an unknown option for O.ABS_SPECIES.SOURCE.', ...
                                                      O.ABS_SPECIES(i).SOURCE );
    end
  end
end