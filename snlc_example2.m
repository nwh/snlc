%snlc_example2  solve rosenbrock problem with snlc/SNOPT
%
% The problem is unconstrained.  Bounds and constraint matrix can be left
% empty.
%
function snlc_example2

  % setup
  usrfun = @(x) rosen(x);
  x0 = [1.2; -1];
  
  % setup problem structure
  prob = snlc_solve();
  prob.name = 'rosen';
  prob.x0 = x0;
  prob.usrfun = usrfun;
  
  % run snopt
  out = snlc_solve(prob);
  
  % simple output
  fprintf('SNOPT returned exit code: %d\n',out.info);
  
  % clean up
  if out.info == 1
    snlc_clean(prob);
  end

end

function [f g] = rosen(x)
  f = (1-x(1))^2 + 100*(x(2)-x(1)^2)^2;
  if ( nargout > 1 )
    % return the gradient
    g = [0;0];
    g(1) = 400*x(1)^3-2*x(1)*(200*x(2)-1)-2;
    g(2) = 200*(x(2)-x(1)^2);
  end
end