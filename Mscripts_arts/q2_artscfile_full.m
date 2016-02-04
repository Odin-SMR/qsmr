% Q2_ARTSCFILE_FULL   Generates full ARTS control files 
%
%   The function creates a control file that either generates an absorption
%   lookup table or spectra. 
%
%   Most input variables are simply read from files. These files shall be
%   placed in *workfolder* and be named as WSV.xml, e.g. f_grid.xml for
%   f_grid. 
%
%   Otherwise, the content is controlled by a structure C, having the
%   fields (with some sample settings/comments):
%     ABSORPTION             LoadTable
%     ABS_LOOKUP_TABLE       full path to a file
%     ABS_P_INTERP_ORDER 
%     ABS_T_INTERP_ORDER 
%     CONTINUA_FILE          full path to a file
%     HITRAN_PATH            full path to a file
%     HITRAN_FMIN            reading starts at this frequency
%     HITRAN_FMAX            reading stops at this frequency
%     PPATH_LMAX
%     PPATH_LRAYTRACE
%     R_EARTH                Planet radius to apply
%     SPECIES                '"ClO',"O3"'
%     SPECTRO_FOLDER         Folder holding hand-picked spectroscopic data
%     SPECTRO_FOLDER2        Secondary folder holding hand-picked
%                            spectroscopic data. Only used if defined.
%
%   The options for C.ABSORPTION are 'CalcTable', 'LoadTable' and 'OnTheFly'.
%   Not all fields are used simultaneously. The required set depends on
%   C.ABSORPTION. 
%
% FORMAT cfile = q2_artscfile_full(C,workfolder[,cfilename])
%
% OUT   cfile        Full path to control file generated.
% IN    C            C structure, as described above.
%       workfolder   Folder where control file shall be placed
% OPT   cfilename    Name of actual file. Default is 'cfile.arts'. 

% 2015-05-29   Created by Patrick Eriksson.

function cfile = q2_artscfile_full(C,workfolder,cfilename)
%  
if nargin < 3, cfilename = 'cfile.arts'; end


%- Open cfile for writing
%
cfile = fullfile( workfolder, cfilename );
%
fid = fileopen( cfile, 'w' );
%
cu = onCleanup( @()fileclose( fid ) );


%- The diferent main options

% Calculation of absorption lookup table
if strcmp( C.ABSORPTION, 'CalcTable' )
  cfile_start( fid, C );
  cfile_abs( fid, C, workfolder );
  cfile_end( fid );

% Calculation of spectra
else
  cfile_start( fid, C );
  cfile_abs( fid, C, workfolder );
  cfile_atm( fid, C, workfolder );
  cfile_sensor_and_rt( fid, C, workfolder );
  cfile_jacobian( fid, C, workfolder );  
  cfile_ycalc( fid, C, workfolder );
  cfile_end( fid );
end


 
 

return
%----------------------------------------------------------------------------

