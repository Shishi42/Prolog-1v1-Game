
%%%%%%%%%%%%%%%%% Visualisation %%%%%%%%%%%%%%%%%


%% afficheLigne(+List:list)
%
% Affiche les éléments de la liste
%
% @param list La liste à afficher
afficheLigne([]).
afficheLigne([A|AS]) :-
  write(A), tab(3),
  afficheLigne(AS).


% Predicat : afficheGrille/1
afficheGrille([]).
afficheGrille([A|AS]) :-
  afficheLigne(A), nl,
  afficheGrille(AS).


%%%%%%%%%%%%%%%%% Représentation %%%%%%%%%%%%%%%%%

caseVide(-).


sizeLine(S) :- size(S, _ ).
sizeColumn(S) :- size( _ , S).

init(SL, SC) :-
  retractall(size(_,_)),
  assert(size(SL, SC)),
  sizeLine(SL), sizeColumn(SC),
  retractall(succNum(_, _)),
  initSuccNum(1, SL),
  retractall(succAlpha(_, _)),
  retractall(equiv(_, _)),
  initSuccAlpha(a, SC),
  initEquiv(1, a, SC).

% Attention à la reduction de taille de grille
initSuccNum(D, S) :-  D < S, D1 is D + 1, assert(succNum(D, D1)), initSuccNum(D1, S).
initSuccNum(D, S) :-  D >= S.

% Attention à la reduction de taille de grille
initSuccAlpha(C, F) :- char_code(C, D), char_code(F, S),
                       D < S, D1 is D + 1,
                       char_code(C1, D1),
                       assert(succAlpha(C, C1)),
                       initSuccAlpha(C1, F).
initSuccAlpha(C, F) :- char_code(C, D), char_code(F, S),
                      D >= S.

initEquiv(D, C, F) :- char_code(C, DA), char_code(F, SA),
                         DA =< SA, D1 is D + 1, DA1 is DA + 1,
                         char_code(C1, DA1),
                         assert(equiv(C, D)), initEquiv(D1, C1, F).
initEquiv(_, C, F) :- char_code(C, DA), char_code(F, SA),
                         DA >= SA.



% Predicat : ligneDeGrille(NumLigne, Grille, Ligne).
% Satisfait si Ligne est la ligne numero NumLigne dans la Grille
ligneDeGrille(1, [Test |_], Test) :- !.
ligneDeGrille(NumLigne, [_|Reste],Test) :- succNum(I, NumLigne),
		ligneDeGrille(I,Reste,Test).

% Predicat : caseDeLigne(Col, Liste, Valeur).
% Satisfait si Valeur est dans la colonne Col de la Liste
caseDeLigne(a, [A|_],A) :- !.
caseDeLigne(Col, [_|Reste],Test) :- succAlpha(I, Col),caseDeLigne(I,Reste, Test).


% Predicat : caseDeGrille(NumCol, NumLigne, Grille, Case).
% Satisfait si Case est la case de la Grille en position NumCol-NumLigne
caseDeGrille(C,L,G, Elt) :- ligneDeGrille(L,G,Res),caseDeLigne(C,Res,Elt).


% Predicat : afficheCaseDeGrille(Colonne,Ligne,Grille) .
afficheCaseDeGrille(C,L,G) :- caseDeGrille(C,L,G,Case),write(Case).




%%%%%%%%%%%%%%%%% Coups autorisés %%%%%%%%%%%%%%%%%

% Predicat : leCoupEstValide/3
leCoupEstValide(C,L,G) :- caseVide(Cv), caseDeGrille(C,L,G,Cv).


% version recursive
coupJoueDansLigne(a, Val, [Cv|Reste],[Val|Reste]) :- caseVide(Cv), !.
coupJoueDansLigne(NomCol, Val, [X|Reste1],[X|Reste2]):-
		succAlpha(I,NomCol),
		coupJoueDansLigne(I, Val, Reste1, Reste2).


% Predicat : coupJoueDansGrille/5
coupJoueDansGrille(NCol,1,Val,[A|Reste],[B|Reste]):- coupJoueDansLigne(NCol, Val, A, B).
coupJoueDansGrille(NCol, NLig, Val, [X|Reste1], [X|Reste2]):- succNum(I, NLig),
					coupJoueDansGrille(NCol, I, Val, Reste1, Reste2).

