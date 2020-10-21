succNum(1,2).
succNum(2,3).
succNum(3,4).
succNum(4,5).
succNum(5,6).
succNum(6,7).
succNum(7,8).

succAlpha(a,b).
succAlpha(b,c).
succAlpha(c,d).
succAlpha(d,e).
succAlpha(e,f).
succAlpha(f,g).
succAlpha(g,h).

afficheLigne([]).
afficheLigne([X|L]) :- write(X), write(' '), afficheLigne(L).

afficheGrille([]).
afficheGrille([X|L]) :- afficheLigne(X), write_ln(''), afficheGrille(L).

caseDansLigne(1, [V|_], V) :- !.
caseDansLigne(C, [_|TS], V) :- C > 1, C1 is C-1, caseDansLigne(C1, TS, V).

ligneDansGrille(L, T, V) :- caseDansLigne(L, T, V).
