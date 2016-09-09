=======================================
Qsmr: definition of settings
=======================================


:Authors: 

   Patrick Eriksson <patrick.eriksson@chalmers.se> 

:Version: 
        
   0.2

:Date:

   2016-09-09

:Summary: 

   This document contains a brief description of the settings considered by the
   Qsmr retrieval system. These settings are packed into a structure denoted
   as Q. This structure must contain an exact set of fields; all fields must be
   present and no additional ones are allowed. The defined fields are described
   below, in alphabetical order.

   Qsmr operates also with two other structures. For the various
   pre-calculations a structure denoted as P is used. The fields of P are
   defined and are shortly described in the file p_std.m. The structure R works
   as repository for internal variables and data. That is, no fields of R is
   set by the user.

   Most fields of Q are of simple types such scalar value, vector or string,
   but some fields are structures. This more complex type is only used for
   retrieval quantities, in order to allow simple communication with some
   functions copied from Qarts.

   All fields listed affect the inversions, either in the pre-calculation phase
   or when doing the actual inversion. The settings are applied by various
   functions and if you are using individual functions of Qsmr you need to
   figure out what settings that have an effect or not. For example, the fields
   TB_SCALING_FAC and TB_CONTRAST_FAC are not applied directly when loading the
   data, but are applied on the L1B data by a special function.
   
~~~~~

ABSLOOKUP_OPTION
   A string. This string gives the name of the sub-folder containing the
   absorption look-up table to use.

ABS_P_INTERP_ORDER
   An integer. The polynomial order to apply for pressure interpolation of the
   absorption look-up table. See further the ARTS workspace variable with the
   same name.

ABS_SPECIES
   An array of structures. Each array element provides settings for a gas
   species. The fields of the structure are as follows. TAG: Definition of the
   species following the ARTS format, e.g. O3-\*-501e9-503e9. SOURCE: A string
   describing from where temperature a priori shall be taken. Handled options
   are 'WebApi' and 'Bdx'. RETRIEVE: A boolean, flagging if the species shall
   be retrieved or not. All fields below are ignored if RETRIEVE is false. L2: A
   boolean, flagging if the species is part of the L2 data of the frequency mode.
   GRID: Retrieval grid to use for the species. UNC_REL and UNC_ABS: Minimum
   relative and absolute uncertainty (1 std dev), respectively. The absolute
   and relative values are compared using the a priori profile and the largest
   of the two is selected (but not exceeding 1e3 in relative value). CORRLEN:
   Correlation length, in meter, to use when creating Sx. LOG_ON: Set to true
   to impose a positive constrain for the species.

   Note that when creating L2 data the outermost points of GRID are removed. 

ABS_T_INTERP_ORDER
   An integer. The polynomial order to apply for temperature interpolation of the
   absorption look-up table. See further the ARTS workspace variable with the
   same name.

ARTS
   A string. Name or path of the ARTS executable to use.

BACKEND_NR
   An integer. Index of expected backend. Index coding described in L1B ATBD.

BASELINE
   A structure. Definition of baseline off-set retrieval. The fields of the
   structure are as follows. RETRIEVE: A boolean, flagging if baseline off-set
   shall be retrieved or not. UNC: A priori uncertainty (1 std dev). MODEL:
   A string. If set to 'common' a single off-set is retrieved for each
   spectrum. If set to 'module' an off-set for each active AC module is
   retrieved, i.e. up to four off-set per spectrum are derived. If set to
   'adaptive' then all modules contributing with more than 125 channels are
   grouped and a common off-set for these modules is retrieved, while separate
   off-sets are retrieved for remaining modules (<= 125 channels).

DZA_GRID_EDGES
   A vector. Complements DZA_MAX_IN_CORE in the specification of the angular
   grid used for pencil beam calculations. The vector specifies the values to
   add outside the lower and upper boresight direction. These are relative angles
   (in degrees), where 0 shall not be included.

DZA_MAX_IN_CORE
   A scalar value. Determines the maximum spacing (in degrees) of the angular
   grid used for pencil beam calculations. This value sets the spacing between
   the lower and upper boresight direction.

