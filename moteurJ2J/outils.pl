
/** <module> Outils
 *
 *  Ce module contient des fonctions utilitaires
 *
 *  @author Mano Brabant
 */
:- module(outils, [
                    replicate/3,
                    combineListe/3,
                    transpose/2,
                    coordonneesOuListe/3,
                    duneListeALautre/3,
                    ligneDeN/4,
                    lignesDeN/3
                  ]).





%% ligneDeN(+Val:any, Liste:list, +NbRepetition:int)
%
% Ce prédicat est satisfait si les nbRepetition premier elements de la liste sont Val
%
% @param Val La valeur a vérifier
% @param Liste La liste qui contient les elements
% @param NbRepetition Le nombre de premier elements qui doivent être Val
ligneDeN(Val, [Val|_], 1, _) :- !.
ligneDeN(Val, [Val|R], N, S) :- N1 is N - 1, ligneDeN(Val, R, N1, S).
ligneDeN(Val, [_|R], _, S) :- ligneDeN(Val, R, S, S).


%% toutesLesCases(?ListeCase:list)
%
% Ce prédicat est satisfait si la liste contient toutes les case du jeu en cours
%
% @param ListeCase La liste des cases du jeu
toutesLesCases(LC1) :-
  listeNumLigne(L), listeNomColonne(C), combineListe(C, L, LC1).



%% listeNumLigne(?ListeNumLigne:list)
%
% Ce prédicat est satisfait si la liste contient touts les numéros de ligne du jeu en cours
%
% @param ListeNumLigne La liste des numéros du jeu
listeNumLigne(L) :- listeNumLigne2(L, 1).

listeNumLigne2([NL], NL) :- moteur:sizeLine(NL), !.
listeNumLigne2([N|L], N) :- moteur:succNum(N, V), listeNumLigne2(L, V).



%% listeNomColonne(?ListeNomColonne:list)
%
% Ce prédicat est satisfait si la liste contient touts les noms de colonne du jeu en cours
%
% @param ListeNomColonne La liste des numéros du jeu
listeNomColonne(L) :- listeNomColonne2(L, a).

listeNomColonne2([NL], NL) :- moteur:sizeColumn(NL), !.
listeNomColonne2([N|L], N) :- moteur:succAlpha(N, V), listeNomColonne2(L, V).




%% lignesDeN(+Val:any, Grille:Grille, +NbRepetition:int)
%
% Ce prédicat est satisfait si la grille contient une ligne dont les nbRepetition premier elements sont Val
%
% @param Val La valeur a vérifier
% @param Liste La liste qui contient les elements
% @param NbRepetition Le nombre de premier elements qui doivent être Val
lignesDeN(_, [], _) :- fail.
lignesDeN(Val, [L|_], N) :- ligneDeN(Val, L, N, N), !.
lignesDeN(Val, [_|R], N) :- lignesDeN(Val, R, N).



%% listeLigne(+Grille:Grille, ?Lignes:list)
%
% Ce prédicat est satisfait si la liste contient les lignes de la grille
%
% @param Grille La grille à vérifier
% @param Liste La liste qui contient les lignes de la grille
listeLigne(G, G) :- !.


%% listeColonne(+Grille:Grille, ?Lignes:list)
%
% Ce prédicat est satisfait si la liste contient les colonnes de la grille
%
% @param Grille La grille à vérifier
% @param Liste La liste qui contient les colonnes de la grille
listeColonne(G, LC) :- transpose(G, LC).




%% diagonale(+Grille:Grille, ?Diagonale:list)
%
% Ce prédicat est satisfait si la liste contient la diagonale de la grille (de haut-gauche à bas-droite)
%
% @param Grille La grille à vérifier
% @param Liste La liste qui contient la diagonale de la grille
diagonale(G, D) :- diagonale2(G, 0, D).

diagonale2([], _, []) :- !.
diagonale2([L|LS], N, [V|R]) :-  N1 is N + 1, diagonale2(LS, N1, R), nth1(N1, L, V), !.
diagonale2([_|LS], N, R) :-  N1 is N + 1, diagonale2(LS, N1, R), !.




%% diagonalesHGBD(+Grille:Grille, ?Diagonale:list)
%
% Ce prédicat est satisfait si la liste contient toutes les diagonales de la grille (de haut-gauche à bas-droite)
%
% Exemple : pour la matrice [[a,b]
%                            [c,d]
%                            [e,f]]
% Le résultat sera [[a,d],[c,f],[e]]
%
% @param Grille La grille à vérifier
% @param Liste La liste qui contient la liste des diagonales de la grille
diagonalesHGBD([], []) :- !.
diagonalesHGBD([G|RG], [D|R]) :- diagonalesHGBD(RG, R), diagonale([G|RG], D), !.


%% listeDiagonale(+Grille:Grille, ?Lignes:list)
%
% Ce prédicat est satisfait si la liste contient les diagonales de la grille
% On appelle [[diagonalesHGBD/2]] 4 fois en tournant la grille de 90° entre chaque appel.
%
% Exemple : pour la matrice [[a,b]
%                            [c,d]
%                            [e,f]]
% Le résultat sera [[a,d],[c,f],[e],[b,c],[a],[f,c],[d,a],[b],[e,d],[f]]
%
% @param Grille La grille à vérifier
% @param Liste La liste qui contient les diagonales de la grille
diagonales(G, LD) :-
  reverse(G, R1G),
  transpose(R1G, G1),
  reverse(G1, R2G),
  transpose(R2G, G2),
  reverse(G2, R3G),
  transpose(R3G, G3),
  diagonalesHGBD(G, L),
  diagonalesHGBD(G1, RL),
  diagonalesHGBD(G2, TL),
  diagonalesHGBD(G3, TRL),
  append(L, RL, L2),
  append(L2, TL, L3),
  append(L3, TRL, LD).



