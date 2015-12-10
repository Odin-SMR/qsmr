function L1B = l1b_test(mjd,lat,lon,orbit,scan,alt)
  
L1B.MJD     = mjd;
L1B.LAT     = lat;
L1B.LON     = lon;
L1B.ORBIT   = orbit;
L1B.SCAN    = scan;

L1B.Z_PLAT  = 600e3;

%L1B.Z_TAN   = 16e3 : -1e3: 11e3;
L1B.Z_TAN   = alt;
%L1B.T_INT   = 0.875 + [ ones(1,3) zeros(1,18) ];
L1B.T_INT   = repmat( 0.875, size(L1B.Z_TAN) );
L1B.HANNING = true;