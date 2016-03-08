% Reads SparseData from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadSparseData(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     SparseData
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-06-18   Created by Oliver Lemke.

function result = xmlReadSparseData(fid, attrlist, itype, ftype, binary, fid2)

result = xmlReadVector(fid, attrlist, itype, ftype, binary, fid2);

