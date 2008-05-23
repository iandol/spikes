% CORRF:  Objective function for corr().  Assumes that input variables have 
%           already been mean-centered (ie, that they are in the form of 
%           deviations from the means).
%
%     Usage: r = corrf(X,notused1,notused2,notused3,P1,P2,makerow,useabs)
%
%         X =       concatenated input matrices: [X1 X2].
%         P1,P2 =   number of variables for X1 and X2 (P2=0 if X2 is null).
%         makerow = boolean flag indicating that output is to be in the form of 
%                     a row vector, the transposition of concatenated 
%                     columns of:
%                       - lower triangular matrix, if P2=0;
%                       - entire rectangular matrix, if P2>0.
%         useabs =  boolean flag indicating that the absolute values of r are
%                     to be returned.
%         ---------------------------------------------------------------------
%         r =       correlation matrix or vector.
%

% RE Strauss, 5/25/99
%   10/19/00 - allow for correlations with one variable invariant.

function r = corrf(X,notused1,notused2,notused3,P1,P2,makerow,useabs)
  if (P2==0)                                % X1 only provided
    cp = X'*X;                                  % Sums of cross products
    ss = sqrt(diag(cp));                        % Sums of squares
    r = cp./max(ss*ss',eps*ones(P1,P1));        % Correlations

    if (makerow)
      r = trilow(r)';
    end;
    if (useabs)
      r = abs(r);
    end;
  end;

  if (P2>0)                                 % X1 & X2 provided
    X1 = X(:,1:P1);                           % Separate matrices
    X2 = X(:,(P1+1):(P1+P2));

    r = zeros(P1,P2);                         % Calc all pairwise correlations
    ss2 = sqrt(diag(X2'*X2))';
    for i = 1:P1
      x1 = X1(:,i);
      cp = x1'*X2;
      ss1 = sqrt(x1'*x1);
      j = find(ss1.*ss2 < eps);
      if (~isempty(j))
        ss2(j) = NaN*ones(size(j));
      end;
      r(i,:) = cp./(ss1.*ss2);
    end;

    if (makerow)
      r = [r(:)]';
    end;
    if (useabs)
      r = abs(r);
    end;
  end;

  return;
