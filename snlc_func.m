function [f g] = snlc_func(x)
  global snlc_func_handle snlc_mA;
  [f g] = snlc_func_handle(x);
  g = g(:);
  f = [f; zeros(snlc_mA,1)];
end