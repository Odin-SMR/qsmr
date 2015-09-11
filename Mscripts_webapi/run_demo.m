% a demo with example usage of the webapi.
%
% The following steps are done:
%
%  1. search of available FreqModes from a given date
%  2. export of loginfo from all scans from one the FreqMode 
%  3. scan filtering (simple) (find scans from tropical region)
%  4. export of data from 4 of the selected scans 
%
function [y,z,s] = run_demo()


% Get info of available FreqModes for a given date

date = '2015-01-04';
webapi_url = get_webapi_url();
url = [ webapi_url,'/viewscan/',date];
y = get_date_info(url)


% Display what data is available for the given date
str = ['Availbale data for ', date];
disp(str)  
for i = 1:length(y.Info);
  disp(y.Info(i))
end

%-------------------------------------------------------------

% Export loginfo from one of the freqmode

ind = 1;
freqmode = y.Info(ind).FreqMode;
str = ['export loginfo for freqmode ',num2str(freqmode)];
disp(str)    

url = y.Info(ind).URL;
z = get_scan_log(url);
  
%-------------------------------------------------------------

% Make a simple search of scans from loginfo

str = 'find scans within the tropics';
disp(str)

lat = (z.StartLat + z.EndLat)/2;
ind = find(abs(lat)<30);

str = [num2str(length(ind)), ' scans available in the tropics'];
disp(str)

for i = 1:length(ind)
  disp( z.Info( ind(i) ).URL )
end

%--------------------------------------------------------------

str = 'get data from 4 of these scans and plot spectra';
disp(str)


for i=1:min(4,length(ind))
     
    j = ind(i);
    scanid = num2str( z.ScanID( j ) );
    startlat = z.StartLat( j );
    endlat = z.EndLat( j );
    str = [ ' get data from scan ',scanid, ...
            ' StartLat: ',num2str( startlat ),...
            ' EndLat: ',num2str( endlat ) ];
    disp(str)
    disp(z.Info(j).URL)
 
    url = z.Info(j).URL;
    s{i} = get_scan_data(url);
    disp(s{i})


    %plot data
    if i==1
      figure
      set(gcf,'PaperPositionMode','auto')
      hFig = figure(1);
      set(hFig, 'Position', [0 0 1200 600])
      set(gca,'FontSize',8)
      title('test')
    end
    subplot(2,2,i)
    plot(s{i}.Frequency/1e9, s{i}.Spectrum(:,3:end))
    str = sprintf('ScanID: %s Source: %s',num2str(s{i}.ScanID(1)),s{i}.Source{1});
    title(str,'fontsize',8)
    xlabel('Freq. [GHz]') 
    ylabel('Tb [K]')
    ylim([-10,250])
    grid on
  end
end


  

