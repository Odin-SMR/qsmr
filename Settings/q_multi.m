function Q = q_multi(qfun,fmodes)
  
for i = 1 : length(fmodes)
  Q(i) = qfun( fmodes(i) );
end

  