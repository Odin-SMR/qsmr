% Q2_PRECALC_BACKEND   Precalculation of backend channel responses
%
%    The function pre-calculates backend response files for all combinations
%    of frequency resolution and Hanning on/off.
%
%    The responses are calculated by in an internal sub-function. The set of
%    frequency resolutions is taken from P.BACKEND_FSPACINGS.
%
%    Only the central part (in frequency) of the repsonse is stored. As the
%    no-Hanning option gives "side-lobes", a much wider frequency range
%    becomes significant. 
%
%    Final files are stored in O.FOLDER_BACKEND
%
% FORMAT   q2_precalc_backend(O,P)
%
% IN  O   O structure
%     P   P structure

% 2015-05-19   Created by Patrick Eriksson.


function q2_precalc_backend(O,P)

  
%- Set out folder
%
outfolder = O.FOLDER_BACKEND;



% A suitable number for JF appears to be 512, per chip. 
%  The relative error on FWHM is then below 0.001.
%
JF = 512; 


for i = 1 : length( P.BACKEND_FSPACINGS )
  for j = 1 : 2

    % Number of chips used (1 for 1MHz etc.)
    nchip = round( 1e6 / P.BACKEND_FSPACINGS(i) );
    
    % Use function below to get overall response
    [x,r,fwhm] = response( nchip, nchip*JF, 0.5*j, false );
    
    
    % Extract core part, following nchip
    ind = find( abs(x) <= 5e6/nchip * (1 + (j-1)*5) );
    x = x(ind);
    r = r(ind);

    if 0
      plot(x/1e6,r)
      grid
      keyboard
    end

    % Create structure and save
    %
    G.name      = 'Backend channel response function';
    G.gridnames = { 'Frequency' };
    G.grids     = { x };
    G.dataname  = 'Response';
    G.data      = r;
    %
    outfile = fullfile( outfolder, ... 
                        sprintf( 'backend_df%04.0fkHz', ...
                                 floor(P.BACKEND_FSPACINGS(i)/1e3) ) );
    if j==1
      outfile = sprintf( '%s_withHan.xml', outfile );
    else
      outfile = sprintf( '%s_noHan.xml', outfile );
    end
    %
    xmlStore( outfile, {G}, 'ArrayOfGriddedField1' );
  end
end


%- Create a simple README
%
fid = fopen( fullfile( outfolder, 'README' ), 'w' );
fprintf( fid, 'The backend response files in this folder were created\n' );
fprintf( fid, sprintf( 'by the function *%s*.', mfilename ) );
fclose( fid );

  



% The function below is copied from Qsmr1's function *pc_response_backend*
% The source is not stated, but the author to the function should be Michael
% Ohlberg. 

%-----------------------------------------------------------------
%
% RESPONSE	calculate response function for Odin correlator
%    RESPONSE(N,JF,A) calculates the response function for an
%    Odin correlator, given the number of correlator chips per band
%    N, the number of sampling points to perform the calculation
%    with and a weight factor A. The weight factor describes the
%    apodizing function to be used, in the sense that the weights
%    are calculated according to:
%
%    w(i) = A + (1-A)*cos(pi*i/n)
%
%    which means that A = 1.0 corresponds to uniform weighting and 
%    A = 0.5 to a Hanning window.
%
%    The routine returns two vectors for frequency and response. A
%    larger JF will increase the quality of the resulting plot, but
%    should not otherwise influence the result.
%
%    example: calculate response for 8 band mode, i.e. 1 chip per
%    band, with and without Hanning filter:
%    [f,P] = response(1,512);      % note that A defaults to 1.0
%    [f,P] = response(1,512,0.5);  % Hanning case
%
%    The routine will output values for FWHM and minimum sidelobe
%    level in dB are printed, so call the function with a ; appended
%    or else those values may scroll off the screen.
%
%----------------------------------------------------------------------
  
function [f,P,FWHM] = response(N,JF,A,do_plot)

  if nargin < 4, do_plot = false; end  % do_plot feature added 2015-05-19 by PE
  
  %if nargin < 3   % Commented out 2015-05-19 by PE
  %  A = 1.0;
  %end
    
  SF = 224.0e6;
  NP = N*112;
  f1 = 0.0;
  f2 = 0.5;
  df = (f2-f1)/JF;
  P = zeros(JF+1);
  % K = 16;
  K = NP/2;
  a = 2*pi/(2*NP);
  AK = K*a;
  b = pi/NP;
  %  W = [ones(N*96,1); zeros(NP-N*96+1,1)];
  H = A+(1-A)*cos(b*[0:NP]');
  %  H = H.*W;
  
  for j = 0:JF
    f = f1+df*j;
    b = 2*pi*f;
    R = cos(b*[0:NP-1]');
    % R(NP+1) = R(NP-1);
    R(NP+1) = 0.0;
    RW = R.*H;
    % RW = R;
    s = 0.0;
    s = sum(RW.*cos(AK*[0:NP]'));
    % P(j+1,l) = 2.0*s-RW(1)-RW(NP+1)*cos(pi*K);
    P(j+1) = 2.0*s-RW(1);
  end

  f = ([0:JF]'*df-0.25)*2.0*NP;
  P = P/max(P);

  if do_plot
    plot(f,P)
    a = axis;
    grid
    xlabel('offset in units of frequency bins')
  end
  
  i = find(P > 0.5);
  i1 = min(i);
  i2 = max(i);
  fr = zeros(1,2);
  fr(1) = f(i1-1)+(0.5-P(i1-1))/(P(i1)-P(i1-1))*(f(i1)-f(i1-1));
  fr(2) = f(i2)+(P(i2)-0.5)/(P(i2)-P(i2+1))*(f(i2+1)-f(i2));
  FWHM = (fr(2)-fr(1));        % in channels
  FWHM = FWHM*0.5*SF/NP;       % in frequency

  if do_plot
    ymin = min(P);
    j = find(P == ymin);
    dB = 10.0*log10(abs(ymin));
    hold on
    plot(fr,[0.5 0.5],'r-')
    plot(f(j),P(j),'ro')
    hold off
  end
  
  % f in frequency
  f = f * 0.5*SF/NP;
