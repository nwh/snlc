%snlc_clean  clean up snopt output for a problem

function snlc_clean(prob)
  
  if exist(prob.prnt_file,'file'), delete(prob.prnt_file); end
  if exist(prob.summ_file,'file'), delete(prob.summ_file); end
  if exist(prob.spc_file,'file'), delete(prob.spc_file); end

end