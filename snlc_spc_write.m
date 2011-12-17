%snlc_spc_write  write snopt spc file from a struct
%
% Takes information in a matlab struct and writes to a file that SNOPT reads to
% set options.
%
% The fields of the input struct should be the names of SNOPT parameters.
% The fieldnames use underscores in places of spaces.  All values should be
% strings.
%
% Usage:
%   spc_struct.major_print_level = '1';
%   spc_struct.minor_print_level = '1';
%   snlc_spc_write(spc_struct,'snlc.spc','snlc-problem');
%
% Output file:
%   begin snlc-problem options
%     major print level         1
%     minor print level         1
%   end snlc-problem options
%
% Function input:
%   spc_struct = structure with SNOPT options
%   spc_file = name for specification file
%   prob_name = optional name for the file
%
% Function output:
%   spc_file = name of file that was written to disk
%
function [spc_file] = snlc_spc_write(spc_struct,spc_file,prob_name)

  if nargin < 3 || isempty(prob_name)
    prob_name = 'snopt-lc-problem';
  end
  
  if nargin < 2 || isempty(spc_file)
    spc_file = 'snlc.spc';
  end
  
  if nargin == 0
    error('snlc_spc_write:input','spc_struct is required.');
  end
  
  sn_opts = fieldnames(spc_struct);
  num_opts = length(sn_opts);
  
  spc_fid = fopen(spc_file,'w');
  
  if spc_fid < 3
    error('snlc_spc_write:io','could not open file.');
  end
  
  fprintf(spc_fid,'begin %s options\n',prob_name);
  
  for i = 1:num_opts
    opt_name = strrep(sn_opts{i},'_',' ');
    opt_val = spc_struct.(sn_opts{i});
    fprintf(spc_fid,'  %-25s %s\n',opt_name,opt_val);
  end

  fprintf(spc_fid,'end %s options\n',prob_name);
  
  fclose(spc_fid);
  
end
