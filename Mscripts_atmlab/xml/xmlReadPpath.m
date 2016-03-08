% Reads a Ppath from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the Ppath structure.
%
% FORMAT   result = xmlReadPpath(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Ppath
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-01-09   Created by Oliver Lemke.

function result = xmlReadPpath(fid, attrlist, itype, ftype, binary, fid2)

  result.dim          = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.np           = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.constant     = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.background   = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.start_pos    = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.start_los    = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.start_lstep  = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.pos          = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.los          = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.r            = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.lstep        = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.end_pos      = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.end_los      = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.end_lstep    = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.nreal        = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.ngroup       = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.gp_p         = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.gp_lat       = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
  result.gp_lon       = xmlReadTag(fid, '', itype, ftype, binary, fid2 );


