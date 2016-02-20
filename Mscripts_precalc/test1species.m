function [f,Y] = test1species( ztans, lat, doy, fmode, species )



Q = q_std( fmode );

Q.ABS_SPECIES             = [];
Q.ABS_SPECIES(1).TAG{1}   = species;
Q.ABS_SPECIES(1).SOURCE   = 'Bdx';
Q.ABS_SPECIES(1).RETRIEVE = false;


[LOG,L1B] = l1b_homemade( Q, ztans, lat, 0, date2mjd(2010,1,1)+doy );


ATM = q2_get_atm( LOG, Q );


[Y,F] = q2_arts_y( L1B, ATM, Q, false, false );

plot( F/1e9, Y, '.' )
xlabel( 'Frequency [GHz]' );
ylabel( 'Tb [K]' );