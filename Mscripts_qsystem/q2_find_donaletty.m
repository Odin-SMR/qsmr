function [Tint,Zint,T,Z,PTZ]=q2_find_donaletty(pgrid,orbit,scan)

%(O.P_GRID,L1B.ORBIT,L1B.SCAN);

O.P_GRID=pgrid;
L1B.ORBIT=orbit;
L1B.SCAN=scan;
hexorbits=dec2hex(L1B.ORBIT);
folder=hexorbits(:,1:end-2);

path=['/odin/smr/Data/SMRl1b/V-7/AC2/',folder];
        srchstring=[path,'/*',hexorbits,'.PTZ'];
        %search for .ptz file containing orbit number in the directory
        
list=dir(srchstring);
if length(list)>0
    %if the srchstring is found in the directory, the name of the PTZ
    %is generated along with all other procedures. If the srchstring is 
    %not found, the loop proceeds to the next orbit.
    ptzname=list.name;
    ptzsrch=[path,'/',ptzname];
    logname=[ptzname(1:end-3),'LOG'];
    logsrch=[path,'/',logname];

    %open ptz file for reading
    fid=fopen(ptzsrch,'rt');
    line=fgetl(fid);

    %the length of each block containing data and the number of blocks
    %is read from the first 5 rows of the file. Blockwidth is assumed
    %to be equal to 3.
    intro=textscan(fid,'%s',5,'Delimiter','\n');
    intro2=str2num(intro{1}{5});
    blocks=str2double(intro{1}{4});
    blocklength=intro2(1);
    blockwidth=3;

    %Create a 3D-matrix containing the data for each scan.

    for level=1:blocks
        try
            PTZ(:,:,level)=fscanf(fid,'%f',[blockwidth blocklength])';
            line=fgetl(fid);line=fgetl(fid);
        catch ME
        end
    end
    fclose(fid);

    T=PTZ(:,2,L1B.SCAN);
    P=PTZ(:,1,L1B.SCAN)*100;
    Z=PTZ(:,3,L1B.SCAN)*1000;
    Tint=interpp(P,T,O.P_GRID);
    Zint=interpp(P,Z,O.P_GRID);
    
end    
