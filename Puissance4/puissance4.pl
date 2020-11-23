
/** <module> Puissance 4
 *
 *  Ce module permet de jouer au jeu de Puissance 4
 *
 *  @author Mano Brabant
 */
:- module(jeu, []).


:- consult('../moteurJ2J/outils.pl').


%% puissance4()
%
%  Cette méthode permet de lancer une partie de Puissance 4.
initJeu():-
	moteur:init(6, g).

profondeurMinMax(4).

%% leCoupEstValide(+Colonne:char, +Ligne:int, +Grille:Grille)
%
% Cette méthode permet de savoir si on peut jouer dans une case dans une grille donnée
%
% @param Colonne La colonne de la case à vérifier
% @param Ligne La ligne de la case à vérifier
% @param Grille La grille dans laquelle on vérifie la case
leCoupEstValide(C,L,G) :- moteur:caseVide(Cv), moteur:caseDeGrille(C,L,G,Cv), moteur:succNum(L, L2), moteur:caseDeGrille(C,L2,G,Cv2), \+ moteur:caseVide(Cv2).
leCoupEstValide(C,L,G) :- moteur:caseVide(Cv), moteur:caseDeGrille(C,L,G,Cv), \+ moteur:succNum(L, _).


%% leCoupEstValide(+Grille:Grille, +Case:Case)
%
% Cette méthode permet de savoir si on peut jouer dans une case dans une grille donnée
%
% @param Grille La grille dans laquelle on vérifié la case
% @param Case La case à vérifier
% @see [[leCoupEstValide/3]]
leCoupEstValide(G, CL) :- outils:coordonneesOuListe(Col, Lig, CL), leCoupEstValide(Col, Lig, G).