FOLDER_ABSLOOKUP
   A string. Full path to folder containing the different versions of absorption
   look-up tables. That is, this folder is expected to contain folders. The
   exact folder specification is a result of this field and ABSLOOKUP_OPTION.

FOLDER_ANTENNA
   A string. Full path to folder containing antenna pattern response files.

FOLDER_BACKEND
   A string. Full path to folder containing backend channel response files.

FOLDER_BDX
   A string. Full path to folder containing files of the Bordeaux a priori
   database. Files having .mat format are expected.   

FOLDER_FGRID
   A string. Full path to folder containing frequency grid files.   

FOLDER_MSIS90
   A string. Full path to folder holding the MSIS90 climatology (version taken
   from arts-xml-data). Only needed of temperature data taken from MSIS90,
   which is the case for some pre-calculations.

FOLDER_WORK
   A string. Full path to a folder where temporary files and/or folders can 
   be placed. If this field is set to '/tmp', a temporary folder is created and
   all files are placed in this folder, and the folder is removed when the
   calculations are done. Otherwise, temporary files are placed directly in the 
   specified folder, and these are left when the calculations are done. This
   option is useful for debugging, but note that just a single Qsmr process can
   use a folder for debugging. If several Qsmr processes are given the same debugging
   folder, files will be overwritten and the calculations will crash or be incorrect.

FREQMODE
   An integer. The frequency mode. See L1B ATBD for definition of existing
   frequency modes.

FREQUENCY 
   A structure. Definition of frequency off-set retrieval. The fields of the
   structure are as follows. RETRIEVE: A boolean, flagging if frequency off-set
   shall be retrieved or not. UNC: A priori uncertainty (1 std dev).

FRONTEND_NR
   An integer. Index of expected frontend. Index coding described in L1B ATBD.

F_RANGES
   A matrix, having two columns. This matrix specifies the frequency ranges to
   include in the retrieval, where the first and second column give the lower
   and upper frequency limit, respectively. Each row specifies a new frequency
   range to include.

F_GRID_NFILL
   An integer. If set to > 0, the sensor response matrix will include a cubic
   frequency interpolation of the spectra, with F_GRID_NFILL points added
   between existing grid points. See further the ARTS workspace method 
   sensor_responseFillFgrid. If set to 0, no such interpolation is made.

F_LO_NOMINAL
   A scalar value. Nominal value of the LO frequency.

GA_FACTOR_NOT_OK
   A scalar value. The factor with which the Marquardt-Levenberg factor is
   increased when not a lower cost value is obtained. This starts a new
   sub-iteration. This value must be > 1.

GA_FACTOR_OK
   A scalar value. The factor with which the Marquardt-Levenberg factor is
   decreased after a lower cost values has been reached. This value must be > 1.

GA_MAX          
   A scalar value. Maximum value for gamma factor for the Marquardt-Levenberg
   method. The inversion is halted and flagged as unsuccessful if this value is
   reached. This value must be > 0.

GA_START
   A scalar value. Start value for gamma factor for the Marquardt-Levenberg
   method. See the L2 ATBD for a definition of the gamma factor. This value must
   be >= 0.

INVEMODE
   A string. A short string naming the inversion set-up used.

LO_COMMON
   A boolean. If true, the initial value of LO frequencies are set to be
   constant over the scan. This value is set following LO_ZREF. If false, the 
   L1B value for each altitude is used.

LO_ZREF
   A scalar value. Reference altitude for LO frequency. When performing
   frequency cropping, frequencies are taken from the spectra with the closest
   altitude. Further, if LO_COMMON is set to true, the LO frequency is taken
   from the L1B data of the spectrum closest to this altitude.

MIN_N_FREQS
   A scalar value. The required number of frequencies (i.e. channels) of spectra
   to start an inversion. This number refers to the number of spectra after frequency
   cropping and quality filtering.

MIN_N_SPECTRA
   A scalar value. The required number of spectra of a scan to start an
   inversion. This number refers to the number of spectra after altitude
   cropping and quality filtering.

