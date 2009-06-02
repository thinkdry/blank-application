//  Prototip 2.0.4 - 05-08-2008
//  Copyright (c) 2008 Nick Stakenburg (http://www.nickstakenburg.com)
//
//  Licensed under a Creative Commons Attribution-Noncommercial-No Derivative Works 3.0 Unported License
//  http://creativecommons.org/licenses/by-nc-nd/3.0/

//  More information on this project:
//  http://www.nickstakenburg.com/projects/prototip2/

var Prototip = {
  Version: '2.0.4'
};

var Tips = {
  options: {
    images: '../images/prototip/', // image path, can be relative to this file or an absolute url
    zIndex: 6000                   // raise if required
  }
};

Prototip.Styles = {
  // The default style every other style will inherit from.
  // Used when no style is set through the options on a tooltip.
  'default': {
    border: 1,
    borderColor: '#CCCCCC',
    className: 'default',
    closeButton: false,
    hideAfter: false,
    hideOn: '',
    hook: false,
	//images: 'styles/creamy/',    // Example: different images. An absolute url or relative to the images url defined above.
    radius: 6,
	showOn: 'mousemove',
    stem: {
      //position: 'topLeft',       // Example: optional default stem position, this will also enable the stem
      height: 12,
      width: 15
    }
  },

  'protoblue': {
    className: 'protoblue',
    border: 6,
    borderColor: '#116497',
    radius: 6,
    stem: { height: 12, width: 15 }
  },

  'darkgrey': {
    className: 'darkgrey',
    border: 6,
    borderColor: '#363636',
    radius: 6,
    stem: { height: 12, width: 15 }
  },

  'creamy': {
    className: 'creamy',
    border: 6,
    borderColor: '#ebe4b4',
    radius: 6,
    stem: { height: 12, width: 15 }
  },

  'protogrey': {
    className: 'protogrey',
    border: 6,
    borderColor: '#606060',
    radius: 6,
    stem: { height: 12, width: 15 }
  }
};