function cfile_start( fid, C )
  fprintf( fid, '#\n# This control file has been generated by *%s*: %s\n#\n', ...
                                                    mfilename, datestr(now,31) );
  fprintf( fid, 'Arts2{\n' );
  %
  fprintf( fid, '\n#\n# Fixed settings:\n#\n' );
  fprintf( fid, 'verbosityInit\n' );
  fprintf( fid, 'output_file_formatSetBinary\n' );
  fprintf( fid, '#\n' );
  fprintf( fid, 'Tensor3SetConstant( wind_u_field, 0, 0, 0, 0.0 )\n' );
  fprintf( fid, 'Tensor3SetConstant( wind_v_field, 0, 0, 0, 0.0 )\n' );
  fprintf( fid, 'Tensor3SetConstant( wind_w_field, 0, 0, 0, 0.0 )\n' );
  fprintf( fid, 'Tensor3SetConstant( mag_u_field, 0, 0, 0, 0.0 )\n' );
  fprintf( fid, 'Tensor3SetConstant( mag_v_field, 0, 0, 0, 0.0 )\n' );
  fprintf( fid, 'Tensor3SetConstant( mag_w_field, 0, 0, 0, 0.0 )\n' );  
  fprintf( fid, 'MatrixSet( transmitter_pos, [] )\n' );
  fprintf( fid, 'NumericSet( rte_alonglos_v, 0 )\n' );
  fprintf( fid, 'scat_speciesSet( scat_species, [] )\n' );
  fprintf( fid, 'NumericSet( lm_p_lim, 0 )\n' );
  fprintf( fid, 'nlteOff\n' );
  fprintf( fid, 'partition_functionsInitFromBuiltin\n' );
  fprintf( fid, '#\n' );
  fprintf( fid, 'AgendaSet( geo_pos_agenda ){\n' );
  fprintf( fid, '  Ignore( ppath )\n' );
  fprintf( fid, '  VectorSet( geo_pos, [] )\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'AgendaSet( refr_index_air_agenda ){\n' );
  fprintf( fid, '  Ignore( f_grid )\n' );
  fprintf( fid, '  NumericSet( refr_index_air, 1.0 )\n' );
  fprintf( fid, '  NumericSet( refr_index_air_group, 1.0 )\n' );
  fprintf( fid, '  refr_index_airMicrowavesEarth\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'AgendaSet( surface_rtprop_agenda ){\n' );
  fprintf( fid, '  Ignore( rtp_los )\n' );
  fprintf( fid, '  InterpAtmFieldToPosition( out=surface_skin_t, field=t_field )\n' );
  fprintf( fid, '  surfaceBlackbody\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'AgendaSet( iy_surface_agenda ){\n' );
  fprintf( fid, '  iySurfaceRtpropAgenda\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'AgendaSet( iy_space_agenda ){\n' );
  fprintf( fid, '  Ignore( rtp_pos )\n' );
  fprintf( fid, '  Ignore( rtp_los )\n' );
  fprintf( fid, '  MatrixCBR( iy, stokes_dim, f_grid )\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'AgendaSet( iy_main_agenda ){\n' );
  fprintf( fid, '  iyEmissionStandard\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'AgendaSet( ppath_agenda ){\n' );
  fprintf( fid, '  Ignore( rte_pos2 )\n' );
  fprintf( fid, '  ppathStepByStep\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'AgendaSet( ppath_step_agenda ){\n' );
  fprintf( fid, '    ppath_stepRefractionBasic\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, '#\n' );
  fprintf( fid, 'NumericSet( molarmass_dry_air, 28.966 )\n' );
  fprintf( fid, 'AgendaSet( g0_agenda ){\n' );
  fprintf( fid, '   Ignore( lon )\n' );
  fprintf( fid, '   g0Earth\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'VectorSet( refellipsoid, [ %d, 0 ] )\n', C.R_EARTH );
  fprintf( fid, 'MatrixSet( z_surface, [ 1e3 ] )\n' );
  fprintf( fid, '#\n' );
  fprintf( fid, 'AtmosphereSet1D\n' );
  fprintf( fid, 'IndexSet( stokes_dim, 1 )\n' );
  fprintf( fid, 'cloudboxOff\n' );
  fprintf( fid, 'StringSet( iy_unit, "RJBT" )\n' );
return
%----------------------------------------------------------------------------


function cfile_abs( fid, C, workfolder )
  %
  fprintf( fid, '\n\n#\n# Absorption:\n#\n' );
  %
  fprintf( fid, 'abs_speciesSet( species = [%s] )\n', C.SPECIES );
  %
  if strcmp( C.ABSORPTION, 'CalcTable' )
    %
    fprintf( fid, 'abs_speciesSet( abs_species=abs_nls, species=[] )\n' );
    fprintf( fid, 'ReadXML( abs_vmrs, "%s" )\n', ...
                                      fullfile( workfolder, 'abs_vmrs.xml' ) );
    fprintf( fid, 'ReadXML( abs_t, "%s" )\n', ...
                                         fullfile( workfolder, 'abs_t.xml' ) );
    fprintf( fid, 'ReadXML( abs_t_pert, "%s" )\n', ...
                                    fullfile( workfolder, 'abs_t_pert.xml' ) );
    fprintf( fid, 'VectorSet( abs_nls_pert, [] )\n' );
    %
    cfile_abscalc_basics( fid, C, workfolder );
    %
    fprintf( fid, 'Copy( abs_p, p_grid )\n' );
    %
    fprintf( fid, 'abs_lookupCalc\n' );
    fprintf( fid, 'WriteXML( in=abs_lookup, filename="%s" )\n', ...
                                    fullfile( workfolder, 'abs_lookup.xml' ) );
  
  elseif strcmp( C.ABSORPTION, 'LoadTable' )
    %
    fprintf( fid, 'ReadXML( abs_lookup, "%s" )\n', C.ABS_LOOKUP_TABLE );
    fprintf( fid, 'f_gridFromGasAbsLookup\n' );
    fprintf( fid, 'ReadXML( p_grid, "%s" )\n', ...
                                          fullfile( workfolder, 'p_grid.xml' ) );
    fprintf( fid, 'IndexSet( abs_p_interp_order, %d )\n', C.ABS_P_INTERP_ORDER );
    fprintf( fid, 'IndexSet( abs_t_interp_order, %d )\n', C.ABS_T_INTERP_ORDER );
    fprintf( fid, 'IndexSet( abs_nls_interp_order, 0 )\n' );
    fprintf( fid, 'abs_lookupAdapt\n' );
    %
    fprintf( fid, 'AgendaSet( propmat_clearsky_agenda ){\n' );
    fprintf( fid, '  Ignore(rtp_mag)\n' );
    fprintf( fid, '  Ignore(rtp_los)\n' );
    fprintf( fid, '  Ignore(rtp_temperature_nlte)\n' );
    fprintf( fid, '  propmat_clearskyInit\n' );
    fprintf( fid, '  propmat_clearskyAddFromLookup\n' );
    fprintf( fid, '}\n' );
    fprintf( fid, 'propmat_clearsky_agenda_checkedCalc\n' );
      
  elseif strcmp( C.ABSORPTION, 'OnTheFly' )
    %
    cfile_abscalc_basics( fid, C, workfolder );
    %
    fprintf( fid, 'AgendaSet( propmat_clearsky_agenda ){\n' );
    fprintf( fid, '  Ignore(rtp_mag)\n' );
    fprintf( fid, '  Ignore(rtp_los)\n' );
    fprintf( fid, '  propmat_clearskyInit\n' );
    fprintf( fid, '  propmat_clearskyAddOnTheFly\n' );
    fprintf( fid, '}\n' );
    fprintf( fid, 'propmat_clearsky_agenda_checkedCalc\n' );

  else
    error( 'Unknow option for C.ABSORPTION' );
  end
  %
  fprintf( fid, 'IndexSet( abs_f_interp_order, 0 )\n' );
  %
return
%----------------------------------------------------------------------------


function cfile_abscalc_basics( fid, C, workfolder )
  %
  fprintf( fid, 'ReadXML( f_grid, "%s" )\n', ...
                                        fullfile( workfolder, 'f_grid.xml' ) );
  fprintf( fid, 'ReadXML( p_grid, "%s" )\n', ...
                                        fullfile( workfolder, 'p_grid.xml' ) );
  %
  fprintf( fid, 'AgendaSet( abs_xsec_agenda ){\n' );
  fprintf( fid, '  abs_xsec_per_speciesInit\n' );
  fprintf( fid, '  abs_xsec_per_speciesAddLines\n' );
  fprintf( fid, '  abs_xsec_per_speciesAddConts\n' );
  fprintf( fid, '}\n' );
  fprintf( fid, 'abs_xsec_agenda_checkedCalc\n' );
  %
  fprintf( fid, 'abs_linesReadFromHitran( abs_lines, "%s", %.5e, %.5e )\n', ...
           C.HITRAN_PATH, C.HITRAN_FMIN, C.HITRAN_FMAX );
  fprintf( fid, 'abs_linesArtscat5FromArtscat34\n' );
  %
  % Add hand-picked data:
  fprintf( fid, 'ArrayOfLineRecordCreate(handpicked)\n' );
  for z = 1:2
    if z == 1
      fname = 'SPECTRO_FOLDER';
    else
      fname = 'SPECTRO_FOLDER2';
    end
    if isfield( C, fname )
      spectrofiles = whichfiles( '*.xml', C.(fname) );
    else
      spectrofiles = [];
    end        
    if ~isempty(spectrofiles)
      for i = 1 : length(spectrofiles)
        fprintf( fid, 'ReadXML( handpicked, "%s" )\n', spectrofiles{i} );
        fprintf( fid, ...
                'abs_linesReplaceWithLines(replacement_lines=handpicked)\n' );
      end
    end
  end
  %
  fprintf( fid, 'abs_lines_per_speciesCreateFromLines\n' );
  fprintf( fid, [ 'abs_lineshapeDefine( shape="Voigt_Kuntz6", ' ...
                  'forefactor="VVW", cutoff=-1 )\n' ] );    
  %
  fprintf( fid, 'isotopologue_ratiosInitFromBuiltin\n' );
  fprintf( fid, 'INCLUDE "%s"\n', C.CONTINUA_FILE );  
return
%----------------------------------------------------------------------------


function cfile_atm( fid, C, workfolder )
  %
  fprintf( fid, '\n\n#\n# Atmospheric fields:\n#\n' );    
  fprintf( fid, 'ReadXML( t_field, "%s" )\n', ...
                                    fullfile( workfolder, 't_field.xml' ) );
  fprintf( fid, 'ReadXML( z_field, "%s" )\n', ...
                                    fullfile( workfolder, 'z_field.xml' ) );
  fprintf( fid, 'ReadXML( vmr_field, "%s" )\n', ...
                                    fullfile( workfolder, 'vmr_field.xml' ) );
  %
  fprintf( fid, 'atmfields_checkedCalc( negative_vmr_ok = 1,\n' );
  fprintf( fid, '   bad_partition_functions_ok = 1)\n' );
  %
  fprintf( fid, 'ReadXML( lat_true, "%s" )\n', ...
                                    fullfile( workfolder, 'lat_true.xml' ) );
  fprintf( fid, 'ReadXML( lon_true, "%s" )\n', ...
                                    fullfile( workfolder, 'lon_true.xml' ) );    
  fprintf( fid, 'z_fieldFromHSE( p_hse = 500e2, z_hse_accuracy = 1 )' );
  %
  fprintf( fid, 'atmgeom_checkedCalc\n' );
  fprintf( fid, 'cloudbox_checkedCalc\n' );
return
%----------------------------------------------------------------------------

  
function cfile_jacobian( fid, C, workfolder )
  %
  if C.JACOBIAN_DO
    fprintf( fid, 'INCLUDE "%s"\n', C.JACOBIAN_FILE );  
  else
     fprintf( fid, 'jacobianOff\n' );  
  end
return
%----------------------------------------------------------------------------


function cfile_sensor_and_rt( fid, C, workfolder );
  %
  fprintf( fid, '\n\n#\n# Sensor + radiative transfer:\n#\n' );    
  %
  fprintf( fid, 'NumericSet( ppath_lmax, %d )\n', C.PPATH_LMAX );
  fprintf( fid, 'NumericSet( ppath_lraytrace, %d )\n', C.PPATH_LRAYTRACE );
  %
  fprintf( fid, 'ArrayOfStringSet( iy_aux_vars, [] )\n' );
  %
  fprintf( fid, 'ReadXML( sensor_pos, "%s" )\n', ...
                       fullfile( workfolder, sprintf('sensor_pos.xml' ) ) );
  fprintf( fid, 'ReadXML( sensor_los, "%s" )\n', ...
                       fullfile( workfolder, sprintf('sensor_los.xml' ) ) );
  %
  fprintf( fid, 'sensorOff\n' );
  fprintf( fid, 'IndexSet( sensor_checked, 1 )\n' );
return
%----------------------------------------------------------------------------


function cfile_ycalc( fid, C, workfolder );
  %
  fprintf( fid, 'yCalc\n' );
  %
  fprintf( fid, 'WriteXML( in=y, filename="%s" )\n', ...
                                            fullfile( workfolder, 'y.xml' ) );
  %fprintf( fid, 'WriteXML( in=y_aux, filename="%s" )\n', ...
  %                                      fullfile( workfolder, 'y_aux.xml' ) );
  %
  if C.JACOBIAN_DO
    fprintf( fid, 'WriteXML( in=jacobian, filename="%s" )\n', ...
                                     fullfile( workfolder, 'jacobian.xml' ) );
    fprintf( fid, 'WriteXML( in=z_field, filename="%s" )\n', ...
                                     fullfile( workfolder, 'z_field.xml' ) );
    fprintf( fid, 'WriteXML( in=t_field, filename="%s" )\n', ...
                                     fullfile( workfolder, 't_field.xml' ) );
  end
return
%----------------------------------------------------------------------------


function cfile_end(fid)
  fprintf( fid, '\n}\n' );
return

  
