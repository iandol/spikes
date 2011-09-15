erefunction bootanovagr(x,s,alpha)
%BOOTANOVAGR Bootstrap Analysis of Variance Graphical Approach.
%   The bootstrap is a way of estimating the variability of a statistic   
%   from a single data set by resampling it independently and with equal
%   probabilities (Monte Carlo resampling). Allows the estimation of 
%   measures where the underlying distribution is unknown or where sample 
%   sizes are small. Their results are consistent with the statistical 
%   properties of those analytical methods (Efron and Tibshirani, 1993).
%
%   The name 'bootstrap' originates from the expression 'pulling yourself 
%   up by your own bootstraps' and refers to the basic idea of the 
%   bootstrap, sampling with replacement from the data. In this way a
%   large number of 'bootstrap samples' is generated, each of the same size
%   as the original data set. From each bootstrap sample the statistical 
%   parameter of interest is calculated (Wehrens and Van der Linden, 1997)
%  
%   Here, we use the Non-parametric Bootstrap. Non-parametric bootstrap is 
%   simpler. It does not use the structure of the model to construct 
%   artificial data. The data is instead directly resampled with
%   replecement.
%
%   As Reddy et al. (2010) did, here a m-file graphical procedure using  
%   bootstrap method is developed as an alternative to the ANOVA to test  
%   the hypothesis on equality of several means.
%
%   BOOTANOVAGR treats NaN values as missing values, and removes them.
%
%   Syntax: function bootanovagr(x,s,alpha)
%
%     Inputs:
%          x – data nx2 matrix (Col 1 = data; Col 2 = sample code)
%          s - boot times or number of Bootstrap simulations (resamplings)
%      alpha - significance level (default=0.05)
%
%     Outputs:
%          - Summary statistics from the samples
%          - Graphics of the bootstrap procedure to test equality of means
%            (Null-hypothesis is rejected if any of the means lie ouside 
%            the decision lines)
%
%   Taking the numerical example given by Reddy et al. (2010), the 
%   lifetimes (in hours) of samples from three different brands of 
%   batteries were recorded with the following results:
%
%                   Lifetimes (in hours) of the batteries
%                  ---------------------------------------
%                                   Brand
%                  ---------------------------------------
%                     1               2               3
%                  ---------------------------------------
%                     40              60              60
%                     30              40              50
%                     50              55              70
%                     50              65              65
%                     30                              75
%                                                     40
%                  ---------------------------------------
%
%   We wish to test whether the three brands have same average lifetimes
%   or not after 2000 re-samplings and with a significance of 0.05.
%   
%   Input data:
%
%   X = [40 1;30 1;50 1;50 1;30 1;60 2;40 2;55 2;65 2;60 3;50 3;70 3;65 3;
%   75 3;40 3];
%
%   Calling on Matlab the function: 
%                bootanovagr(X,2000)
%
%   Answer is:
%
%   Summary statistics from the samples.
%   --------------------------------------------------
%    Sample       Size        Mean            Variance
%   --------------------------------------------------
%      1           5         40.0000          100.0000
%      2           4         55.0000          116.6667
%      3           6         60.0000          170.0000
%   --------------------------------------------------
% 
%   After 2000 resamplings and with a significance of 0.05
%   The assumption that sample means are equal was not met.
%
%   Graphical display
%
%   Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.edu.mx
%
%   Copyright (C)  June 13, 2011. 
%   
%   To cite this file, this would be an appropriate format:
%   Trujillo-Ortiz, A. and R. Hernandez-Walls. (2011). bootanovagr: 
%      Bootstrap Analysis of Variance Graphical Approach. [WWW document].
%      URL http://www.mathworks.com/matlabcentral/fileexchange/
%      31786-bootanovagr
%
%   References:
%   Efron, B. and Tibshirani, R. J. (1993), An Introduction to the Bootstrap
%              Chapman and Hall:New York.
%   Reddy, M. K., Kumar, B. N. and Ramu, Y. (2010), Bootstrap Method for 
%              Testing of Equality of Several Means. InterStat,
%              8(April):1-6. Published online at http://interstat.
%              statjournals.net/YEAR/2010/articles/1004008.pdf
%   Wehrens, R and Van der Linden, W. E. (1997), Bootstrapping Principal
%              Component Regression Models. Journal of Chemometrics, 
%              11:157–171.
%

