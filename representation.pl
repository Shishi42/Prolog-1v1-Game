:- consult('yolo.pl').

gLin2([G|_], D, D, G) :- !.
gLin2([_|GS], D, Y, P) :- succNum(D, D1), gLin2(GS, D1, Y, P).

gLin(G, Y, P) :- gLin2(G, 1, Y, P).

gPos2([G|_], D, D, Y, P) :- gLin(G, Y, P), !.
gPos2([_|GS], D, X, Y, P) :- succAlpha(D, D1), gPos2(GS, D1, X, Y, P).

donneValeurCase(G, X, Y, P) :- gPos2(G, a, X, Y, P).

dim([G|GS], W, H) :- length([G|GS], W), length(G, H).

grilleDeDepart(G) :- dim(G, 3, 3),
donneValeurCase(G, a, 1, '-'), donneValeurCase(G, a, 2, '-'), donneValeurCase(G, a, 3, '-'),
donneValeurCase(G, b, 1, '-'), donneValeurCase(G, b, 2, '-'), donneValeurCase(G, b, 3, '-'),
donneValeurCase(G, c, 1, '-'), donneValeurCase(G, c, 2, '-'), donneValeurCase(G, c, 3, '-').


caseVide(G, X, Y) :- \+ donneValeurCase(G, X, Y, _).
