function [norm,rawdp]=dotproduct(m1,m2)

%***************************************************************
%
%  DOTPRODUCT
%
%***************************************************************

rawdp=sum(m1(:).*m2(:));
norm=(sum(m1(:).*m1(:))*sum(m2(:).*m2(:)))^0.5;

