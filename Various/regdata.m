function [std,varresid,r2,cor,vcv,varinf]=regdata(param,yfit,ydata,jac)
%[std,varresid,r2,cor,vcv,varinf]=regdata(param,yfit,ydata,jac)
% Calculate and Plot regression statistics from curvefit.m
% OUT
% std -standard error of each parameter
% varresid- Variance of residuals
% r2	- R^2 Correlation coefficient
% cor	- Correlation matrix for Parameters
% vcv	- Variance Covariance Matrix for Parameters
% varinf- Variance inflation factors >10 implies Multicollinearity in x's
% IN
% param	-Least squares parameter values
% yfit	-Response fit using param to get yfit from curvefit use 
% yfit=F+ydata 

% ydata	-Response data
% jac	-Jacobian value at Least squares parameter values

% Arthur Jutan Univ of Western Ontario Dept of Chemical Engineering
% jutan@fs2.engga.uwo.ca

e=yfit-ydata; %error
ss=e'*e; % best sum of squares
m=length(yfit);n=length(param);
if (m~=n),varresid=ss./(m-n);else, var=NaN;end % variance of Residuals

% CALC VARIANCE COV MATRIX AND CORRELATION MATRIX OF PARAMETERS

      xtx=jac'*jac;
      xtxinv=inv(xtx);
      
      %calc correlation matrix cor and variance inflation varinf
	varinf = diag(xtxinv);
	cor = xtxinv./sqrt(varinf*varinf');

% Plot the fit vs data
      t=1:m;
      plot(t,ydata,'o',t,yfit,'g-')
      title(' ydata and ymodel versus observation number')
      xlabel(' observation number');
      ylabel(' ydata o and ymodel-')
      grid;
      
      disp(' Least Squares Estimates of Parameters')
      disp(param')
      disp(' correlation matrix for parameters ')
      disp(cor)
      vcv=xtxinv.*varresid; % mult by var of residuals~=pure error
      disp('Variance inflation Factors >10 ==> Multicollinearity in x"s')
      disp(varinf')

%Formulae for vcv=(x'.vo.x)^-1 *sigma^2 where meas error Var, v=[vo]*sigma^2	
      std=sqrt(diag(vcv)); % calc std error for each param
      disp('2*standard deviation (95%CL) for each parameter')
      disp(2*std')
%Calculate R^2 (Ref Draper & Smith p.46)
      r=corrcoef(ydata,yfit);
      r2=r(1,2).^2;
      disp('Variance of Residuals  ' )
      disp(  varresid )
      disp( 'Correlation Coefficient R^2')
      disp(r2)

