function L1B = l1b_test
  
L1B.MJD     = date2mjd(2000,1,1) + 122;
L1B.LAT     = 50;
L1B.LON     = 30;

L1B.Z_PLAT  = 600e3;

L1B.Z_TAN   = 60e3 : -2e3: 20e3;
%L1B.T_INT   = 0.875 + [ ones(1,3) zeros(1,18) ];
L1B.T_INT   = repmat( 0.875, size(L1B.Z_TAN) );
L1B.HANNING = true;