%  ?- coupJoueDansGrille(a,2,x,[[-,-,x],[-,o,-],[x,o,o]],V).
%  V = [[-,-,x],[x,o,-],[x,o,o]] ;
%  no



%%%%%%%%%%%%%%%%% Moteur et règles %%%%%%%%%%%%%%%%%


% Predicat : ligneFaite/2
ligneFaite(Val, [Val]) :- !.
ligneFaite(Val, [Val|R]) :- ligneFaite(Val, R).


% Predicat : ligneGagnante/3
% ?- ligneGagnante(x,[[x,-,x],[x,x,x],[-,o,-]],V).
% V = 2 ;

ligneGagnante(Val, [L1|_]) :- ligneFaite(Val, L1), !.
ligneGagnante(Val, [_|R]) :- ligneGagnante(Val, R).



% Predicat : ligneFaite/2
colonneFaite(Val, [[Val|_]]) :- !.
colonneFaite(Val, [[Val|_]| R]) :- colonneFaite(Val, R).

% Predicat : colonneGagnante/3
colonneGagnante(Val, L) :- transpose(L, L1), ligneGagnante(Val, L1).


transpose([[]|_], []) :- !.
transpose(Matrix, [Row|Rows]) :- transpose_1st_col(Matrix, Row, RestMatrix),
                                 transpose(RestMatrix, Rows).
transpose_1st_col([], [], []).
transpose_1st_col([[H|T]|Rows], [H|Hs], [T|Ts]) :- transpose_1st_col(Rows, Hs, Ts).


% Predicats diagonaleDG/2 et diagonaleGD/2
diagonale([], 0, []).
diagonale([L|LS], N, [V|R]) :- diagonale(LS, N1, R), N is N1 + 1, nth1(N, L, V).

diagonaleGagnante(Val, L) :- diagonale(L, _, D), ligneFaite(Val, D).
diagonaleGagnante(Val, L) :- reverse(L, L1), diagonale(L1, _, D), ligneFaite(Val, D).


% Predicat partieGagnee/2
partieGagnee(Val, G) :- ligneGagnante(Val, G).
partieGagnee(Val, G) :- colonneGagnante(Val, G).
partieGagnee(Val, G) :- diagonaleGagnante(Val, G).







% coordonneesOuListe(NomCol, NumLigne, Liste).
% ?- coordonneesOuListe(a, 2, [a,2]). vrai.
coordonneesOuListe(NomCol, NumLigne, [NomCol, NumLigne]).


% duneListeALautre(LC1, Case, LC2)
% ?- duneListeALautre([[a,1],[a,2],[a,3]], [a,2], [[a,1],[a,3]]). est vrai
duneListeALautre([A|B], A, B).
duneListeALautre([A|B], C, [A|D]):- duneListeALautre(B,C,D).


% toutesLesCasesValides(Grille, LC1, C, LC2).
% Se verifie si l'on peut jouer dans la case C de Grille et que la liste
% LC1 est une liste composee de toutes les cases de LC2 et de C.
% Permet de dire si la case C est une case ou l'on peut jouer, en evitant
% de jouer deux fois dans la meme case.
toutesLesCasesValides(Grille, LC1, C, LC2) :-
	coordonneesOuListe(Col, Lig, C),
	leCoupEstValide(Col, Lig, Grille),
	duneListeALautre(LC1, C, LC2).

toutesLesCasesDepart(N) :- listeLigne(L), listeColonne(C), combine(C, L, N).

listeLigne2([NL], NL) :- sizeLine(NL), !.
listeLigne2([N|L], N) :- succNum(N, V), listeLigne2(L, V).

listeLigne(L) :- listeLigne2(L, 1).

listeColonne2([NL], NL) :- sizeColumn(NL), !.
listeColonne2([N|L], N) :- succAlpha(N, V), listeColonne2(L, V).

listeColonne(L) :- listeColonne2(L, a).



combine2([], _, []).
combine2([L|LS], V, [[L,V]|R]) :- combine2(LS, V, R).

