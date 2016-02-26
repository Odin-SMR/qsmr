% A demonstration how to search and extract odin/smr 
% and correlative collocated data from the verification 
% dataset (VDS)
%
% 4 type of different requests is demonstrated:
% 
% 
%  1: a request to the root URI to get information
%     on the VDS content (i.e which odin/smr freqmodes
%     that is included in the VDS)
%
%  2: a request to get available VDS data for a given 
%     freqmode of odin/smr (i.e which correlative
%     datasets that matches the given freqmode). 
%
%  3: a request to get available vds data for a given 
%     freqmode and mathcing instrument/species
%     (i.e. dates for which collocations are available)
%
%  4: a request to get actual odin/smr level1b data
%     and collocated level2 data for a given scan      

function [scandata, compl2] = odin_webapi_vds_demo()

%some hardcoded settings in this demo
freqmode = 1;
instrument = 'osiris';
instrument = 'smr';
species = 'O3';
date = '2011-04-21';

%------------------------------------------------------------------
% Start by making a request to the root URI of the VDS API 
%----------------------------------------------------------------

url = 'http://malachite.rss.chalmers.se/rest_api/v4/vds/';
y0 = webread(url, weboptions('ContentType','json','Timeout',60));

% display which frequency modes that are included in the VDS
% and links to more detailed data

for i = 1:length(y0.VDS)

  display(y0.VDS(i))

end

%--------------------------------------------------------------------------
% select one freqmode and display what VDS data (instrument/species) 
% that is available for that:
% available VDS data is here categorised into instrument and species,
% e.g. one entry can be osiris and O3
%--------------------------------------------------------------------------

ind = find( [y0.VDS.FreqMode] == freqmode );
VDS = y0.VDS(ind);
url = VDS.URL_collocation
y0 = webread(url, weboptions('ContentType','json','Timeout',60));

for i = 1:length(y0.VDS)

  display(y0.VDS(i))

end

%------------------------------------------------------------------
% select one instrument/species and get the data
% (the result correseponds to dates for which data is available)
%------------------------------------------------------------------

ind  = find( strcmp({y0.VDS.Instrument}, instrument) & ...
             strcmp({y0.VDS.Species}, species) );
VDS = y0.VDS(ind);

y0 = webread(VDS.URL, weboptions('ContentType','json','Timeout',60));

% display for which dates data is availabele
display({y0.VDS.Date})


%------------------------------------------------------------------
% select a date and get available scans for this date
% 
%------------------------------------------------------------------

ind = find( strcmp({y0.VDS.Date}, date) );

VDS = y0.VDS(ind);
y0 = webread(VDS.URL, weboptions('ContentType','json','Timeout',60));

%------------------------------------------------------------------
% select and get data from all of the scans this day 
%-----------------------------------------------------------------

for n = 1 : length(y0.VDS)

  url2odinl1b = y0.VDS(n).URLS.URL_spectra;
  url2compl2 = eval(['y0.VDS(n).URLS.URL_',lower(instrument),'_',species]);
  scandata(n) = get_scan_l1b_data(url2odinl1b);
  compl2(n) = webread(url2compl2, weboptions('ContentType','json','Timeout',60));

end

%------------------------------------------------------------------
% plot data
%------------------------------------------------------------------


figure
set(gcf,'PaperPositionMode','auto')
hFig = figure(1);
set(hFig, 'Position', [0 0 1200 600])
set(gca,'FontSize',8)

s0 = length(scandata);
for i = 1:s0

  [s1,s2] = size(scandata(i).Spectrum);
  lofreq = ones(s1,1) * scandata(i).Frequency.LOFreq';
  IFreqmat = scandata(i).Frequency.IFreqGrid * ones(1,s2);
  freqmat = lofreq + IFreqmat;
  okind = find(~bitget(scandata(i).Quality,find(bitget(hex2dec('0020'),1:8))));
  subplot(s0,2,1 + 2*(i-1))
  plot( freqmat(:,okind)/1e9, scandata(i).Spectrum(:,okind ) )
  grid on
  scanmjd = (scandata(i).MJD(1)+scandata(i).MJD(end))/2;
  scandate = datestr(datenum('1858-11-17') + scanmjd,'yyyy-mm-ddTHH:MM:SS');
  scanid = num2str(scandata(i).ScanID(1));
  scanfreqmode = scandata(i).FreqMode(1);
  str = sprintf('Date: %s \nScanID: %s FreqMode: %d', scandate,scanid,scanfreqmode);
  title(str,'fontsize',8)
  xlabel('Freq. [GHz]') 
  ylabel('Tb [K]')
  ylim([-10,250])

  c1 = subplot(s0,2,2 + 2*(i-1));

  if isequal(instrument,'MLS');

     semilogy(compl2(i).data_fields.L2gpValue*1e6,compl2(i).geolocation_fields.Pressure)
     set(c1,'ydir','reverse');
     xlabel('VMR [ppmv]')
     ylabel('Pressure [hPa]')
     title([instrument,': ',species])
     grid on
 
  elseif isequal(lower(instrument),'smiles');
     
     plot(compl2(i).data_fields.L2Value*1e6,compl2(i).geolocation_fields.Altitude)
     xlabel('VMR [ppmv]')
     ylabel('Altitude [Km]')
     title([instrument,': ',species])
     grid on
 
  elseif isequal(lower(instrument),'mipas');

     semilogy(compl2(i).target,compl2(i).pressure)
     set(c1,'ydir','reverse');
     xlabel('VMR [ppmv]')
     ylabel('Pressure [hPa]')
     title([instrument,': ',species])
     grid on 

  elseif isequal(lower(instrument),'osiris');

     okind = find(compl2(i).data_fields.O3~=-9999);
     plot(compl2(i).data_fields.O3(okind)*1e6, compl2(i).geolocation_fields.Altitude(okind))
     xlabel('VMR [ppmv]')
     ylabel('Altitude [Km]')
     title([instrument,': ',species])
     grid on

  elseif isequal(lower(instrument),'smr');
    
     plot(compl2(i).Data.Profiles, compl2(i).Data.Altitudes)
     xlabel('VMR [ppmv]')
     ylabel('Altitude [Km]')
     title([instrument,': ',species])
     grid on


  end

end