if  nargin < 2,
    error('bootanovagr:TooFewInputs', ...
          'BOOTANOVAGR requires at least three input arguments.');
end

if nargin < 3 || isempty(alpha)
    alpha = 0.05; %default
elseif numel(alpha) ~= 1 || alpha <= 0 || alpha >= 1
    error('bootanovagr:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

X = x;

c = size(X,2);
if c ~= 2
    error('stats:bootanovagr:BadData','X must have two colums.');
end

%Remove NaN values, if any
X = X(~any(isnan(X),2),:);

k = max(X(:,2));

indice = X(:,2);
for i = 1:k
   Xe = indice ==i;
   d(i).X = X(Xe,1);
   d(i).m = mean(d(i).X);
   d(i).v = var(d(i).X);
   d(i).n = length(d(i).X);
end
m=cat(1,d.m);v=cat(1,d.v);n=cat(1,d.n);

disp(' ')
disp('Summary statistics from the samples.')
disp('--------------------------------------------------')
disp(' Sample       Size        Mean          Variance  ')
disp('--------------------------------------------------')
for i = 1:k
   fprintf('   %d           %i         %.4f          %.4f\n',i,n(i),m(i),v(i))
end
disp('--------------------------------------------------')
disp(' ')

n = sum(n);
z = X(:,1); %pooling of data (the order does not matter)
idx = ceil(rand(n,s)*n);
bootstrapdata = z(idx);
mbootd = mean(bootstrapdata); %means of each bootstrap sample
mboot = mean(mbootd); %mean of s-bootstrap estimates of mean

dboot = zeros(s,1);
for  b= 1:s
    dboot(b) = (mbootd(b) - mboot)^2;
end

S = sqrt(mean(dboot)); %standard deviation of s-bootstrap estimates of mean

LDL = mboot - norminv(1-alpha/2)*S; %lower decision line
UDL = mboot + norminv(1-alpha/2)*S; %upper decision line

plot((1:k),ones(1,k)*UDL,'r-',(1:k),ones(1,k)*LDL,'r--','LineWidth',2)
hold on
plot((1:k),m,'*b')
plot((1:k),ones(1,k)*mboot,'-k')
stem((1:k),m,'BaseValue',mboot)
xlabel('Sample');
ylabel('Bootstraping Means');
st1 = (['(alpha-level = ',num2str(alpha) ', ' 'UDL = ',...
    num2str(UDL) ', ' 'LDL = ',num2str(LDL) ', ' 'Resamplings = ',...
    num2str(s) ', ' 'Total size = ',num2str(n) ', ' 'Samples = ',num2str(k) ')']);
title({'Graphical procedure using bootstrap to test equality of means.',...
    ;'Null-hypothesis is rejected if any of the means lie ouside the decision lines.',...
    ;num2str(st1)},'FontSize',8);

if any (m > UDL),
    U = max(m);
    U = U+(U*0.02);
else
    U = UDL;
    U = U+(U*0.02);
end

if any (m < LDL),
    L = min(m);
    L = L-(L*0.02);
else
    L = LDL;
    L = L-(L*0.02);
end

if any  (m > UDL) || (m < LDL),
    disp('  ')
    fprintf('After %g resamplings and with a significance of %3.2f\n',s,alpha);
    fprintf('The assumption that sample means are equal was not met.\n');
end

axis([.8 k+.2 L U])

h = figure(gcf);
h2 = get(h,'CurrentAxes');
h4 = get(h2,'XTickLabel');
for k = 1:length(h4),
   if ~isempty(strfind(h4(k,:),'.')),
      h4(k,:) = ' ';
   end
end
set(h2,'XTickLabel',h4)

hold off

return,