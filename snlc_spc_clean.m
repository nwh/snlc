%snlc_spc_clean  delete a spc file

function snlc_spc_clean(spc_file)
  
  if exist(spc_file,'file'), delete(spc_file); end
  
end