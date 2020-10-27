
replicate(V, N, L) :- length(L, N), maplist(=(V), L).


combine2([], _, []).
combine2([L|LS], V, [[L,V]|R]) :- combine2(LS, V, R).

combine(_, [], []).
combine(L1, [L2|L2S], RS) :- combine2(L1, L2, V), combine(L1, L2S, R), append(V, R, RS).


transpose([[]|_], []) :- !.
transpose(Matrix, [Row|Rows]) :- transpose_1st_col(Matrix, Row, RestMatrix),
                                 transpose(RestMatrix, Rows).
transpose_1st_col([], [], []).
transpose_1st_col([[H|T]|Rows], [H|Hs], [T|Ts]) :- transpose_1st_col(Rows, Hs, Ts).





% coordonneesOuListe(NomCol, NumLigne, Liste).
% ?- coordonneesOuListe(a, 2, [a,2]). vrai.
coordonneesOuListe(NomCol, NumLigne, [NomCol, NumLigne]).


% duneListeALautre(LC1, Case, LC2)
% ?- duneListeALautre([[a,1],[a,2],[a,3]], [a,2], [[a,1],[a,3]]). est vrai
duneListeALautre([A|B], A, B).
duneListeALautre([A|B], C, [A|D]):- duneListeALautre(B,C,D).
