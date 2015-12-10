=======================================
Qsmr: definition of existing settings
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
   structure must contain exactly this set of settings; all fields must be
   present and no additional ones are allowed. All defined settings are
   described below, grouped into topics.

~~~~~



Paths and versions:
--------------------------------------

ARTS_VERSION
  The expected version of ARTS. Given as a complete string, e.g. 'arts-2.3.190'.

ATMLAB_VERSION
  The expected version of Atmalb. Given as a complete string, e.g. 'atmlab-2.3.80'.

WORK_AREA
  Matches directly Atmlab's setting with the same name. Path to a folder where a work
  folder can be created. 





