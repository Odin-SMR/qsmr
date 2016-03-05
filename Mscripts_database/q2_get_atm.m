% Q2_GET_ATM   Extracts atmospheric data from handled databases
%
%   The output structure has the following fields
%      P   : pressure grid (set to be equal to Q.P_GRID)
%      T   : temperature profile
%      Z   : geomtrical altitude profile
%      VMR : gas species profiles
%    
%   The data can be compiled from different sources. The handled options are
%      Q.T.SOURCE           : WebApi, CIRA 86 and MSIS90
%      Q.ABS_SPECIES.SOURCE : WebApi and Bdx
%
% FORMAT   ATM = q2_get_atm( LOG, Q )
%
% OUT  ATM   Structure holding atmospheric data, see above.
% IN   LOG   Log data of a single scan.
%      Q     Q structure for frequency mode. 

% 2015-05-22   Created by Patrick Eriksson.


function ATM = q2_get_atm( LOG, Q )
%
if length(LOG) > 1
  error( 'This function handles only single logdata entries.' );
end


% Set MJD, lat and lon (not used if all data are from WebApi)
%
[mjd,lat,lon] = q2_calc_scan_pos( LOG );


% Pressure grid to use
%
ATM.P = Q.P_GRID;

  
% T and Z field
%
switch Q.T.SOURCE
  
 case 'WebApi'
  %
  PTZ = get_scan_aux_data( LOG.URLS.URL_ptz );
  %
  X = interpp( PTZ.Pressure, [ PTZ.Temperature, PTZ.Altitude ], ATM.P );
  %
  ATM.T     = X(:,1); 
  ATM.Z     = X(:,2); 
  ATM.LAT1D = PTZ.Latitude;
  ATM.LON1D = PTZ.Longitude;

 case 'MSIS90'
  %
  ATM.LAT1D = lat;
  ATM.LON1D = lon;
  %
  % Temperature
  M = gf_artsxml( fullfile( Q.FOLDER_ARTSXMLDATA, 'planets', 'Earth', ...
                            'MSIS90', 'climatology', 'msis90.t.xml' ), ...
                            'Temperature', 't_field' );
  if ATM.P(end) < M.GRID1(end)
    error( 'Your pressure grid extends above the coverage of MSIS90 data at hand.' );
  end
  G = atmdata_regrid( M, { ATM.P, lat, lon, mjd } );
  ATM.T = G.DATA;
  % Altitudes
  M = gf_artsxml( fullfile( Q.FOLDER_ARTSXMLDATA, 'planets', 'Earth', ...
                            'MSIS90', 'climatology', 'msis90.z.xml' ), ...
                            'Altitude', 'z_field' );
  G = atmdata_regrid( M, { ATM.P, lat, lon, mjd } );
  ATM.Z = G.DATA;
 
  
 %case 'DONALETTY'
 %  [ATM.T,ATM.Z] = q2_find_donaletty(ATM.P,L1B.ORBIT,L1B.SCAN);  
  
   
 %case 'ERA'
 % ATM = find_ERA( ATM.P, L1B )
   
   
 otherwise
  error( '%s is an unknown option for Q.T.SOURCE.', Q.T.SOURCE );
end


% VMR field
%
ATM.VMR = zeros( length(Q.ABS_SPECIES), length(ATM.P), 1, 1 );
%
for i = 1 : length( Q.ABS_SPECIES )

  species = arts_tgs2species( Q.ABS_SPECIES(i).TAG{1} );
  
  switch Q.ABS_SPECIES(i).SOURCE
    
   case 'WebApi'
    %
    VMR = get_scan_aux_data( LOG.URLS.(sprintf('URL_apriori_%s',species)) );
    ATM.VMR(i,:,1,1) = interpp( VMR.Pressure, VMR.VMR, ATM.P );    
    
   case 'Bdx'
    %
    load( fullfile( Q.FOLDER_BDX ,sprintf('apriori_%s.mat',species)) );
    G = atmdata_regrid( Bdx, { ATM.P, lat, lon, mjd } );
    ATM.VMR(i,:,1,1) = G.DATA;

   otherwise
    error( '%s is an unknown option for Q.ABS_SPECIES.SOURCE.', ...
                                                    Q.ABS_SPECIES(i).SOURCE );
  end
end
