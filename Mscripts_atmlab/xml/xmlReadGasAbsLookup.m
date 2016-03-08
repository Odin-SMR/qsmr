% Reads a GasAbsLookup table from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the GasAbsLookup structure.
%
% FORMAT   result = xmlReadGasAbsLookup(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     GasAbsLookup table
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2002-11-28   Created by Oliver Lemke.

function result = xmlReadGasAbsLookup(fid, attrlist, itype, ftype, binary, fid2)

  result.species            = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.nonlinear_species  = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.f_grid             = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.p_grid             = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.vmrs_ref           = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.t_ref              = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.t_pert             = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.nls_pert           = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.xsec               = xmlReadTag(fid, '', itype, ftype, binary, fid2);

