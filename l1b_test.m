function L1B = l1b_test
  
L1B.MJD     = date2mjd(2013,6,5);
L1B.LAT     = 64;
L1B.LON     = 173;
L1B.ORBIT   = 64693;
L1B.SCAN    = 10;

L1B.Z_PLAT  = 600e3;

L1B.Z_TAN   = 16e3 : -1e3: 11e3;
%L1B.T_INT   = 0.875 + [ ones(1,3) zeros(1,18) ];
L1B.T_INT   = repmat( 0.875, size(L1B.Z_TAN) );
L1B.HANNING = true;