%% listeDiagonale(+Grille:Grille, ?Lignes:list)
% @see [[diagonales/2]]
listeDiagonale(G, LD) :- diagonales(G, LD).


%% tailleSupN(+Taille:int, ?Ligne:list)
%
% Ce prédicat est satisfait si la liste est de taille supérieur ou égal à Taille
%
% @param Taille La taille minimum
% @param Liste La liste à vérifier
tailleSupN(N, L) :-
  length(L, N1),
  N1 >= N.

%% toutesLesLignesDeLongueurSupAN(+Grille:grille, +Longueur:Int, ?Lignes:list)
%
% Ce prédicat est satisfait si la liste de ligne contient toutes les lignes de longueur supérieur ou égale à Longueur de la grille
% Toutes les lignes contient les lignes, les colonnes, les diagonales.
%
% @param Grille La grille dans laquelle chercher les lignes
% @param Longueur La longuer minimale des lignes
% @param Lignes Les lignes de la grille de longueur supérieur ou égale à Longueur
toutesLesLignesDeLongueurSupAN(G, N, L) :-
  listeLigne(G, LL),
  listeColonne(G, LC),
  listeDiagonale(G, LD),
  append(LL, LC, LLC),
  append(LLC, LD, LLCD),
  include(tailleSupN(N), LLCD, L).



%% grilleAvecLigneDeN(+Grille:grille, +Valeur:char, ?Longueur:int)
%
% Ce prédicat est satisfait si la grille contient une ligne avec Longueur fois de suite une même valeur Valeur
%
% @param Grille La grille à vérifier
% @param Valeur La valeur à chercher
% @param Longueur Le nombre d'occurences de suite à trouver
grilleAvecLigneDeN(G, Val, N, N2) :- outils:toutesLesLignesDeLongueurSupAN(G, N, L), outils:lignesDeN(Val, L, N2).

%% replicate(+Val:any, +NbRep:int, ?Liste:list)
%
%  Ce prédicat est satisfait si une valeur est répété un certaine nombre de fois dans une liste.
%
% @param Val La valeur qui doit se répéter
% @param NbRep Le nombre de fois que la valeur doit se répéter
% @param Liste La liste qui contient NbRep fois Val
replicate(V, N, L) :- length(L, N), maplist(=(V), L).


%% associe(+Liste1:list, +Liste2:list, ?ListeRetour:list)
%
% Ce prédicat est satisfait si ListeRetour a pour chaque element une liste contenant les elements de même indice de Liste1 et Liste2
%
% Exemple : Avec Liste1 = [1,2,3] et Liste2 = [a,b,c]
%           ListeRetour = [[1,a],[2,b],[3,c]]
%
% @param Liste1 La première liste
% @param Liste2 La deuxième liste
% @param ListeRetour La liste de retour
associe([], [], []).
associe([L1|R1], [L2|R2], [[L1,L2]|R]) :- associe(R1, R2, R).


%% combineListe(+Liste1:list, +Liste2:list, ?ListeRetour:list)
%
% Ce prédicat est satisfait si la liste de retour est le produit cartésien de la liste 1 et 2.
%
% @param Liste1 La première liste
% @param Liste2 La deuxième liste
% @param ListeRetour La liste qui contient le produit cartésien de la liste 1 et 2
combineListe(_, [], []).
combineListe(L1, [L2|L2S], RS) :- combineElem(L1, L2, V), combineListe(L1, L2S, R), append(V, R, RS).


%% combineElem(+Liste:list, Val:any, ListeRetour:list)
%
% @see [[associe/3]]
%
% Comme associe mais prend une valeur unique à la place de la deuxième liste
combineElem([], _, []).
combineElem([L|LS], V, [[L,V]|R]) :- combineElem(LS, V, R).


%% transpose(+Matrice:matrice, ?MatriceRetour:matrice)
%
%  Ce prédicat est satisfait si la matrice de retour est la transposé de la matrice 1.
%
% @param Matrice La matrice à transposer
% @param MatriceRetour La matrice transposée
transpose([[]|_], []) :- !.
transpose(Matrix, [Row|Rows]) :- transpose_1st_col(Matrix, Row, RestMatrix),
                                 transpose(RestMatrix, Rows).
transpose_1st_col([], [], []).
transpose_1st_col([[H|T]|Rows], [H|Hs], [T|Ts]) :- transpose_1st_col(Rows, Hs, Ts).





%% coordonneesOuListe(+NomColonne:char, +NumLigne:int, ?Case:list)
%
%  Ce prédicat est satisfait si le nom de colonne et le numéro de ligne correspondent à la case
%
% @param NomColonne Le nom de la colonne
% @param NumLigne Le numéro de la ligne
% @param Case La case
coordonneesOuListe(NomCol, NumLigne, [NomCol, NumLigne]).


%% duneListeALautre(+Liste1:list, +Element:any, ?ListeRetour:list)
%
%  Ce prédicat est satisfait si la liste de retour est la liste 1 privée de l'element donnée
%
% @param Liste1 La liste avec l'element
% @param Element L'element à retirer
% @param ListeRetour La liste privée de l'element
duneListeALautre([A|B], A, B).
duneListeALautre([A|B], C, [A|D]):- duneListeALautre(B,C,D).
