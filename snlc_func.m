function [f g] = snlc_func(x)
  global snlc_func_handle snlc_mA snlc_fevcnt;

  % evaluate function
  [f g] = snlc_func_handle(x);
  g = g(:);

  % must store nonlinear part of constraints (all zero!)
  f = [f; zeros(snlc_mA,1)];
  
  % increment function eval counter
  snlc_fevcnt = snlc_fevcnt + 1;
  
end