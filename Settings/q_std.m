function Q = q_std

%-----------------------------------------------------------------------------
%--- Common settings
%-----------------------------------------------------------------------------

  
  
%-----------------------------------------------------------------------------
%--- User specific settings
%-----------------------------------------------------------------------------  
  
switch whoami
  
 case 'patrick'
  %
  Q.ARTS_VERSION       = 'arts-2.3.286';
  Q.ATMLAB_VERSION     = 'atmlab-2.3.105';
  Q.WORK_AREA          = '/home/patrick/WORKAREA';  
  
 case 'joonask'
  %
  Q.ARTS_VERSION       = 'arts-2.3.286';
  Q.ATMLAB_VERSION     = 'atmlab-2.3.105';
  Q.WORK_AREA          = '/home/joonask/WORKAREA';  

 otherwise
  error( 'Unknown user.' );
end




