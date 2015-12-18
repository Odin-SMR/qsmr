% Q2_GET_ATM   Extracts atmospheric data from handled databases
%
%   The output structure has the following fields
%      P   : pressure grid (set to be equal to O.P_GRID)
%      T   : temperature profile
%      Z   : geomtrical altitude profile
%      VMR : gas species profiles
%    
%   The data can be compiled from different sources. The handled options are
%      O.T_SOURCE           : WebApi, CIRA 86 and MSIS90
%      O.ABS_SPECIES.SOURCE : WebApi and Bdx
%
% FORMAT   ATM = q2_get_atm( LOG, O )
%
% OUT  ATM   Structure holding atmospheric data, see above.
% IN   LOG   Log data of a single scan.
%      O     O struture for frequency mode. 

% 2015-05-22   Created by Patrick Eriksson.


function ATM = q2_get_atm( LOG, O )
%
if length(LOG) > 1
  error( 'This function handles only single logdata entries.' );
end


% Set MJD, lat and lon (even if not used if all data are from WebApi)
%
[mjd,lat,lon] = q2_calc_scan_pos( LOG );


% Pressure grid to use
%
ATM.P = O.P_GRID;

  
% T and Z field
%
switch upper( O.T_SOURCE )
  
 case 'WebApi'
  %
  PTZ = get_scan_aux_data( LOG.URL_ptz );
  %
  X = interpp( PTZ.P*100, [ PTZ.T, PTZ.Z ], ATM.P );
  %
  ATM.T = X(:,1); 
  ATM.Z = X(:,2); 
    
 case 'CIRA86'
  %
  [ATM.Z,ATM.T] = p2z_cira86( ATM.P, lat, mjd2doy(mjd) );
    
 case 'MSIS90'
  %
  arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
  if isnan( arts_xmldata_path ) 
    error( 'You need to set ARTS_XMLDATA_PATH to obtain MSIS90.' );
  end
  % Temperature
  M = gf_artsxml( fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                            'MSIS90', 'climatology', 'msis90.t.xml' ), ...
                    'Temperature', 't_field' );
  G = atmdata_regrid( M, { ATM.P, lat, lon, mjd } );
  ATM.T = G.DATA;
  % Altitudes
  M = gf_artsxml( fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                            'MSIS90', 'climatology', 'msis90.z.xml' ), ...
                  'Altitude', 'z_field' );
  G = atmdata_regrid( M, { ATM.P, lat, lon, mjd } );
  ATM.Z = G.DATA;
  
 %case 'DONALETTY'
 %  [ATM.T,ATM.Z] = q2_find_donaletty(ATM.P,L1B.ORBIT,L1B.SCAN);  
   
 %case 'ERA'
 % ATM = find_ERA( ATM.P, L1B )
       
 otherwise
  error( '%s is an unknown option for O.T_SOURCE.', O.T_SOURCE );
end


% VMR field
%
ATM.VMR = zeros( length(O.ABS_SPECIES), length(ATM.P), 1, 1 );
%
for i = 1 : length( O.ABS_SPECIES )

  species = arts_tgs2species( O.ABS_SPECIES(i).TAG{1} );
  
  switch O.ABS_SPECIES(i).SOURCE
    
   case 'WebApi'
    %
    VMR = get_scan_aux_data( LOG.(sprintf('URL_apriori_%s',species)) );
    ATM.VMR(i,:,1,1) = interpp( VMR.pressure, VMR.vmr, ATM.P );    
    
   case 'Bdx'
    %
    load( fullfile( O.FOLDER_BDX ,sprintf('apriori_%s.mat',species)) );
    G = atmdata_regrid( Bdx, { ATM.P, lat, lon, mjd } );
    ATM.VMR(i,:,1,1) = G.DATA;

   otherwise
    error( '%s is an unknown option for O.ABS_SPECIES.SOURCE.', ...
                                                    O.ABS_SPECIES(i).SOURCE );
  end
end
