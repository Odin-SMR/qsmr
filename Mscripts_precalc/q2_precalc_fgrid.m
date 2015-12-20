% Q2_PRECALC_FGRID   Frequency grid pre-calculation by a simple optimisation
%
%    The function pre-calculates frequency grids for all combinations of
%    frequency modes and selected precision limits. This is done by a simple
%    "optimisation" algorithm. Reference spectra are calculated on a fine grid
%    for a number of atmospheric scenarios. The optimised grid is found by
%    starting with the end points plus two randomly selected points inside the
%    range of the fine grid. A linear or cubic interpolation is performed back
%    to the fine grid and the frequency grid point where the maximum deviation
%    is found is added to the optimised grid. This procedure is repeated until
%    the deviation is smaller than the precision limit. This is repeated 100
%    times and the shortest grid is selected.
% 
%    For splitted modes, the procedure is applied on each part separately. The
%    same procedure is applied for the image band, but with a weaker precision
%    demand. The complete procedure is repeated 100 tim
%
%    Some critical settings here are
%      O.ABS_SPECIES
%      O.P_GRID
%      O.F_BACKEND_NOMINAL
%      O.F_LO_NOMINAL
%      P.FGRID_TEST_DF
%      P.FGRID_EDGE_MARGIN
%
%    Atmospheric data are hard-coded to be taken from the local version of the
%    Bdx database (O.ABS_SPECIES.SOURCE = 'Bdx') and MSIS90 (O.T_SOURCE =
%    'MSIS90').
%
%    The set of test simulations are mainly defined by P. Some details, such
%    as orbit altitude, are hard-coded.
%
%    Call the function as with O set to o_std(q2_fmodes) to perform
%    pre-calculations for all frequency modes defined.
%
%    Final files are stored in a subfolder of O.FOLDER_FGRID
%
% FORMAT   q2_precalc_fgrid(O,P,R,precs)
%        
% IN    O        An array of O structures
%       P        A P structure
%       R        A R structure
%       precs    Vector of precision limits [K]. 
% OPT   do_cubic Flag to active cubic interpolation. Default is false.

% 2015-05-25   Created by Patrick Eriksson.

function q2_precalc_fgrid(O,P,R,precs,varargin)
%
[do_cubic] = optargs( varargin, { false } );


%- Hard-coded O settings
% 
O.T_SOURCE             = 'MSIS90';
[O.ABS_SPECIES.SOURCE] = deal( 'Bdx' ); 


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


%- Loop all fmodes
%
for i = 1 : length( O )

  f_opt = do_1fmode( O(i), P, R, precs, do_cubic );

  for j = 1 : length( precs )

    [outfolder,outfile] = create_folderfile( O(i), precs(j), do_cubic );

    xmlStore( outfile, f_opt{j}, 'Vector', 'binary' );
    
    %- Create a simple README
    %
    fid = fopen( fullfile( outfolder, 'README' ), 'w' );
    fprintf( fid, 'The frequency grid files in this folder were created\n' );
    fprintf( fid, sprintf( 'by the function *%s*.', mfilename ) );
    fclose( fid );
    
  end
end

return
%--------------------------------------------------------------------------



function f_opt = do_1fmode( O, P, R, precs, do_cubic );
  %
  for j = 1 : length( precs )
    f_opt{j} = [];
  end
  %
  bp = [ 0;
         find( diff(vec2row(O.F_BACKEND_NOMINAL)) > 2*P.FGRID_EDGE_MARGIN );
         length(O.F_BACKEND_NOMINAL) ];
  %
  for i = 1 : length(bp)-1
    % Part of main band
    frange = O.F_BACKEND_NOMINAL( [ bp(i)+1 bp(i+1) ] ) + ...
             P.FGRID_EDGE_MARGIN * [-1 1];
    fpart  = do_1range( O, P, R, frange, precs, do_cubic );
    for j = 1 : length( precs )
      f_opt{j} = [ f_opt{j}; fpart{j} ];
    end
    % Corresponding part in side band
    frange = sort( 2*O.F_LO_NOMINAL - frange );
    fpart  = do_1range( O, P, R, frange, 20*precs, do_cubic );
    for j = 1 : length( precs )
      f_opt{j} = [ f_opt{j}; fpart{j} ];
    end
  end
  %
  for j = 1 : length( precs )
    f_opt{j} = sort( f_opt{j} );
  end
  %
return
%--------------------------------------------------------------------------