%% partieGagnee(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille est gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
partieGagnee(Val, G) :- outils:grilleAvecLigneDeN(G, Val, 4, 4).



%% toutesLesCasesDepart(?ListeCases:list)
%
% Cette méthode permet de récupérer toutes les cases de départ
%
% @param ListeCases La liste des cases où l'on peut jouer
toutesLesCasesDepart(N) :- outils:listeNomColonne(C), moteur:sizeLine(SL), outils:combineListe(C, [SL], N).



%% grilleDeDepart(?Grille:Grille)
%
% Cette méthode permet de récupérer la grille de départ du jeu
%
% @param Grille La grille de départ
grilleDeDepart(G) :- moteur:size(SL, SCA), moteur:equiv(SCA, SC),
	outils:replicate(-, SC, L), outils:replicate(L, SL, G).



terminal(G) :- moteur:toutesLesCasesValides(G, LC), length(LC, L), L == 0.
terminal(G) :- partieGagnee(x, G).
terminal(G) :- partieGagnee(o, G).


%eval(G, J, _) :- moteur:afficheGrille(G), nl, write(J), nl, fail.
eval(G, J, -1000) :- moteur:campAdverse(J, J1), partieGagnee(J1, G), !.
eval(G, J, 1000) :- partieGagnee(J, G), !.

eval(G, J, -100) :- moteur:campAdverse(J, J1), outils:grilleAvecLigneDeN(G, J1, 4, 3), outils:grilleAvecLigneDeN(G, J, 4, 3).
eval(G, J, -200) :- moteur:campAdverse(J, J1), outils:grilleAvecLigneDeN(G, J1, 4, 3).
eval(G, J, 200) :- outils:grilleAvecLigneDeN(G, J, 4, 3).

eval(_,_,5) :- !.


consequencesCoupDansGrille(_, _, _, GrilleArr, GrilleArr).


derniereLigne2([C|_], 0) :- \+ moteur:caseVide(C), !.
derniereLigne2([], 0) :- !.
derniereLigne2([_|R], NumLigne) :- derniereLigne2(R, N), NumLigne is N + 1.


%% derniereLigne(+Grille:Grille, +NomColonne:char, ?NumLigne:int)
%
% Cette méthode permet récupérer le numéro de ligne de la dernière case vide d'une colonne
%
% @param Grille La grille où chercher
% @param NomColonne Le nom de la colonne dans laquelle on cherche la dernière case vide
% @param NumLigne Le numéro de la ligne où se trouve la dernière case vide
derniereLigne(G, NomColonne, NumLigne) :-
	moteur:equiv(NomColonne, NumColonne),
	outils:transpose(G, G1), nth1(NumColonne, G1, L),
	derniereLigne2(L, NumLigne).


%% saisieUnCoup(+Grille:Grille, ?NomColonne:char, ?NumLigne:int)
%
% Cette méthode permet de demander à l'utilisateur de saisir un coup
%
% @param Grille La grille dans laquelle le joueur va jouer son coup
% @param NomColonne Le nom de la colonne dans laquelle le joueur va jouer son coup
% @param NumLigne Le numéro de la ligne dans laquelle le joueur va jouer son coup
saisieUnCoup(G, NomCol,NumLig) :-
	write("entrez le nom de la colonne a jouer : "),
	outils:listeNomColonne(LNC),
	writeln(LNC),
	read(NomCol), nl,
	derniereLigne(G, NomCol, NumLig).








% Les fonctions mortes au combat
% @deprecated



%% ligneDeN(+Val:any, Liste:list, +NbRepetition:int)
%
% Ce prédicat est satisfait si les nbRepetition premier elements de la liste sont Val
%
% @param Val La valeur a vérifier
% @param Liste La liste qui contient les elements
% @param NbRepetition Le nombre de premier elements qui doivent être Val
/*
ligneDeN(Val, [Val|_], 1) :- !.
ligneDeN(Val, [Val|R], N) :- N1 is N - 1, ligneDeN(Val, R, N1).
*/

%% ligneDe4(+Val:any, Ligne:list)
%
% Ce prédicat est satisfait si une ligne contient 4 elements Val consécutif
%
% @param Val La valeur a vérifier
% @param Ligne La ligne à vérifier
/*
ligneDe4(_, []) :- fail.
ligneDe4(Val, L) :- ligneDeN(Val, L, 4).
ligneDe4(Val, [_|R]) :- ligneDe4(Val, R).
*/

%% ligneGagnante(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille contient une ligne gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
/*
ligneGagnante(Val, [L1|_]) :- outils:ligneDeN(Val, L1, 4), !.
ligneGagnante(Val, [_|R]) :- ligneGagnante(Val, R), !.
*/


%% colonneGagnante(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille contient une colonne gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
/*
colonneGagnante(Val, L) :- outils:transpose(L, L1), ligneGagnante(Val, L1).
*/


%% diagonale(+Grille:Grille, ?NbElement:int, +Ligne:Ligne)
%
% Cette méthode permet de récupérer une diagonale dans une grille donnée
%
% @param Grille La grille où l'on va récupérer une diagonale
% @param NbElemtn Le nombre d'éléments dans la diagonale
% @param Ligne La diagonale récupérée
/*
diagonale([], _, []).
diagonale([L|LS], N, [V|R]) :-  N1 is N + 1, diagonale(LS, N1, R), nth1(N1, L, V).
*/


%% diagonaleGagnante(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une des diagonale (haut-gauche->bas-droite)
% de la grille contient 4 même valeur consécutive
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
/*
diagonaleGagnante2(_, []) :- fail.
diagonaleGagnante2(Val, L) :- diagonale(L, 0, D), outils:ligneDeN(Val, D, 4).
diagonaleGagnante2(Val, [_|R]) :- diagonaleGagnante2(Val, R).
*/


%% diagonaleGagnante(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille contient une diagonale gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
/*
diagonaleGagnante(Val, L) :- 																									diagonaleGagnante2(Val, L).
diagonaleGagnante(Val, L) :- 													outils:reverse(L, L1),	diagonaleGagnante2(Val, L1).
diagonaleGagnante(Val, L) :- outils:transpose(L, L1), 												diagonaleGagnante2(Val, L1).
diagonaleGagnante(Val, L) :- outils:transpose(L, L1), outils:reverse(L1, L2),	diagonaleGagnante2(Val, L2).
*/



%% partieGagnee(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille est gagnante pour un joueur
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
/*
partieGagnee(Val, G) :- ligneGagnante(Val, G).
partieGagnee(Val, G) :- colonneGagnante(Val, G).
partieGagnee(Val, G) :- diagonaleGagnante(Val, G).
*/

/*
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
*/



%% toutesLesCasesValides(+Grille:Grille, +ListeCoups:list, +Case:list, ?NouveauListeCoups:list)
%
% Cette méthode permet de récupérer touts les coups disponibles pour le prochain joueur
%
% @param Grille La grille dans laquelle on joue
% @param ListeCoups L'ancienne liste des coups
% @param Case La case ou l'on veut jouer
% @param NouveauListeCoups La nouvelle liste des coups
/*
toutesLesCasesValides(Grille, _, _, LC2) :-
	listeLigne(L), listeColonne(C), outils:combine(C, L, N),
  include(leCoupEstValide(Grille), N, LC2).
*/
