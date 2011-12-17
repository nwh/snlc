%snlc_solve  solve LC problem with SNOPT
%
% This function uses SNOPT to solve the problem:
%
%   min f(x)
%   s/t bl <=   x <= bu
%       cl <= A*x <= cu
%
% 

function out = snlc_solve(varargin)
  
  in_parse = inputParser;
  
  in_parse.addParamValue('name','snlc-problem',@(x) ischar(x));
  in_parse.addParamValue('usrfun',[],@(x) isa(x,'function_handle'));
  in_parse.addParamValue('x0',[],@(x) isvector(x));
  in_parse.addParamValue('bl',[],@(x) isvector(x));
  in_parse.addParamValue('bu',[],@(x) isvector(x));
  in_parse.addParamValue('A',[],@(x) ismatrix(x));
  in_parse.addParamValue('cl',[],@(x) isvector(x));
  in_parse.addParamValue('cu',[],@(x) isvector(x));
  in_parse.addParamValue('summ_file','snlc_summ.txt',@(x) ischar(x));
  in_parse.addParamValue('prnt_file','snlc_prnt.txt',@(x) ischar(x));
  in_parse.addParamValue('spc_struct',[],@(x) isstruct(x) || isempty(x));
  in_parse.addParamValue('spc_file','snlc.spc', @(x) ischar(x) && ~isempty(x));
  in_parse.addParamValue('spc_save',false,@(x) ismember(x,[0,1]) || islogical(x));
  
  in_parse.parse(varargin{:});
  prob = in_parse.Results;
  
  % output default structure if desired
  if nargin == 0 || ischar(varargin{1})
    out = prob;
    return;
  end
  
  % check if prob.spc_file exists
  if exist(prob.spc_file,'file')
    snlc_file_exists = true;
  else
    snlc_file_exists = false;
  end
  
  % deal with spc_struct 
  spc_struct = [];
  if isstruct(prob.spc_struct) && snlc_file_exists
    % If the user specifies a spc file that exists on disk and a spc struct
    % the program will ignore the struct and use the file on disk.  This is 
    % done to avoid overwriting a hand constructed spc file.  It seems
    % appropriate to print a warning in this case.
    warning('snlc_solve:spc_file_exists','ignoring spc_struct, using existing spc file on disk.');
  elseif isstruct(prob.spc_struct)
    % Here the user has specified a scp structure, the program will use it.
    spc_struct = prob.spc_struct;
  elseif isempty(prob.spc_struct) && ~snlc_file_exists
    % Here no spc structure has been specified and there is nothing on disk.
    % In this case we set the print levels in a structure, which will result in
    % a spc file being written to disk.
    spc_struct.major_print_level = '1';
    spc_struct.minor_print_level = '1';
  end
  
  % write the spc file to disk if needed
  if isstruct(spc_struct)
    snlc_spc_write(spc_struct,prob.spc_file,prob.name);
  end
  
  % check input data
  [mA nA] = size(prob.A);
  nx = length(prob.x0);
  
  if nx ~= nA
    error('snlc_solve:input','sizes of x0 and A are inconsistent.')
  end
  
  if nx ~= length(prob.bl) || nx ~= length(prob.bu)
    error('snlc_solve:input','incorrect size of bl or bu.');
  end
  
  if mA ~= length(prob.cl) || mA ~= length(prob.cu)
    error('snlc_solve:input','incorrect size of cl or cu.');
  end
  
  % snopt setup
  snprint(prob.summ_file);
  snsummary(prob.prnt_file);
  
  % for some reason the SNOPT examples all give the full path to the spc file.
  spc_file_full = which(prob.spc_file);
  snspec(spc_file_full);
  
  % get some data from snopt
  infbnd = abs(sngetr('Infinite bound'));
  
  % setup input data for snopt
  % please refer to the SNOPT documentation for info on these parameters.
  % this is most similar to the snOptA interface.
  x = prob.x0;
  xlow = prob.bl;
  xupp = prob.bu;
  xmul = zeros(nx,1);
  xstate = zeros(nx,1);
  Flow = [-infbnd*1.1; prob.cl(:)];
  Fupp = [infbnd*1.1; prob.cu(:)];
  Fmul = zeros(mA+1,1);
  Fstate = zeros(mA+1,1);
  ObjAdd = 0;
  ObjRow = 1;
  [iAfun jAvar Aval] = find(prob.A);
  iAfun = iAfun(:)+1; jAvar = jAvar(:); Aval = Aval(:);
  iGfun = ones(nx,1); jGvar = (1:nx)';
  
  % prepare user objective function
  global snlc_func_handle snlc_mA;
  snlc_func_handle = prob.usrfun;
  snlc_mA = mA;
  snlc_func_str = 'snlc_func';
  
  % run snopt
  % please refer to the SNOPT documentation for info on these parameters.
  % this is most similar to the snOptA interface.
  [xstar, Fstar, xmul, Fmul, info, xstate, Fstate, ns, ninf, ...
    sinf, mincw, miniw, minrw] = ...
    snsolve( ...
    x, xlow, xupp, xmul, xstate, ...
    Flow, Fupp, Fmul, Fstate, ...
    ObjAdd, ObjRow, ...
    Aval, iAfun, jAvar,...
    iGfun, jGvar, snlc_func_str );
  
  % construct output structure
  out.xstar = xstar;
  out.Fstar = Fstar;
  out.xmul = xmul;
  out.Fmul = Fmul;
  out.info = info;
  out.xstate = xstate;
  out.Fstate = Fstate;
  out.ns = ns;
  out.ninf = ninf;
  out.sinf = sinf;
  out.mincw = mincw;
  out.miniw = miniw;
  out.minrw = minrw;
  
  % clean up
  snprint off
  snsummary off
  if isstruct(prob.spc_struct) && ~prob.spc_save
    snlc_spc_clean(prob.spc_file);
  end
  
end