function f_opt = do_1range( O, P, R, frange, precs, do_cubic );

  % Local settings:
  %
  L.F_EXTRA  = 5e9;    % Includes lines inside this distance to range edges
  L.Z_PLAT   = 600e3;  % Assumed platform altitude

  % Create cfile and needed variables
  %
  C.ABSORPTION      = 'OnTheFly';
  C.CONTINUA_FILE   = O.CONTINUA_FILE;
  C.HITRAN_PATH     = P.HITRAN_PATH;
  C.HITRAN_FMIN     = P.HITRAN_FMIN;
  C.HITRAN_FMAX     = P.HITRAN_FMAX;
  C.PPATH_LMAX      = O.PPATH_LMAX;
  C.PPATH_LRAYTRACE = O.PPATH_LRAYTRACE;
  C.R_EARTH         = constants( 'EARTH_RADIUS' );
  C.SENSOR_ON       = false;
  C.SPECIES         = arts_tgs_cnvrt( O.ABS_SPECIES );
  C.SPECTRO_FOLDER  = P.SPECTRO_FOLDER;
  if isfield( P, 'SPECTRO_FOLDER2' )
    C.SPECTRO_FOLDER2  = P.SPECTRO_FOLDER2;
  end
  %
  f_fine = [ frange(1) : P.FGRID_TEST_DF : frange(2)+P.FGRID_TEST_DF/2 ]';
  %
  xmlStore( fullfile( R.WORK_FOLDER, 'f_grid.xml' ), f_fine, ...
                                                        'Vector', 'binary' );
  xmlStore( fullfile( R.WORK_FOLDER, 'p_grid.xml' ), O.P_GRID, ...
                                                        'Vector', 'binary' );
  %
  cfile  = q2_artscfile_full( C, R.WORK_FOLDER );
  %
  Y = [];
  %
  for i = 1 : length( P.REFSPECTRA_LAT )
    %
    [L1B,LOG] = homemade_l1b( O, P.REFSPECTRA_ZTAN, P.REFSPECTRA_LAT(i), ...
                              P.REFSPECTRA_LON(i), P.REFSPECTRA_MJD(i) );
    %
    ATM =  q2_get_atm( LOG, O );
    %
    xmlStore( fullfile( R.WORK_FOLDER, 't_field.xml' ), ATM.T, ...
                                                        'Tensor3', 'binary' );
    xmlStore( fullfile( R.WORK_FOLDER, 'z_field.xml' ), ATM.Z, ...
                                                        'Tensor3', 'binary' );
    xmlStore( fullfile( R.WORK_FOLDER, 'vmr_field.xml' ), ATM.VMR, ...
                                                        'Tensor4', 'binary' );
    %
    za = vec2col( geomztan2za( constants('EARTH_RADIUS'), L.Z_PLAT, ...
                                                        P.REFSPECTRA_ZTAN ) );
    %
    xmlStore( fullfile( R.WORK_FOLDER, 'sensor_pos.xml' ), ...
                           repmat( L.Z_PLAT, size(za) ), 'Matrix', 'binary' );
    xmlStore( fullfile( R.WORK_FOLDER, 'sensor_los.xml' ), za, ...
                                                         'Matrix', 'binary' );
    %
    status = arts( cfile );
    y      = xmlLoad( fullfile( R.WORK_FOLDER, 'y.xml' ) );
    y      = reshape( y, length(f_fine), length(za) );
    Y      = [ Y, y ];
  end

  for j = 1 : length( precs )
    [f_opt{j},maxdev] = f_opt_1band( f_fine, Y, precs(j), do_cubic );
  end
  
  %j=2;
  %Y_opt = interp1( f_fine, Y, f_opt{j} );
  %ind = [ 1 3 5 ];
  %plot( f_fine/1e9, Y(:,ind), f_opt{j}/1e9, Y_opt(:,ind), '*--' )
return
%--------------------------------------------------------------------------




function [f_opt,maxdev] = f_opt_1band( f_fine, Y, tb_lim, do_cubic )

  nf    = length( f_fine );
  f_opt = zeros( nf+1, 1 ); 
  
  for t = 1:100
     in_or_out      = isnan( f_fine );
     in_or_out(1)   = true;
     in_or_out(end) = true;
     
     in_or_out( ceil(length(f_fine)*rand(2)) ) = true;
     
     maxdev = Inf;

     while maxdev >= tb_lim
       %Y_opt = interp1( f_fine, Y, f_fine(in_or_out) );
       if do_cubic
         Yt = interp1( f_fine(in_or_out), Y(in_or_out,:,:), f_fine, 'pchip' );
       else
         Yt = interp1( f_fine(in_or_out), Y(in_or_out,:,:), f_fine );
       end
       
       [maxdev,ihit]   = max( max( abs( Yt - Y ), [], 2 ) );
       
       in_or_out(ihit) = true;
     end 
  
    if sum(in_or_out) < length(f_opt)
      f_opt = f_fine( in_or_out );
    end
  end
  
return
%--------------------------------------------------------------------------


function [outfolder,outfile] = create_folderfile( O, precs, do_cubic );

  if do_cubic
    lorc = 'cubic';
  else
    lorc = 'linear';
  end
    
  outfolder = fullfile( O.FOLDER_FGRID, sprintf( '%dmK_%s', precs*1e3, lorc ) );

  outfile = fullfile( outfolder, sprintf( 'fgrid_fmode%02d.xml', O.FMODE ) );
return
%--------------------------------------------------------------------------