NOISE_CORRMODEL
  A string. Model of correlations inside Se. Only correlation between adjacent
  channels of each spectrum is modelled. The options are as follows. 'none':
  this generates a pure diagonal Se. 'empi': Uses empirically derived values
  making Se a five-diagonal matrix. 'expo': Exponentially decreasing
  correlation, approximating the empirically derived values.

POINTING
   A structure. Definition of pointing off-set retrieval. The fields of the
   structure are as follows. RETRIEVE: A boolean, flagging if pointing off-set
   shall be retrieved or not. UNC: A priori uncertainty (1 std dev).

PPATH_LMAX
   A scalar value. The maximum distance between points of the propagation path.
   See further the ARTS workspace variable with the same name.

PPATH_LRAYTRACE 
   A scalar value. The length to apply for ray tracing to consider the effect
   of refraction. See further the ARTS workspace variable with the same name.

P_GRID
   A vector. The pressure grid to be used. See further the ARTS workspace
   variable with the same name. Note that this setting is also used when
   pre-calculating absorption lookup tables.

SIDEBAND_LEAKAGE
   A scalar. Relative contribution of the sideband. So far the sideband leakage
   is assumed to be flat over each frequency band.

STOP_DX
   OEM stop criterion. The iteration is halted when the change in x 
   is < stop_dx. Eq. 5.29 in the book by Rodgers is followed, but a
   normalisation with the length of x is applied. This means that STOP_DX
   should in general be in the order of 0.01 (and not change with the
   length of the state vector).

REFRACTION_DO
   A boolean. Determines if refraction is considered or not by the forward
   model. Set to true to include refraction.

T
   A structure. Definition of atmospheric temperature profile. The fields of
   the structure are as follows. SOURCE: A string describing from where
   temperature a priori shall be taken. Handled options are 'WebApi' and
   'MSIS90'. RETRIEVE: A boolean, flagging if temperature shall be retrieved or
   not. All fields below are ignored if RETRIEVE is false. L2: A boolean,
   flagging if temperature is part of L2 data of the frequency mode. GRID:
   Retrieval grid to use for temperature. UNC: A vector of length 5, with a 
   priori uncertainty (1 std dev)  at 100, 10, 1, 0.1 and 0.01 hPa (roughly 
   16, 32, 48, 64 and 80 km). CORRLEN: Correlation length, in meter, to use 
   when creating Sx.

TB_CONTRAST_FAC
   A scalar value. This factor modifies the contrast of each spectrum part. 
   If this factor is denoted as c, the scaling is:
   Tb_new = c * ( Tb -Tb_min ) + Tb_min,
   where Tb_min as an estimate of the noise-free minimum value of each
   spectrum part. This scaling is applied after TB_SCALING_FAC. This contrast
   scaling is applied on each AC module separately. That is, the complete
   spectrum is divided into four individual parts when performing this scaling. 
   To leave the data unchanged, set this field to [] or 1. 

TB_SCALING_FAC
   A scalar value. The L1B brightness temperature data are scaled with this
   factor. If this factor is denoted as c, the scaling is Tb_new = c * Tb.
   For example setting this field to 1.005 will convert an original  Tb-value 
   of 200 K to 201 K. To leave the data unchanged, set this field to [] or 1. 

ZTAN_LIMIT_BOT
   A vector of length 4. The lower limit for tangent altitudes to include in
   the inversion. That is, this setting determines the lower limit when
   cropping the scan range. The four values give the tangent altitude limit at
   0, +-30, +-60 and +-90 degrees in latitude. That is, the tangent altitude
   mask is assumed to be symmetric around the equator.  

ZTAN_LIMIT_TOP
   A scalar value. The upper limit for tangent altitudes to include in the
   inversion. That is, this setting determines the upper limit when cropping
   the scan range.

ZTAN_MIN_RANGE 
   A vector of length two. This field specifies the minimum altitude coverage of a
   scan to start an inversion. The order between lower and upper limit is free.
   The scan must have at least one tangent altude below and above the given
   limits. This check is done after applying ZTAN_LIMIT_BOT/TOP.