combine(_, [], []).
combine(L1, [L2|L2S], RS) :- combine2(L1, L2, V), combine(L1, L2S, R), append(V, R, RS).

grilleDeDepart(G) :- size(SL, SCA), equiv(SCA, SC), replicate(-, SC, L), replicate(L, SL, G).

replicate(V, N, L) :- length(L, N), maplist(=(V), L).







%%%%%%%%%%%%%%%%% Joueur artificiel %%%%%%%%%%%%%%%%%

campCPU(x).


campAdverse(x,o).
campAdverse(o,x).

joueLeCoup(Case, Valeur, GrilleDep, GrilleArr) :-
	coordonneesOuListe(Col, Lig, Case),
	leCoupEstValide(Col, Lig, GrilleDep),
	coupJoueDansGrille(Col, Lig, Valeur, GrilleDep, GrilleArr),
	nl, afficheGrille(GrilleArr), nl.

saisieUnCoup(NomCol,NumLig) :-
	writeln("entrez le nom de la colonne a jouer (a,b,c) :"),
	read(NomCol), nl,
	writeln("entrez le numero de ligne a jouer (1, 2 ou 3) :"),
	read(NumLig),nl.

%saisieUnCoupValide(Col,Lig,Grille):-
%	saisieUnCoup(Col,Lig),
%	leCoupEstValide(Col,Lig,Grille),
%	writef('attention, vous ne pouvez pas jouer dans cette case'), nl,
%	writef('reessayer SVP dans une autre case'),nl,
%	saisieUnCoupValide(Col,Lig,Grille).


% Predicat : moteur/3
% Usage : moteur(Grille,ListeCoups,Camp) prend en parametre une grille dans
% laquelle tous les coups sont jouables et pour laquelle
% Camp doit jouer.


% cas gagnant pour le joueur
moteur(Grille,_,Camp):-
	partieGagnee(Camp, Grille), nl,
	write('le camp '), write(Camp), write(' a gagne').

% cas gagnant pour le joueur adverse
moteur(Grille,_,Camp):-
	campAdverse(CampGagnant, Camp),
	partieGagnee(CampGagnant, Grille), nl,
	write('le camp '), write(CampGagnant), write(' a gagne').

% cas de match nul, plus de coups jouables possibles
% TODO :: Système de point a regarder en fin de partie
moteur(_,[],_) :-nl, write('game over').

% cas ou l ordinateur doit jouer
moteur(Grille, [Premier|ListeCoupsNew], Camp) :-
	campCPU(Camp),
	joueLeCoup(Premier, Camp, Grille, GrilleArr),
	campAdverse(AutreCamp, Camp),
	moteur(GrilleArr, ListeCoupsNew, AutreCamp).

% cas ou c est l utilisateur qui joue
moteur(Grille, ListeCoups, Camp) :-
  campCPU(CPU),
  campAdverse(Camp, CPU),
  saisieUnCoup(Col,Lig),
  test(Col, Lig, Grille, Camp, CPU, ListeCoups).


% TODO :: Donner un vrai nom au prédicat
test(Col, Lig, Grille, Camp, CPU, ListeCoups) :-
  leCoupEstValide(Col, Lig, Grille),
  joueLeCoup([Col,Lig], Camp, Grille, GrilleArr),
  toutesLesCasesValides(Grille, ListeCoups, [Col, Lig], ListeCoupsNew),
  moteur(GrilleArr, ListeCoupsNew, CPU).


test(Col, Lig, Grille, Camp, _, ListeCoups) :-
  \+ leCoupEstValide(Col, Lig, Grille),
  write("Coup invalide"), nl,
	moteur(Grille, ListeCoups, Camp).



%% lanceJeu()
%  lanceJeu permet de lancer une partie de tic tac toe.
lanceJeu:-
  init(3, c),                          %spécifique
  grilleDeDepart(G),                   %spécifique
	toutesLesCasesDepart(ListeCoups),    %spécifique
	afficheGrille(G),nl,                 %général
   writeln("L ordinateur est les x et vous etes les o."),
   writeln("Quel camp doit debuter la partie ? "),read(Camp),
	moteur(G,ListeCoups,Camp).           %général
