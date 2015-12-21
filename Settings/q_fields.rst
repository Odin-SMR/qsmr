=======================================
Qsmr: definition of settings
=======================================

:Authors: 

   Patrick Eriksson <patrick.eriksson@chalmers.se> 

:Version: 
        
   0.1 


:Date:

   2015-XX-XX


:Abstract: 

   This document contains a brief description of the settings considered by the
   Qsmr system. These settings are packed into a structure denoted as Q. This
   structure must contain an exact set of fields; all fields must be
   present and no additional ones are allowed. The defined fields are described
   below, in alphabetical order.

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
   be retrieved or not. L2: A boolean, flagging if the species is part of L2
   data of the frequency mode. GRID: Retrieval grid to use for the species. L2
   and GRID are ignored if RETRIEVE is false.

ABS_T_INTERP_ORDER
   An integer. The polynomial order to apply for temperature interpolation of the
   absorption look-up table. See further the ARTS workspace variable with the
   same name.

BACKEND_NR
   An integer. Index of expected backend. Index coding described in L1B ATBD.

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

FMODE
   An integer. The frequency mode. See L1B ATBD for definition of existing
   frequency modes.

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
   database. Files having .amt format are expected.   

FOLDER_FGRID
   A string. Full path to folder containing frequency grids.   

FRONTEND_NR
   An integer. Index of expected frontend. Index coding described in L1B ATBD.

F_BACKEND_COMMON
   A boolean. If true, the backend channels are treated to have the same
   frequencies throughout the scan. If false, these frequencies are allowed to
   vary over the scan.

F_BACKEND_NOMINAL
   A vector. Nominal value of the backend channel centre frequencies.

F_GRID_NFILL
   An integer. If set to > 0, the sensor response matrix will include a cubic
   frequency interpolation of the spectra, with F_GRID_NFILL points added
   between existing grid points. See further the ARTS workspace method 
   sensor_responseFillFgrid. If set to 0, no such interpolation is made.

F_LO_NOMINAL
   A scalar value. Nominal value of the LO frequency.

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

T_SOURCE
   A string. This string describes from where temperature a priori shall be
   taken. The following options are treated: 'WebApi', 'MSIS90' and 'CIRA86'.
   The two last options require that arts-xml-data is at hand.
