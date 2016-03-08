% Functions to read and write XML files for sharing data with ARTS.
%
%    This folder contains interface functions to the ARTS XML format.
%
%    Most of these functions are used internally for parsing and writing
%    XML files. Only xmlLoad and xmlStore should be called by the user.
%
%    Examples:
%
%    v = xmlLoad ('vect.xml');
%
%    Load the data from vect.xml into the variable v.
%
%    xmlStore ('tens4.xml', t4, 'Tensor4');
%
%    Stores the Tensor4 t4 into the file tens4.xml.

