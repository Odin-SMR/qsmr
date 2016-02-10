=======================================
Qsmr: definition of settings
=======================================


:Authors: 

   Patrick Eriksson <patrick.eriksson@chalmers.se> 

:Version: 
        
   0.1 

:Date:

   2016-XX-XX

:Summary: 

   This document contains a brief description of the inversion settings
   considered by the Qsmr system. These settings are packed into a structure
   denoted as Q. This structure must contain an exact set of fields; all fields
   must be present and no additional ones are allowed. The defined fields are
   described below, in alphabetical order.

   The Qsmr settings operates also with three other structures. For the various
   pre-calculations a structure denoted as P is used. The fields of P are
   defined and are shortly described in the file p_std.m. The structure R works
   as repository for internal variables and data. That is, no fields of R is
   set by the user.

   Most fields of Q are of simple types such scalar value, vector or string,
   but some fields are structures. This more complex type is only used for
   retrieval quantities, in order to follow  the Qpack system.

~~~~~

ABSLOOKUP_OPTION
   A string. This string gives the name of the folder containing the absorption
   look-up tables to use.

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
   be retrieved or not. All fields below are ignore if RETRIEVE is false. L2: A
   boolean, flagging if the species is part of L2 data of the frequency mode.
   GRID: Retrieval grid to use for the species. UNC_REL and UNC_ABS: Minimum
   relative and absolute uncertainty (1 std dev), respectively. The absolute
   and relative values are compared using the a priori profile and the largest
   of the two is selected (with a max at 1e6 in relative value). CORRLEN:
   Correlation length, in meter, to use when creating Sx. LOG_ON: Set to true
   to impose a positive constrain for the species.

ABS_T_INTERP_ORDER
   An integer. The polynomial order to apply for temperature interpolation of the
   absorption look-up table. See further the ARTS workspace variable with the
   same name.

BACKEND_NR
   An integer. Index of expected backend. Index coding described in L1B ATBD.

BASELINE
   A structure. Definition of baseline off-set retrieval. The fields of the
   structure are as follows. RETRIEVE: A boolean, flagging if baseline off-set
   shall be retrieved or not. UNC: A priori uncertainty (1 std dev). PIECEWISE:
   A boolean. If set to false, the baseline off-set is assumed to be constant
   over the complete frequency band. If set to true, a baseline off-set is
   fitted for each autocorrelator sub-band pair.

CONTINUA_FILE
   A string. Full path to file containing description of absorption
   models/continua, in the format expected by ARTS. 

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

FOLDER_ARTSXMLDATA
   A string. Full path to top folder of arts-xml-data. A correct settings is
   only needed when using the MSIS90 climatology.

FOLDER_BACKEND
   A string. Full path to folder containing backend channel response files.

FOLDER_BDX
   A string. Full path to folder containing files of the Bordeaux a priori
   database. Files having .amt format are expected.   

FOLDER_FGRID
   A string. Full path to folder containing frequency grids.   

FOLDER_WORK
   A string. Full path to a folder where temporary files and/or folders can 
   be placed. If this field is set to '/tmp', a temporary folder is created and
   all files are placed in this folder, and the folder is removed when the
   calculations are done. Otherwise, temporary files are placed directly in the 
   specified folder, and these are left when the calculations are done. This
   option is usefull for debugging, but note that just a single Qsmr process can
   use a folder for debugging. If several Qsmr processes are given the same dubugging
   folder, files will be overwritten.

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
   A matrix, having two colmns. This matrix specifies the frequency ranges to
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
   method. The stops if this value is reached and cost value is still not
   decreased. This value must be > 0.

GA_START
   A scalar value. Start value for gamma factor for the Marquardt-Levenberg
   method. See the L2 ATBD for a definition of the gamma factor. This value must
   be >= 0.

INVEMODE
   A string. A short string maning the inversion set-up used.

LO_COMMON
   A boolean. If true, the initial value of LO frequencies are set to be
   constant over the scan. This value is set following LO_ZREF If false, the 
   L1B value for each altitude is used.

LO_ZREF
   A scalar value. Reference altitude for LO frequency. When performing
   frequency cropping, frequencies are taken from the spectra with the closest
   altitude. Further, if LO_COMMON is set to true, the LO frequency is taken
   from the L1B data of the spectrum closest to this altitude.

MIN_N_FREQS
   A scalar value. The required number of frequencies of each spectrum to start
   an inversion. This number refers to the number of spectra after frequency
   cropping and quality filtering.

MIN_N_SPECTRA
   A scalar value. The required number of spectra of a scan to start an
   inversion. This number refers to the number of spectra after altitude
   cropping and quality filtering.

NOISE_SCALEFAC
   A scalar value. A tuning parameter to adjust the values in Se. The thermal
   noise standard deviation obtained by the L1B data is multiplicated with this
   factor.

NOISE_CORRMODEL
  A string. Model of correlations inside Se. Only correlation between adjecent
  channels of each spectrum is modelled. The options are as follows. 'none':
  this generates a pure diagonal Se. 'empi': Uses emperically derived values
  making Se a five-diagonal matrix. 'expo': Exponentially decreasing
  correlation, approximating the emperically derived values.

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
   variable with the same name.

SIDEBAND_LEAKAGE
   To be defined ...

STOP_DX
   OEM stop criterion. The iteration is halted when the change in x 
   is < stop_dx. Eq. 5.29 in the book by Rodgers is followed, but a
   normalisation with the length of x is applied. This means that STOP_DX
   should in general be in the order of 0.01 (and not change of the state
   vector is expanded).

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

ZTAN_RANGE
   A vector of length 2. The first and last element of this vector give the
   lower and upper tangent limit for spectra to include in the retrieval.
