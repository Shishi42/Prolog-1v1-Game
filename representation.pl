consult('yolo.pl').

gLin2([G|_], D, D, G) :- !.
gLin2([_|GS], D, Y, P) :- succNum(D, D1), gLin2(GS, D1, Y, P).

gLin(G, Y, P) :- gLin2(G, 1, Y, P).

gPos2([G|_], D, D, Y, P) :- gLin(G, Y, P), !.
gPos2([_|GS], D, X, Y, P) :- succAlpha(D, D1), gPos2(GS, D1, X, Y, P).

gPos(G, X, Y, P) :- gPos2(G, a, X, Y, P).

dim([G|GS], W, H) :- length([G|GS], W), length(G, H).

grilleDeDepart(G) :- dim(G, 3, 3),
gPos(G, 1, 1, '-'), gPos(G, 1, 2, '-'), gPos(G, 1, 3, '-'),
gPos(G, 2, 1, '-'), gPos(G, 2, 2, '-'), gPos(G, 2, 3, '-'),
gPos(G, 3, 1, '-'), gPos(G, 3, 2, '-'), gPos(G, 3, 3, '-').


/*
gPos(G, a, 1, '-'), gPos(G, a, 2, '-'), gPos(G, a, 3, '-'),
gPos(G, b, 1, '-'), gPos(G, b, 2, '-'), gPos(G, b, 3, '-'),
gPos(G, c, 1, '-'), gPos(G, c, 2, '-'), gPos(G, c, 3, '-').
*/
