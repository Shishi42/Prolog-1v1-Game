
:- module(ticTacToe, [ticTacToe/0]).

:- consult('../moteurJ2J/moteur.pl'), consult('../moteurJ2J/outils.pl').



%% leCoupEstValide(+Colonne:char, +Ligne:int, +Grille:Grille)
%
% Cette méthode permet de savoir si une case est valide dans une grille donnée
%
% @param Colonne La colonne de la case à vérifier
% @param Ligne La ligne de la case à vérifier
% @param Grille La grille dans laquelle on vérifie la case
leCoupEstValide(C,L,G) :- caseVide(Cv), caseDeGrille(C,L,G,Cv).



% Predicat : leCoupEstValide/2
leCoupEstValide(G, CL) :- 	coordonneesOuListe(Col, Lig, CL), leCoupEstValide(Col, Lig, G).



%% ligneFaite(+Val:char, +Ligne:Ligne)
%
% Cette méthode permet de savoir si une ligne contient uniquement une valeur donnée
%
% @param Val La valeur à vérifier
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
colonneGagnante(Val, L) :- transpose(L, L1), ligneGagnante(Val, L1).


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
diagonaleGagnante(Val, L) :- diagonale(L, _, D), ligneFaite(Val, D).
diagonaleGagnante(Val, L) :- reverse(L, L1), diagonale(L1, _, D), ligneFaite(Val, D).



%% partieGagnee(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille est gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
partieGagnee(Val, G) :- ligneGagnante(Val, G).
partieGagnee(Val, G) :- colonneGagnante(Val, G).
partieGagnee(Val, G) :- diagonaleGagnante(Val, G).



%% toutesLesCasesDepart(?ListeCases:list)
%
% Cette méthode permet de récupérer toutes les cases de départ
%
% @param ListeCases La liste des cases où l'on peut jouer
toutesLesCasesDepart(N) :- listeLigne(L), listeColonne(C), combine(C, L, N).


listeLigne2([NL], NL) :- sizeLine(NL), !.
listeLigne2([N|L], N) :- succNum(N, V), listeLigne2(L, V).

%% listeLigne(?Lignes:list)
%
% Cette méthode permet de récupérer toutes les lignes du jeu
listeLigne(L) :- listeLigne2(L, 1).



listeColonne2([NL], NL) :- sizeColumn(NL), !.
listeColonne2([N|L], N) :- succAlpha(N, V), listeColonne2(L, V).

%% listeColonne(?Colonnes:list)
%
% Cette méthode permet de récupérer toutes les colonnes du jeu
listeColonne(L) :- listeColonne2(L, a).

%% grilleDeDepart(?Grille:Grille)
%
% Cette méthode permet de récupérer la grille de départ du jeu
%
% @param Grille La grille de départ
grilleDeDepart(G) :- size(SL, SCA), equiv(SCA, SC), replicate(-, SC, L), replicate(L, SL, G).




%% toutesLesCasesValides(?Grille:Grille, +ListeCoups:list, +Case:list, ?NouveauListeCoups:list)
%
% Cette méthode permet de récupérer touts les coups disponibles pour le prochain joueur
%
% @param Grille La grille dans laquelle on joue
% @param ListeCoups L'ancienne liste des coups
% @param Case La case ou l'on veut jouer
% @param NouveauListeCoups La nouvelle liste des coups
toutesLesCasesValides(Grille, _, _, LC2) :-
	listeLigne(L), listeColonne(C), combine(C, L, N),
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


%% ticTacToe()
%
%  Cette méthode permet de lancer une partie de tic tac toe.
ticTacToe:-
  init(3, c),
	lanceJeu.
