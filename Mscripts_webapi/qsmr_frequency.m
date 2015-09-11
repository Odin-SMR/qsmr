%-------------------------------------------------------------------
function [f] = qsmr_frequency(scan_h,numspec)
%
% DESCRIPTION:  Generates frequency per spectrum in scan, 
%               2001/21/9. Partly provided by Frank Merino,
%               updated by C. jimenez, M. Olberg, N. Lautie, 
%               J. Urban (2002-2007).
%
% INPUT:        (struct) scan_h:  structure created by call such as below: 
%                               scan_h = read_hdfheader(SMR,file_id,nrec).
%               (int) num_spec: spectrum number in HDF file for which
%                               the frequencies shall be determined.
%
% OUT:          (double) frequency vector (AOS) or matrix (AC) [Hz].
%              
% VERSION:      2007-Jan-26 (JU) 
%-------------------------------------------------------------------

%--- filling S to use Franks mscript

  S.Level     = scan_h.Level(numspec);
  S.Channels  = scan_h.Channels(numspec);
  S.IntMode   = scan_h.IntMode(numspec);
  S.FreqCal   = scan_h.FreqCal(:,numspec);
  S.Quality   = scan_h.Quality(numspec);
  S.SkyFreq   = scan_h.SkyFreq(numspec);
  S.Backend   = scan_h.Backend(numspec);
  S.FreqRes   = scan_h.FreqRes(numspec);
  S.RestFreq  = scan_h.RestFreq(numspec);
  % -- correcting Doppler in LO
  S.LOFreq    = scan_h.LOFreq(numspec)-(S.SkyFreq-S.RestFreq);

  % Note:
  % S.Backend(numspec) == 1 -> AC1
  % S.Backend(numspec) == 2 -> AC2
  % S.Backend(numspec) == 3 -> AOS
  % otherwise : FBA

  % --- START FRANKS MSCRIPT---------------------------------------

  n = S.Channels;
  f = [];

  %--  == 1 missing

  %--- if FSORTED frequency sorting performed ---------------------
  %if bitand(hex2dec(S.Level), hex2dec('0080'))==1
  %if bitand(S.Level, hex2dec('0080'))==1
  
  %%% ISORTED bit is now part of Quality %%%

  %JU%if bitand(hex2dec(S.Quality), hex2dec('02000000'))
  if bitand((S.Quality), hex2dec('02000000'))

    x = [0:n-1]-floor(n/2);
    f = zeros(n,1);
    c = S.FreqCal(end:-1:1);    % MO uses fliplr, but we have here a
    %c = fliplr(S.FreqCal);     % column vector (PE 060602)
    f = polyval(c, x);
    mode = 0;

  else %------------------------------------------------------------

    %-- AOS
    if S.Backend == 3    % AOS
    %if strcmp(S.Backend,'AOS') == 1
      x = [0:n-1]-floor(n/2);

      c = S.FreqCal(end:-1:1);   % MO uses fliplr, but we have here a
      % c = fliplr(S.FreqCal);   % column vector (PE 060602)
      f = 3900.0e6*ones(1,n)-(polyval(c, x)-2100.0e6);
      mode = 0;
      
      %-- autocorrelators
    else

      %%%% new code for spectra which have ADC_SEQ set %%% 

      if bitand(S.IntMode, 256)
	%
	% The IntMode reported by the correlator is interpreted as
	% a bit pattern. Because this bit pattern only describes ADC
	% 2-8, the real bit pattern is obtained by left shifting it
	% by one bit and adding one (i.e. it is assumed that ADC 1
	% is always on).
	%
	% The sidebands used are represented by vector ssb, this is
	% hard-wired into the correlators:
	ssb = [1, -1, 1, -1, -1, 1, -1, 1];
      
	% Analyse the correlator mode by reading the bit pattern
	% from right to left(!) and calculating a sequence of 16
	% integers whose meaning is as follows:
	%
	% n1 ssb1 n2 ssb2 n3 ssb3 ... n8 ssb8
	% 
	% n1 ... n8 are the numbers of chips that are cascaded 
	% to form a band. 
	% ssb1 ... ssb8 are +1 or -1 for USB or SSB, respectively.  
	% Unused ADCs are represented by zeros.
	%
	% examples (the "classical" modes):
	%
	% mode 0x00: ==> bit pattern 00000001
	% 8  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0
	% i.e. ADC 1 uses 8 chips in upper-side band mode
	%
	% mode 0x08: ==> bit pattern 00010001
	% 4  1  0  0  0  0  0  0  4 -1  0  0  0  0  0  0
	% i.e. ADC 1 uses 4 chips in upper-side band mode
	% and  ADC 5 uses 4 chips in lower-side band mode
	%
	% mode 0x2A: ==> bit pattern 01010101
	% 2  1  0  0  2  1  0  0  2 -1  0  0  2 -1  0  0
	% i.e. ADC 1 uses 2 chips in upper-side band mode
	% and  ADC 3 uses 2 chips in upper-side band mode
	% and  ADC 5 uses 2 chips in lower-side band mode
	% and  ADC 7 uses 2 chips in lower-side band mode
	%
	% mode 0x7F: ==> bit pattern 11111111
	% 1  1  1 -1  1  1  1 -1  1 -1  1  1  1 -1  1  1
	% i.e. ADC 1 uses 1 chip in upper-side band mode
	% and  ADC 2 uses 1 chip in lower-side band mode
	% and  ADC 3 uses 1 chip in upper-side band mode
	% and  ADC 4 uses 1 chip in lower-side band mode
	% and  ADC 5 uses 1 chip in lower-side band mode
	% and  ADC 6 uses 1 chip in upper-side band mode
	% and  ADC 7 uses 1 chip in lower-side band mode
	% and  ADC 8 uses 1 chip in upper-side band mode
	%
	mode = bitand(S.IntMode, 255);
	bands = 0;
	seq = zeros(1,16);
	m = 0;
	for bit = 1:8
	  if bitget(mode,bit) 
	    m = bit;
	  end
	  seq(2*m-1) = seq(2*m-1)+1;
	end    
	for bit = 1:8
	  if seq(2*bit-1) > 0
	    seq(2*bit) = ssb(bit);
	  else
	    seq(2*bit) = 0;
	  end
	end    
	% disp(seq)
	
	f = zeros(8,112);

        bands = [1 2 3 4 5 6 7 8];     % default: use all bands
        if bitand(S.IntMode, 512)      % test for split mode
          if bitand(S.IntMode, 1024)
            bands = [3 4 7 8];       % upper band
          else
            bands = [1 2 5 6];       % lower band
          end
        end

        for adc = bands     % Previous loop: for adc = 1:8
	  if seq(2*adc-1) > 0
	    df = 1.0e6/seq(2*adc-1);
	    if seq(2*adc) < 0
	      df = -df;
	    end
	    for j=1:seq(2*adc-1)
	      m = adc-1+j;
	      % The frequencies are calculated by noting that two
	      % consecutive ADCs share the same internal SSB-LO:
	      f(m,1:112) = S.FreqCal(round(adc/2))*ones(1,112) + ...
		  [0:111]*df+(j-1)*112*df;
	    end
	  end
	end

        if bitand(S.IntMode, 512)     % for split mode keep used bands only
          f = f(bands,:);
        end

      %%%%  end of new code %%%
      
      else
      
	df = S.FreqRes;
	mode = bitand(S.IntMode, 15);
	if bitand(S.IntMode, bitshift(1,4))
	  if bitand(S.IntMode, bitshift(1,5))
	    if mode == 2
	      m = n;
	      f = S.FreqCal(2)*ones(1,m)-[m-1:-1:0]*df;
	    elseif mode == 3
	      m = n/2;
	      f = [ S.FreqCal(4)*ones(1,m)-[m-1:-1:0]*df;
		    S.FreqCal(3)*ones(1,m)+[0:m-1]*df ];
	    else
	      m = n/4;
	      f = [ S.FreqCal(3)*ones(1,m)-[m-1:-1:0]*df;
		    S.FreqCal(3)*ones(1,m)+[0:m-1]*df;
		    S.FreqCal(4)*ones(1,m)-[m-1:-1:0]*df;
		    S.FreqCal(4)*ones(1,m)+[0:m-1]*df ];
	    end
	  else
	    if mode == 2
	      m = n;
	      f = S.FreqCal(1)*ones(1,m)+[0:m-1]*df;
	      mode
	    elseif mode == 3
	      m = n/2;
	      f = [ S.FreqCal(2)*ones(1,m)-[m-1:-1:0]*df;
		    S.FreqCal(1)*ones(1,m)+[0:m-1]*df ];
	    else
	      m = n/4;
	      f = [ S.FreqCal(1)*ones(1,m)-[m-1:-1:0]*df;
		    S.FreqCal(1)*ones(1,m)+[0:m-1]*df;
		    S.FreqCal(2)*ones(1,m)-[m-1:-1:0]*df;
		    S.FreqCal(2)*ones(1,m)+[0:m-1]*df ];
	    end
	  end
	else
	  if mode == 1
	    m = n;
	    f = S.FreqCal(1)*ones(1,m)+[0:m-1]*df;
	  elseif mode == 2
	    m = n/2;
	    f = [ S.FreqCal(1)*ones(1,m)+[0:m-1]*df;
		  S.FreqCal(2)*ones(1,m)-[m-1:-1:0]*df ];
	  elseif mode == 3
	    m = n/4;
	    f = [ S.FreqCal(2)*ones(1,m)-[m-1:-1:0]*df;
		  S.FreqCal(1)*ones(1,m)+[0:m-1]*df;
		  S.FreqCal(4)*ones(1,m)-[m-1:-1:0]*df;
		  S.FreqCal(3)*ones(1,m)+[0:m-1]*df ];
	  else
	    m = n/8;
	    f = [ S.FreqCal(1)*ones(1,m)-[m-1:-1:0]*df;
		  S.FreqCal(1)*ones(1,m)+[0:m-1]*df;
		  S.FreqCal(2)*ones(1,m)-[m-1:-1:0]*df;
		  S.FreqCal(2)*ones(1,m)+[0:m-1]*df;
		  S.FreqCal(3)*ones(1,m)-[m-1:-1:0]*df;
		  S.FreqCal(3)*ones(1,m)+[0:m-1]*df;
		  S.FreqCal(4)*ones(1,m)-[m-1:-1:0]*df;
		  S.FreqCal(4)*ones(1,m)+[0:m-1]*df ];
	  end
	end
      end
    end %--------------------------------------------------------
  end

  if isempty(f)
    disp('qsmr_frequency.m: no frequencies, spectrum not frequency sorted!')
    f = [];
    return
  end
  f = f'; %'

  if bitand(S.Quality, bin2dec('00001000')) == 0

    if (S.SkyFreq - S.LOFreq) > 0.0
      f = S.LOFreq + f;
    else
      f = S.LOFreq - f;
    end

  end

  % --- END FRANKS MSCRIPT---------------------------------------

return
