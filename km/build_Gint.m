function [G,Gg,R,N]=build_Gint
set_params
load(ts_paramfile)

ndates=length(dates);
nints=length(ints);

dn = [dates.dn];
dn = dn-dn(id);

i1=[ints.i1];
i2=[ints.i2];

G=zeros(nints,ndates);
for i=1:nints
    G(i,i1(i)) = -1;
    G(i,i2(i)) =  1;
end
G(end+1,id)=1; %master date has zero def.

%find un-resolved time periodsp=rank(G);
p       = rank(G);
[U,S,V] = svd(G);
Rm      = V(:,1:p)*inv(S(1:p,1:p))*U(:,1:p)'*U(:,1:p)*S(1:p,1:p)*V(:,1:p)'; %truncates resolution matrix
badid   = find(diag(Rm)<0.9); %thresholds should perhaps be set differently
goodid  = find(diag(Rm)>=0.9);

Gline   = dn(goodid)';
Ggline  = inv(Gline'*Gline)*Gline';
for j=1:length(badid)
    G(end+1,goodid)=Ggline*dn(badid(j));
    G(end,badid(j))=-1;
end

Gg = inv(G'*G)*G';
N  = G*Gg;
R  = Gg*G;

plotflag=1;
if(plotflag)
    res=diag(N);
    minres=min(res);
    maxres=max(res);
    dres=maxres-minres;
    
    figure
    c=colormap;
    dnpair=[dates(i1).dn;dates(i2).dn];
    bppair=[dates(i1).bp;dates(i2).bp];
    
    plot([dates.dn],[dates.bp],'k.')
    hold on
    for i=1:nints
        deltad=floor((res(i)-minres)/dres*63)+1;
        plot(dnpair(:,i),bppair(:,i),'-','Color',c(deltad,:))
        
    end
    grid on
    datetick
    print('-depsc','figs/baseline_R.eps');
end
