function demo_nsb()
%DEMO_NSB Shows a comparitive example of the NSB method

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%

if isoctave
    warning(['Due to differences in the figure handling and plotting functions ' ...
        'between Matlab and Octave, this demo will not run in Octave. You may use ' ...
        'this file as a template for your own analyses.']);
	return;
end

%reset random number stream
stream = RandStream.getDefaultStream;
stream.reset;

beta = 1;
K = 2^8;
N = [round(0.5*sqrt(K)) round(sqrt(K)) round(2*sqrt(K)) K 2*K]';

%initialize variables
xi = inline('psi(K.*beta+1)-psi(beta+1)','K','beta'); %entropy of a Dirichlet distribution
hist1d = struct('P',num2cell(N),'C',[],'N',num2cell(ones(size(N))),'wordlist',[],'wordcnt',[],'entropy',[]);
optsA = struct('entropy_estimation_method',{{'plugin','tpmc'}},'variance_estimation_method',{{'boot'}},'boot_random_seed',1,'boot_num_samples',100,'possible_words',K);
optsB = struct('entropy_estimation_method',{{'nsb'}},'variance_estimation_method',{{'nsb_var'}},'nsb_precision',1e-6,'possible_words',K);
entropy = zeros(length(N),length(optsA.entropy_estimation_method)+length(optsB.entropy_estimation_method));
variance = zeros(length(N),length(optsA.entropy_estimation_method)+length(optsB.entropy_estimation_method));

%populate hist1d structure
for i=1:length(N)
	[n wordlist wordcnt p] = dirichlet_count(beta,K,N(i));
	hist1d(i).C = length(wordcnt);
	hist1d(i).wordlist = wordlist';
	hist1d(i).wordcnt = wordcnt';
end

%do computations
hist1d = entropy1d(hist1d,optsA);
temp = entropy1d(hist1d,optsB);

%get values
for i=1:length(hist1d)
	hist1d(i).entropy(end+1) = temp(i).entropy;
	for j=1:length(hist1d(i).entropy)
		entropy(i,j) = hist1d(i).entropy(j).value;
		variance(i,j) = hist1d(i).entropy(j).ve.value;
	end
end

%plot results
figure('Name','Comparison of Entropy Estimates');
errorbar(entropy,sqrt(variance));
hold on;
plot(xi(repmat(K,[length(N) 1]),beta)/log(2),'k--');
axis tight;
set(gca,'xtick',1:length(N),'xticklabel',N);
title(['Data from Dirichlet distribution with \beta=' num2str(beta) ' and K=' int2str(K)]);
xlabel('Total words observed');
ylabel('Entropy (bits)');
legend('plugin','tpmc','nsb');

function [n,wordlist,wordcnt,p] = dirichlet_count(beta,K,N)
%DIRICHLET_COUNT Creates NSB count vectors from a Dirichlet distribution
%   [n,wordlist,wordcnt,p]=dirichlet_count(beta,K,N) Uses parameter beta to
%   sample a Dirichlet distribution on K bins N times. The vector n are the
%   sample counts in each of K bins. Vector wordlist are the indices of occupied
%   bins in n, while vector wordcnt are the counts, in conformance with the
%   format for a hist1d structure. The vector p is the Dirichlet probability
%   vector.

p = dirichlet_sample(repmat(beta,[1 K]),1); %get probability vector

n = histc(rand([1 N]),[0 cumsum(p)]); %get sampled counts

wordlist = find(n); %which bins are occupied
wordcnt = n(wordlist); %what are the counts

function p = dirichlet_sample(beta,n)
%DIRICHLET_SAMPLE Sample from Dirichlet distribution.
%   p=dirichlet_sample(beta,n) returns n samples (default 1) of a probability
%   vector sampled from a Dirichlet distribution with parameter vector beta,
%   where each vector in the output matrix p has the same orientation as beta.

%This function was adapted from the identically named function in the FastFit
%toolbox: http://research.microsoft.com/en-us/um/people/minka/software/fastfit/

if nargin<2
  n = 1;
end

row = (size(beta,1) == 1); %determine orientation of beta vector

beta = beta(:);

q = gamrnd(repmat(beta,1,n),1); %get gamma random vector(s)
p = sum(q,1);
p(find(p==0)) = 1;
p = q./repmat(p,size(q,1),1); %transform to Dirichlet random

if row
  p = p'; %orient the output matrix
end
