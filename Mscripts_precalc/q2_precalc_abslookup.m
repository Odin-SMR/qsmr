% Q2_PRECALC_ABSLOOKUP
%
% FORMAT   q2_precalc_abslookup(O,P,R,precs)
%        
% IN    O       An array of O structures
%       P       A P structure
%       R       A R structure
%       precs   A vector of precision limits.
% OPT   do_cubic Flag to use f_grid assuming cubic interpolation. Default is false.

% 2015-05-25   Created by Patrick Eriksson.

function q2_precalc_abslookup(O,P,R,precs,varargin)
%
[do_cubic] = optargs( varargin, { false } );


%- Check folder and file names
%
for i = 1 : length( O )
  for j = 1 : length( precs )
    
    [outfolder,outfile] = create_folderfile( O(i), precs(j), do_cubic );
    
    if ~exist( outfolder, 'dir' )
      error( 'The following folder does not exist: %s', outfolder );
    end
    if exist( outfile )
      error( 'The following file does already exist: %s', outfile );
    end
    
  end
end


%- Loop all fmodess
%
for i = 1 : length( O )

  for j = 1 : length( precs )
  
    A = do_1fmode( O(i), P, R, precs(j), do_cubic );

    [outfolder,outfile] = create_folderfile( O(i), precs(j), do_cubic );    
    
    xmlStore( outfile, A, 'GasAbsLookup', 'binary' );

    %- Create a simple README
    %
    fid = fopen( fullfile( outfolder, 'README' ), 'w' );
    fprintf( fid, 'The absorption lookup table files in this folder were\n' );
    fprintf( fid, sprintf( 'created by the function *%s*.', mfilename ) );
    fclose( fid );  
  end
end
return
%--------------------------------------------------------------------------


function A = do_1fmode( O, P, R, prec, do_cubic )

  % Table is calculated for atmospheric state behind first reference spectrum
  [L1B,LOG] = homemade_l1b( O, 30e3, P.REFSPECTRA_LAT(1), ...
                              P.REFSPECTRA_LON(1), P.REFSPECTRA_MJD(1) );
  ATM =  q2_get_atm( LOG, O );

  C.ABSORPTION      = 'CalcTable';
  C.CONTINUA_FILE   = O.CONTINUA_FILE;
  C.HITRAN_PATH     = P.HITRAN_PATH;
  C.HITRAN_FMIN     = P.HITRAN_FMIN;
  C.HITRAN_FMAX     = P.HITRAN_FMAX;
  C.R_EARTH         = constants( 'EARTH_RADIUS' );
  C.SPECTRO_FOLDER  = P.SPECTRO_FOLDER;
  if isfield( P, 'SPECTRO_FOLDER2' )
    C.SPECTRO_FOLDER2  = P.SPECTRO_FOLDER2;
  end
  C.SPECIES         = arts_tgs_cnvrt( O.ABS_SPECIES );

  if do_cubic
    lorc = 'cubic';
  else
    lorc = 'linear';
  end
  %    
  fgridfile = fullfile( O.FOLDER_FGRID, sprintf( '%dmK_%s', prec*1e3, lorc ), ...
                        sprintf( 'fgrid_fmode%02d.xml', O.FMODE ) );
  f_grid    = xmlLoad( fgridfile );
  %
  xmlStore( fullfile( R.WORK_FOLDER, 'f_grid.xml' ), f_grid, ...
                                                        'Vector', 'binary' );
  xmlStore( fullfile( R.WORK_FOLDER, 'p_grid.xml' ), O.P_GRID, ...
                                                        'Vector', 'binary' );
  %
  xmlStore( fullfile( R.WORK_FOLDER, 'abs_t.xml' ), ATM.T, ...
                                                         'Vector', 'binary' );
  xmlStore( fullfile( R.WORK_FOLDER, 'abs_t_pert.xml' ), P.ABS_T_PERT, ...
                                                         'Vector', 'binary' );
  xmlStore( fullfile( R.WORK_FOLDER, 'abs_vmrs.xml' ), ATM.VMR, ...
                                                         'Matrix', 'binary' );
  %
  cfile  = q2_artscfile_full( C, R.WORK_FOLDER );
  %
  status = arts( cfile );
  A      = xmlLoad( fullfile( R.WORK_FOLDER, 'abs_lookup.xml' ) );
  
return
%--------------------------------------------------------------------------

  
  
function [outfolder,outfile] = create_folderfile( O, precs, do_cubic );

  outfolder = fullfile( O.FOLDER_ABSLOOKUP, sprintf( '%dmK', precs*1e3) );

  if do_cubic
    outfolder = [ outfolder, '_cubic' ];
  else
    outfolder = [ outfolder, '_linear' ];
  end

  outfile = fullfile( outfolder, sprintf( 'abslookup_fmode%02d.xml', ...
                                                               O.FMODE ) );
return
%--------------------------------------------------------------------------
