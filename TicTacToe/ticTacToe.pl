
/** <module> TicTacToe
 *
 *  Ce module permet de jouer au jeu de Tic-Tac-Toe
 *
 *  @author Mano Brabant
 */
:- module(jeu, []).


:- consult('../moteurJ2J/outils.pl').


%% ticTacToe()
%
%  Cette méthode permet de lancer une partie de tic tac toe.
initJeu() :-
  moteur:init(3, c).


%% leCoupEstValide(+Colonne:char, +Ligne:int, +Grille:Grille)
%
% Cette méthode permet de savoir si on peut jouer dans une case dans une grille donnée
%
% @param Colonne La colonne de la case à vérifier
% @param Ligne La ligne de la case à vérifier
% @param Grille La grille dans laquelle on vérifie la case
leCoupEstValide(C,L,G) :- moteur:caseVide(Cv), moteur:caseDeGrille(C,L,G,Cv).



%% leCoupEstValide(+Grille:Grille, +Case:Case)
%
% Cette méthode permet de savoir si on peut jouer dans une case dans une grille donnée
%
% @param Grille La grille dans laquelle on vérifié la case
% @param Case La case à vérifier
% @see [[leCoupEstValide/3]]
leCoupEstValide(G, CL) :- outils:coordonneesOuListe(Col, Lig, CL), leCoupEstValide(Col, Lig, G).



%% ligneFaite(+Val:char, +Ligne:list)
%
% Ce prédicat est satisfait si toutes les valeur de la liste sont les mêmes
%
% @param Val La valeur dans la liste
% @param Ligne La ligne à vérifier
ligneFaite(Val, [Val]).
ligneFaite(Val, [Val|R]) :- ligneFaite(Val, R).


%% ligneGagnante(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille contient une ligne gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
ligneGagnante(Val, [L1|_]) :- ligneFaite(Val, L1), !.
ligneGagnante(Val, [_|R]) :- ligneGagnante(Val, R).


%% colonneGagnante(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille contient une colonne gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
colonneGagnante(Val, L) :- outils:transpose(L, L1), ligneGagnante(Val, L1).


%% diagonale(+Grille:Grille, ?NbElement:int, +Ligne:Ligne)
%
% Cette méthode permet de récupérer une diagonale dans une grille donnée
%
% @param Grille La grille où l'on va récupérer une diagonale
% @param NbElemtn Le nombre d'éléments dans la diagonale
% @param Ligne La diagonale récupérée
diagonale([], 0, []).
diagonale([L|LS], N, [V|R]) :- diagonale(LS, N1, R), N is N1 + 1, nth1(N, L, V).


%% diagonaleGagnante(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille contient une diagonale gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
diagonaleGagnante(Val, L) :- 									diagonale(L, _, D), ligneFaite(Val, D).
diagonaleGagnante(Val, L) :- reverse(L, L1), 	diagonale(L1, _, D), ligneFaite(Val, D).



%% partieGagnee(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille est gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
partieGagnee(Val, G) :- ligneGagnante(Val, G).
partieGagnee(Val, G) :- colonneGagnante(Val, G).
partieGagnee(Val, G) :- diagonaleGagnante(Val, G).




grilleAvecLigneDeN(G, Val, N) :-                  diagonale(G, _, D), outils:ligneDeN(Val, D, N).
grilleAvecLigneDeN(G, Val, N) :- reverse(G, G1), 	diagonale(G1, _, D), outils:ligneDeN(Val, D, N).

grilleAvecLigneDeN(G, Val, N) :-                                            outils:lignesDeN(Val, G, N).
grilleAvecLigneDeN(G, Val, N) :-                  outils:transpose(G, G1),  outils:lignesDeN(Val, G1, N).
grilleAvecLigneDeN(G, Val, N) :- reverse(G, G1), 	                          outils:lignesDeN(Val, G1, N).
grilleAvecLigneDeN(G, Val, N) :- reverse(G, G1), 	outils:transpose(G1, G2), outils:lignesDeN(Val, G2, N).


%% toutesLesCasesDepart(?ListeCases:list)
%
% Cette méthode permet de récupérer toutes les cases de départ
%
% @param ListeCases La liste des cases où l'on peut jouer
toutesLesCasesDepart(N) :- listeLigne(L), listeColonne(C), outils:combine(C, L, N).


listeLigne2([NL], NL) :- moteur:sizeLine(NL), !.
listeLigne2([N|L], N) :- moteur:succNum(N, V), listeLigne2(L, V).

%% listeLigne(?Lignes:list)
%
% Cette méthode permet de récupérer toutes les lignes du jeu
%
% @param Lignes La liste des numéros de ligne
listeLigne(L) :- listeLigne2(L, 1).



listeColonne2([NL], NL) :- moteur:sizeColumn(NL), !.
listeColonne2([N|L], N) :- moteur:succAlpha(N, V), listeColonne2(L, V).

%% listeColonne(?Colonnes:list)
%
% Cette méthode permet de récupérer toutes les colonnes du jeu
%
% @param Colonnes La liste des noms de colonne
listeColonne(L) :- listeColonne2(L, a).

%% grilleDeDepart(?Grille:Grille)
%
% Cette méthode permet de récupérer la grille de départ du jeu
%
% @param Grille La grille de départ
grilleDeDepart(G) :- moteur:size(SL, SCA), moteur:equiv(SCA, SC),
	outils:replicate(-, SC, L), outils:replicate(L, SL, G).


terminal(G) :- toutesLesCasesValides(G, _, _, LC), length(LC, L), L == 0.
terminal(G) :- partieGagnee(x, G).
terminal(G) :- partieGagnee(o, G).

%eval(G, J, _) :- moteur:afficheGrille(G), nl, write(J), nl, fail.
eval(G, J, -1000) :- moteur:campAdverse(J, J1), partieGagnee(J1, G), !.
eval(G, J, 1000) :- partieGagnee(J, G), !.

eval(G, J, -100) :- moteur:campAdverse(J, J1), grilleAvecLigneDeN(G, J1, 2), grilleAvecLigneDeN(G, J, 2).
eval(G, J, -200) :- moteur:campAdverse(J, J1), grilleAvecLigneDeN(G, J1, 2).
eval(G, J, 200) :- grilleAvecLigneDeN(G, J, 2).

eval(_,_,5) :- !.

%% toutesLesCasesValides(+Grille:Grille, +ListeCoups:list, +Case:list, ?NouveauListeCoups:list)
%
% Cette méthode permet de récupérer touts les coups disponibles pour le prochain joueur
%
% @param Grille La grille dans laquelle on joue
% @param ListeCoups L'ancienne liste des coups
% @param Case La case ou l'on veut jouer
% @param NouveauListeCoups La nouvelle liste des coups
toutesLesCasesValides(Grille, _, _, LC2) :-
	listeLigne(L), listeColonne(C), outils:combine(C, L, N),
  include(leCoupEstValide(Grille), N, LC2).


%% saisieUnCoup(+Grille:Grille, ?NomColonne:char, ?NumLigne:int)
%
% Cette méthode permet de demander à l'utilisateur de saisir un coup
%
% @param Grille La grille dans laquelle le joueur va jouer son coup
% @param NomColonne Le nom de la colonne dans laquelle le joueur va jouer son coup
% @param NumLigne Le numéro de la ligne dans laquelle le joueur va jouer son coup
saisieUnCoup(_, NomCol,NumLig) :-
	writeln("entrez le nom de la colonne a jouer (a,b,c) :"),
	read(NomCol), nl,
	writeln("entrez le numero de ligne a jouer (1, 2 ou 3) :"),
	read(NumLig),nl.