eval(function(p,a,c,k,e,r){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--)r[e(c)]=k[c]||e(c);k=[function(e){return r[e]}];e=function(){return'\\w+'};c=1};while(c--)if(k[c])p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c]);return p}('O.11(V,{5F:"1.6.0.2",3R:b(){3.3D("1Y");9(/^(6v?:\\/\\/|\\/)/.6d(c.8.W)){c.W=c.8.W}10{e A=/1Q(?:-[\\w\\d.]+)?\\.4D(.*)/;c.W=(($$("4z 4w[2c]").3v(b(B){N B.2c.2a(A)})||{}).2c||"").3j(A,"")+c.8.W}9(1Y.2r.3d&&!1a.3Y.v){1a.3Y.37("v","5B:5s-5n-5g:59");1a.1e("3I:33",b(){1a.4M().4G("v\\\\:*","4E: 30(#2Z#4B);")})}c.2o();q.1e(2U,"2T",3.2T)},3D:b(A){9((4u 2U[A]=="4q")||(3.2Q(2U[A].4l)<3.2Q(3["4k"+A]))){4i("V 6l "+A+" >= "+3["4k"+A]);}},2Q:b(A){e B=A.3j(/4f.*|\\./g,"");B=6b(B+"0".66(4-B.3f));N A.5S("4f")>-1?B-1:B},46:$w("44 5K"),24:b(A){9(1Y.2r.3d){N A}A=A.2t(b(G,F){e E=O.2z(3)?3:3.k,B=F.5A;5v{e D=E.2x,C=B.2x}5j(H){N}9(V.46.2F(E.2x.1Z())){9(B!=E&&!B.56(E)){G(F)}}10{9(B!=E&&!$A(E.2M("*")).2F(B)){G(F)}}});N A},3g:b(A){N(A>0)?(-1*A):(A).4X()},2T:b(){c.3G()}});O.11(c,{1H:[],18:[],2o:b(){3.2L=3.1r},1o:(b(A){N{1l:(A?"1V":"1l"),15:(A?"1J":"15"),1V:(A?"1V":"1l"),1J:(A?"1J":"15")}})(1Y.2r.3d),3B:{1l:"1l",15:"15",1V:"1l",1J:"15"},2e:{j:"2X",2X:"j",h:"1u",1u:"h",1U:"1U",1f:"1g",1g:"1f"},3y:{p:"1f",o:"1g"},3s:b(A){N!!28[1]?3.2e[A]:A},1j:(b(B){e A=r 4o("4n ([\\\\d.]+)").4m(B);N A?(3u(A[1])<7):Y})(6r.6p),3p:(1Y.2r.6k&&!1a.6i),37:b(A){3.1H.2K(A)},1G:b(A){e B=3.1H.3v(b(C){N C.k==$(A)});9(B){B.4e();9(B.1c){B.n.1G();9(c.1j){B.1p.1G()}}3.1H=3.1H.4c(B)}A.1Q=2i},3G:b(){3.1H.3h(b(A){3.1G(A.k)}.1i(3))},2I:b(C){9(C==3.49){N}9(3.18.3f===0){3.2L=3.8.1r;3e(e B=0,A=3.1H.3f;B<A;B++){3.1H[B].n.f({1r:3.8.1r})}}C.n.f({1r:3.2L++});9(C.T){C.T.f({1r:3.2L})}3.49=C},45:b(A){3.31(A);3.18.2K(A)},31:b(A){3.18=3.18.4c(A)},42:b(){c.18.1S("U")},X:b(B,F){B=$(B),F=$(F);e K=O.11({1d:{x:0,y:0},Q:Y},28[2]||{});e D=K.1x||F.2v();D.j+=K.1d.x;D.h+=K.1d.y;e C=K.1x?[0,0]:F.3T(),A=1a.1F.2A(),G=K.1x?"20":"1b";D.j+=(-1*(C[0]-A[0]));D.h+=(-1*(C[1]-A[1]));9(K.1x){e E=[0,0];E.p=0;E.o=0}e I={k:B.21()},J={k:O.2h(D)};I[G]=K.1x?E:F.21();J[G]=O.2h(D);3e(e H 3P J){3M(K[H]){S"5p":S"5o":J[H].j+=I[H].p;19;S"5k":J[H].j+=(I[H].p/2);19;S"5i":J[H].j+=I[H].p;J[H].h+=(I[H].o/2);19;S"5h":S"5f":J[H].h+=I[H].o;19;S"5d":S"5c":J[H].j+=I[H].p;J[H].h+=I[H].o;19;S"5a":J[H].j+=(I[H].p/2);J[H].h+=I[H].o;19;S"58":J[H].h+=(I[H].o/2);19}}D.j+=-1*(J.k.j-J[G].j);D.h+=-1*(J.k.h-J[G].h);9(K.Q){B.f({j:D.j+"i",h:D.h+"i"})}N D}});c.2o();e 55=54.3J({2o:b(C,E){3.k=$(C);9(!3.k){4i("V: q 53 51, 4Y 3J a 1c.");N}c.1G(3.k);e A=(O.2s(E)||O.2z(E)),B=A?28[2]||[]:E;3.1s=A?E:2i;9(B.1T){B=O.11(O.2h(V.3q[B.1T]),B)}3.8=O.11(O.11({1m:Y,1h:0,3o:"#4L",1n:0,u:c.8.u,13:c.8.4F,1v:!(B.17&&B.17=="1W")?0.14:Y,1A:Y,1K:"1J",3C:Y,X:B.X,1d:B.X?{x:0,y:0}:{x:16,y:16},1I:(B.X&&!B.X.1x)?1k:Y,17:"2p",m:Y,1T:"2Z",1b:3.k,12:Y,1F:(B.X&&!B.X.1x)?Y:1k,p:Y},V.3q["2Z"]),B);3.1b=$(3.8.1b);3.1n=3.8.1n;3.1h=(3.1n>3.8.1h)?3.1n:3.8.1h;9(3.8.W){3.W=3.8.W.2Y("://")?3.8.W:c.W+3.8.W}10{3.W=c.W+"4C/"+(3.8.1T||"")+"/"}9(!3.W.4A("/")){3.W+="/"}9(O.2s(3.8.m)){3.8.m={Q:3.8.m}}9(3.8.m.Q){3.8.m=O.11(O.2h(V.3q[3.8.1T].m)||{},3.8.m);3.8.m.Q=[3.8.m.Q.2a(/[a-z]+/)[0].1Z(),3.8.m.Q.2a(/[A-Z][a-z]+/)[0].1Z()];3.8.m.1C=["j","2X"].2F(3.8.m.Q[0])?"1f":"1g";3.1t={1f:Y,1g:Y}}9(3.8.1m){3.8.1m.8=O.11({2V:1Y.4y},3.8.1m.8||{})}3.1o=$w("4x 44").2F(3.k.2x.1Z())?c.3B:c.1o;9(3.8.X.1x){e D=3.8.X.1q.2a(/[a-z]+/)[0].1Z();3.20=c.2e[D]+c.2e[3.8.X.1q.2a(/[A-Z][a-z]+/)[0].1Z()].2n()}3.3A=(c.3p&&3.1n);3.3z();c.37(3);3.3x();V.11(3)},3z:b(){3.n=r q("R",{u:"1Q"}).f({1r:c.8.1r});9(3.3A){3.n.U=b(){3.f("j:-3w;h:-3w;1N:2m;");N 3};3.n.P=b(){3.f("1N:18");N 3};3.n.18=b(){N(3.2S("1N")=="18"&&3u(3.2S("h").3j("i",""))>-4v)}}3.n.U();9(c.1j){3.1p=r q("4t",{u:"1p",2c:"4s:Y;",4r:0}).f({2l:"2b",1r:c.8.1r-1,4p:0})}9(3.8.1m){3.23=3.23.2t(3.2R)}3.1q=r q("R",{u:"1s"});3.12=r q("R",{u:"12"}).U();9(3.8.13||(3.8.1K.k&&3.8.1K.k=="13")){3.13=r q("R",{u:"2k"}).26(3.W+"2k.2j")}},2G:b(){9(1a.33){3.2P();3.3t=1k;N 1k}10{9(!3.3t){1a.1e("3I:33",3.2P);N Y}}},2P:b(){$(1a.2O).s(3.n);9(c.1j){$(1a.2O).s(3.1p)}9(3.8.1m){$(1a.2O).s(3.T=r q("R",{u:"6u"}).26(3.W+"T.6t").U())}e G="n";9(3.8.m.Q){3.m=r q("R",{u:"6q"}).f({o:3.8.m[3.8.m.1C=="1g"?"o":"p"]+"i"});e B=3.8.m.1C=="1f";3[G].s(3.3r=r q("R",{u:"6n 2N"}).s(3.4h=r q("R",{u:"6m 2N"})));3.m.s(3.1R=r q("R",{u:"6j"}).f({o:3.8.m[B?"p":"o"]+"i",p:3.8.m[B?"o":"p"]+"i"}));9(c.1j&&!3.8.m.Q[1].4g().2Y("6h")){3.1R.f({2l:"6f"})}G="4h"}9(3.1h){e D=3.1h,F;3[G].s(3.27=r q("6e",{u:"27"}).s(3.25=r q("3m",{u:"25 3l"}).f("o: "+D+"i").s(r q("R",{u:"2J 6c"}).s(r q("R",{u:"29"}))).s(F=r q("R",{u:"6a"}).f({o:D+"i"}).s(r q("R",{u:"4d"}).f({1y:"0 "+D+"i",o:D+"i"}))).s(r q("R",{u:"2J 65"}).s(r q("R",{u:"29"})))).s(3.2W=r q("3m",{u:"2W 3l"}).s(3.3i=r q("R",{u:"3i"}).f("2q: 0 "+D+"i"))).s(3.4b=r q("3m",{u:"4b 3l"}).f("o: "+D+"i").s(r q("R",{u:"2J 64"}).s(r q("R",{u:"29"}))).s(F.63(1k)).s(r q("R",{u:"2J 62"}).s(r q("R",{u:"29"})))));G="3i";e C=3.27.2M(".29");$w("5Z 5Y 5X 5W").3h(b(I,H){9(3.1n>0){V.48(C[H],I,{1L:3.8.3o,1h:D,1n:3.8.1n})}10{C[H].2H("47")}C[H].f({p:D+"i",o:D+"i"}).2H("29"+I.2n())}.1i(3));3.27.2M(".4d",".2W",".47").1S("f",{1L:3.8.3o})}3[G].s(3.1c=r q("R",{u:"1c "+3.8.u}).s(3.1X=r q("R",{u:"1X"}).s(3.12)));9(3.8.p){e E=3.8.p;9(O.5O(E)){E+="i"}3.1c.f("p:"+E)}9(3.m){e A={};A[3.8.m.1C=="1f"?"h":"1u"]=3.m;3.n.s(A);3.2f()}3.1c.s(3.1q);9(!3.8.1m){3.3c({12:3.8.12,1s:3.1s})}},3c:b(E){e A=3.n.2S("1N");3.n.f("o:1M;p:1M;1N:2m").P();9(3.1h){3.25.f("o:0");3.25.f("o:0")}9(E.12){3.12.P().43(E.12);3.1X.P()}10{9(!3.13){3.12.U();3.1X.U()}}9(O.2z(E.1s)){E.1s.P()}9(O.2s(E.1s)||O.2z(E.1s)){3.1q.43(E.1s)}3.1c.f({p:3.1c.3F()+"i"});3.n.f("1N:18").P();3.1c.P();e C=3.1c.21(),B={p:C.p+"i"},D=[3.n];9(c.1j){D.2K(3.1p)}9(3.13){3.12.P().s({h:3.13});3.1X.P()}9(E.12||3.13){3.1X.f("p: 34%")}B.o=2i;3.n.f({1N:A});3.1q.2H("2N");9(E.12||3.13){3.12.2H("2N")}9(3.1h){3.25.f("o:"+3.1h+"i");3.25.f("o:"+3.1h+"i");B="p: "+(C.p+2*3.1h)+"i";D.2K(3.27)}D.1S("f",B);9(3.m){3.2f();9(3.8.m.1C=="1f"){3.n.f({p:3.n.3F()+3.8.m.o+"i"})}}3.n.U()},3x:b(){3.3b=3.23.1z(3);3.41=3.U.1z(3);9(3.8.1I&&3.8.17=="2p"){3.8.17="1l"}9(3.8.17==3.8.1K){3.1P=3.40.1z(3);3.k.1e(3.8.17,3.1P)}9(3.13){3.13.1e("1l",b(E){E.26(3.W+"5J.2j")}.1i(3,3.13)).1e("15",b(E){E.26(3.W+"2k.2j")}.1i(3,3.13))}e C={k:3.1P?[]:[3.k],1b:3.1P?[]:[3.1b],1q:3.1P?[]:[3.n],13:[],2b:[]},A=3.8.1K.k;3.3a=A||(!3.8.1K?"2b":"k");3.1O=C[3.3a];9(!3.1O&&A&&O.2s(A)){3.1O=3.1q.2M(A)}e D={1V:"1l",1J:"15"};$w("P U").3h(b(H){e G=H.2n(),F=(3.8[H+"3X"].35||3.8[H+"3X"]);3[H+"3W"]=F;9(["1V","1J","1l","15"].2Y(F)){3[H+"3W"]=(3.1o[F]||F);3["35"+G]=V.24(3["35"+G])}}.1i(3));9(!3.1P){3.k.1e(3.8.17,3.3b)}9(3.1O){3.1O.1S("1e",3.5I,3.41)}9(!3.8.1I&&3.8.17=="1W"){3.2u=3.Q.1z(3);3.k.1e("2p",3.2u)}3.3V=3.U.2t(b(G,F){e E=F.5H(".2k");9(E){E.5G();F.5E();G(F)}}).1z(3);9(3.13){3.n.1e("1W",3.3V)}9(3.8.17!="1W"&&(3.3a!="k")){3.2D=V.24(b(){3.1E("P")}).1z(3);3.k.1e(3.1o.15,3.2D)}e B=[3.k,3.n];3.39=V.24(b(){c.2I(3);3.2C()}).1z(3);3.38=V.24(3.1A).1z(3);B.1S("1e",3.1o.1l,3.39).1S("1e",3.1o.15,3.38);9(3.8.1m&&3.8.17!="1W"){3.2B=V.24(3.3S).1z(3);3.k.1e(3.1o.15,3.2B)}},4e:b(){9(3.8.17==3.8.1K){3.k.1w(3.8.17,3.1P)}10{3.k.1w(3.8.17,3.3b);9(3.1O){3.1O.1S("1w")}}9(3.2u){3.k.1w("2p",3.2u)}9(3.2D){3.k.1w("15",3.2D)}3.n.1w();3.k.1w(3.1o.1l,3.39).1w(3.1o.15,3.38);9(3.2B){3.k.1w(3.1o.15,3.2B)}},2R:b(C,B){9(!3.1c){9(!3.2G()){N}}3.Q(B);9(3.2w){N}10{9(3.3Q){C(B);N}}3.2w=1k;e D={2g:{1D:22.1D(B),1B:22.1B(B)}};e A=O.2h(3.8.1m.8);A.2V=A.2V.2t(b(F,E){3.3c({12:3.8.12,1s:E.5C});3.Q(D);(b(){F(E);e G=(3.T&&3.T.18());9(3.T){3.1E("T");3.T.1G();3.T=2i}9(G){3.P()}3.3Q=1k;3.2w=2i}.1i(3)).1v(0.6)}.1i(3));3.5z=q.P.1v(3.8.1v,3.T);3.n.U();3.2w=1k;3.T.P();3.5y=(b(){r 5x.5w(3.8.1m.30,A)}.1i(3)).1v(3.8.1v);N Y},3S:b(){3.1E("T")},23:b(A){9(!3.1c){9(!3.2G()){N}}3.Q(A);9(3.n.18()){N}3.1E("P");3.5u=3.P.1i(3).1v(3.8.1v)},1E:b(A){9(3[A+"3N"]){5t(3[A+"3N"])}},P:b(){9(3.n.18()){N}9(c.1j){3.1p.P()}9(3.8.3C){c.42()}c.45(3);3.1c.P();3.n.P();9(3.m){3.m.P()}3.k.3O("1Q:5r")},1A:b(A){9(3.8.1m){9(3.T&&3.8.17!="1W"){3.T.U()}}9(!3.8.1A){N}3.2C();3.5q=3.U.1i(3).1v(3.8.1A)},2C:b(){9(3.8.1A){3.1E("1A")}},U:b(){3.1E("P");3.1E("T");9(!3.n.18()){N}3.3L()},3L:b(){9(c.1j){3.1p.U()}9(3.T){3.T.U()}3.n.U();(3.27||3.1c).P();c.31(3);3.k.3O("1Q:2m")},40:b(A){9(3.n&&3.n.18()){3.U(A)}10{3.23(A)}},2f:b(){e C=3.8.m,B=28[0]||3.1t,D=c.3s(C.Q[0],B[C.1C]),F=c.3s(C.Q[1],B[c.2e[C.1C]]),A=3.1n||0;3.1R.26(3.W+D+F+".2j");9(C.1C=="1f"){e E=(D=="j")?C.o:0;3.3r.f("j: "+E+"i;");3.1R.f({"2y":D});3.m.f({j:0,h:(F=="1u"?"34%":F=="1U"?"50%":0),5D:(F=="1u"?-1*C.p:F=="1U"?-0.5*C.p:0)+(F=="1u"?-1*A:F=="h"?A:0)+"i"})}10{3.3r.f(D=="h"?"1y: 0; 2q: "+C.o+"i 0 0 0;":"2q: 0; 1y: 0 0 "+C.o+"i 0;");3.m.f(D=="h"?"h: 0; 1u: 1M;":"h: 1M; 1u: 0;");3.1R.f({1y:0,"2y":F!="1U"?F:"2b"});9(F=="1U"){3.1R.f("1y: 0 1M;")}10{3.1R.f("1y-"+F+": "+A+"i;")}9(c.3p){9(D=="1u"){3.m.f({Q:"3U",5m:"5l",h:"1M",1u:"1M","2y":"j",p:"34%",1y:(-1*C.o)+"i 0 0 0"});3.m.1T.2l="3K"}10{3.m.f({Q:"3Z","2y":"2b",1y:0})}}}3.1t=B},Q:b(B){9(!3.1c){9(!3.2G()){N}}c.2I(3);9(c.1j){e A=3.n.21();9(!3.2E||3.2E.o!=A.o||3.2E.p!=A.p){3.1p.f({p:A.p+"i",o:A.o+"i"})}3.2E=A}9(3.8.X){e J,H;9(3.20){e K=1a.1F.2A(),C=B.2g||{};e G,I=2;3M(3.20.4g()){S"5L":S"5M":G={x:0-I,y:0-I};19;S"5N":G={x:0,y:0-I};19;S"5e":S"5P":G={x:I,y:0-I};19;S"5Q":G={x:I,y:0};19;S"5R":S"5b":G={x:I,y:I};19;S"5T":G={x:0,y:I};19;S"5U":S"5V":G={x:0-I,y:I};19;S"57":G={x:0-I,y:0};19}G.x+=3.8.1d.x;G.y+=3.8.1d.y;J=O.11({1d:G},{k:3.8.X.1q,20:3.20,1x:{h:C.1B||22.1B(B)-K.h,j:C.1D||22.1D(B)-K.j}});H=c.X(3.n,3.1b,J);9(3.8.1F){e M=3.36(H),L=M.1t;H=M.Q;H.j+=L.1g?2*V.3g(G.x-3.8.1d.x):0;H.h+=L.1g?2*V.3g(G.y-3.8.1d.y):0;9(3.m&&(3.1t.1f!=L.1f||3.1t.1g!=L.1g)){3.2f(L)}}H={j:H.j+"i",h:H.h+"i"};3.n.f(H)}10{J=O.11({1d:3.8.1d},{k:3.8.X.1q,1b:3.8.X.1b});H=c.X(3.n,3.1b,O.11({Q:1k},J));H={j:H.j+"i",h:H.h+"i"}}9(3.T){e E=c.X(3.T,3.1b,O.11({Q:1k},J))}9(c.1j){3.1p.f(H)}}10{e F=3.1b.2v(),C=B.2g||{},H={j:((3.8.1I)?F[0]:C.1D||22.1D(B))+3.8.1d.x,h:((3.8.1I)?F[1]:C.1B||22.1B(B))+3.8.1d.y};9(!3.8.1I&&3.k!==3.1b){e D=3.k.2v();H.j+=-1*(D[0]-F[0]);H.h+=-1*(D[1]-F[1])}9(!3.8.1I&&3.8.1F){e M=3.36(H),L=M.1t;H=M.Q;9(3.m&&(3.1t.1f!=L.1f||3.1t.1g!=L.1g)){3.2f(L)}}H={j:H.j+"i",h:H.h+"i"};3.n.f(H);9(3.T){3.T.f(H)}9(c.1j){3.1p.f(H)}}},36:b(C){e E={1f:Y,1g:Y},D=3.n.21(),B=1a.1F.2A(),A=1a.1F.21(),G={j:"p",h:"o"};3e(e F 3P G){9((C[F]+D[G[F]]-B[F])>A[G[F]]){C[F]=C[F]-(D[G[F]]+(2*3.8.1d[F=="j"?"x":"y"]));9(3.m){E[c.3y[G[F]]]=1k}}}N{Q:C,1t:E}}});O.11(V,{48:b(G,H){e F=28[2]||3.8,B=F.1n,E=F.1h,D=r q("60",{u:"61"+H.2n(),p:E+"i",o:E+"i"}),A={h:(H.4a(0)=="t"),j:(H.4a(1)=="l")};9(D&&D.3k&&D.3k("2d")){G.s(D);e C=D.3k("2d");C.52=F.1L;C.4Z((A.j?B:E-B),(A.h?B:E-B),B,0,67.68*2,1k);C.69();C.3H((A.j?B:0),0,E-B,E);C.3H(0,(A.h?B:0),E,E-B)}10{G.s(r q("R").f({p:E+"i",o:E+"i",1y:0,2q:0,2l:"3K",Q:"3U",4W:"2m"}).s(r q("v:4V",{4U:F.1L,4T:"4S",4R:F.1L,6g:(B/E*0.5).4Q(2)}).f({p:2*E-1+"i",o:2*E-1+"i",Q:"3Z",j:(A.j?0:(-1*E))+"i",h:(A.h?0:(-1*E))+"i"})))}}});q.4P({26:b(C,B){C=$(C);e A=O.11({3E:"h j",3n:"4O-3n",32:"4N",1L:""},28[2]||{});C.f(c.1j?{6o:"4K:4J.4I.6s(2c=\'"+B+"\'\', 32=\'"+A.32+"\')"}:{4H:A.1L+" 30("+B+") "+A.3E+" "+A.3n});N C}});V.4j={P:b(){c.2I(3);3.2C();e D={};9(3.8.X){D.2g={1D:0,1B:0}}10{e A=3.1b.2v(),C=3.1b.3T(),B=1a.1F.2A();A.j+=(-1*(C[0]-B[0]));A.h+=(-1*(C[1]-B[1]));D.2g={1D:A.j,1B:A.h}}9(3.8.1m){3.2R(D)}10{3.23(D)}3.1A()}};V.11=b(A){A.k.1Q={};O.11(A.k.1Q,{P:V.4j.P.1i(A),U:A.U.1i(A),1G:c.1G.1i(c,A.k)})};V.3R();',62,404,'|||this|||||options|if||function|Tips||var|setStyle||top|px|left|element||stem|wrapper|height|width|Element|new|insert||className|||||||||||||||||||return|Object|show|position|div|case|loader|hide|Prototip|images|hook|false||else|extend|title|closeButton||mouseout||showOn|visible|break|document|target|tooltip|offset|observe|horizontal|vertical|border|bind|fixIE|true|mouseover|ajax|radius|useEvent|iframeShim|tip|zIndex|content|stemInverse|bottom|delay|stopObserving|mouse|margin|bindAsEventListener|hideAfter|pointerY|orientation|pointerX|clearTimer|viewport|remove|tips|fixed|mouseleave|hideOn|backgroundColor|auto|visibility|hideTargets|eventToggle|prototip|stemImage|invoke|style|middle|mouseenter|click|toolbar|Prototype|toLowerCase|mouseHook|getDimensions|Event|showDelayed|capture|borderTop|setPngBackground|borderFrame|arguments|prototip_Corner|match|none|src||_inverse|positionStem|fakePointer|clone|null|png|close|display|hidden|capitalize|initialize|mousemove|padding|Browser|isString|wrap|eventPosition|cumulativeOffset|ajaxContentLoading|tagName|float|isElement|getScrollOffsets|ajaxHideEvent|cancelHideAfter|eventCheckDelay|iframeShimDimensions|member|build|addClassName|raise|prototip_CornerWrapper|push|zIndexTop|select|clearfix|body|_build|convertVersionString|ajaxShow|getStyle|unload|window|onComplete|borderMiddle|right|include|default|url|removeVisible|sizingMethod|loaded|100|event|getPositionWithinViewport|add|activityLeave|activityEnter|hideElement|eventShow|_update|IE|for|length|toggleInt|each|borderCenter|replace|getContext|borderRow|li|repeat|borderColor|WebKit419|Styles|stemWrapper|inverseStem|_isBuilding|parseFloat|find|9500px|activate|_stemTranslation|setup|fixSafari2|specialEvent|hideOthers|require|align|getWidth|removeAll|fillRect|dom|create|block|afterHide|switch|Timer|fire|in|ajaxContentLoaded|start|ajaxHide|cumulativeScrollOffset|relative|buttonEvent|Action|On|namespaces|absolute|toggle|eventHide|hideAll|update|input|addVisibile|_captureTroubleElements|prototip_Fill|createCorner|_highest|charAt|borderBottom|without|prototip_Between|deactivate|_|toUpperCase|stemBox|throw|Methods|REQUIRED_|Version|exec|MSIE|RegExp|opacity|undefined|frameBorder|javascript|iframe|typeof|9500|script|area|emptyFunction|head|endsWith|VML|styles|js|behavior|closeButtons|addRule|background|Microsoft|DXImageTransform|progid|000000|createStyleSheet|scale|no|addMethods|toFixed|strokeColor|1px|strokeWeight|fillcolor|roundrect|overflow|abs|cannot|arc||available|fillStyle|not|Class|Tip|descendantOf|LEFTMIDDLE|leftMiddle|vml|bottomMiddle|BOTTOMRIGHT|rightBottom|bottomRight|TOPRIGHT|leftBottom|com|bottomLeft|rightMiddle|catch|topMiddle|both|clear|microsoft|rightTop|topRight|hideAfterTimer|shown|schemas|clearTimeout|showTimer|try|Request|Ajax|ajaxTimer|loaderTimer|relatedTarget|urn|responseText|marginTop|stop|REQUIRED_Prototype|blur|findElement|hideAction|close_hover|textarea|LEFTTOP|TOPLEFT|TOPMIDDLE|isNumber|RIGHTTOP|RIGHTMIDDLE|RIGHTBOTTOM|indexOf|BOTTOMMIDDLE|BOTTOMLEFT|LEFTBOTTOM|br|bl|tr|tl|canvas|cornerCanvas|prototip_CornerWrapperBottomRight|cloneNode|prototip_CornerWrapperBottomLeft|prototip_CornerWrapperTopRight|times|Math|PI|fill|prototip_BetweenCorners|parseInt|prototip_CornerWrapperTopLeft|test|ul|inline|arcSize|MIDDLE|evaluate|prototip_StemImage|WebKit|requires|prototip_StemBox|prototip_StemWrapper|filter|userAgent|prototip_Stem|navigator|AlphaImageLoader|gif|prototipLoader|https'.split('|'),0,{}));


function newTip(elementId){
	new Tip('elementId', 'je devrait voir des trucs ecris', 
			{ title: 'Informations',  
			  className: 'pinktip',
			  effect: 'appear',
			  duration: 0.2,
			  hook: { target: 'bottomMiddle', tip: 'topRight' },
			  hideAfter: { element: '.close', event: 'click'}
			});
}
