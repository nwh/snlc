%snlc_example  snlc example problem
%
% min sum(x.^3) + d'*x
% s/t sum(x) == 1
%     -1 <= x <= 1
%

function snlc_example

  % settings
  n = 10;
  rng_seed = 210;
  
  % seed the rng
  RandStream.setDefaultStream(RandStream('mt19937ar','seed',rng_seed));

  % generate c
  d = randn(n,1);
  
  % generate problem data
  A = ones(1,n);
  cl = 1;
  cu = 1;
  bl = -ones(n,1);
  bu = ones(n,1);
  usrfun = @(x) snlc_example_func(x,d);
  
  % starting point
  x0 = zeros(n,1);
  
  % get problem structure
  prob = snlc_solve();
  
  % set problem structure
  prob.A = A;
  prob.cl = cl;
  prob.cu = cu;
  prob.x0 = x0;
  prob.bl = bl;
  prob.bu = bu;
  prob.usrfun = usrfun;
  
  % set up spec file
  %spc.major_print_level = '1';
  %spc.minor_print_level = '1';
  %prob.spc = spc;
  
  % call solver
  out = snlc_solve(prob);
  
  keyboard
  
end

function [f g] = snlc_example_func(x,d)
  
  d = d(:);
  x = x(:);
  
  f = sum(x.^3) + d'*x;
  g = 3*(x.^2) + d;
  
end
