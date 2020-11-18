
/** <module> Outils
 *
 *  Ce module contient des fonctions utilitaires
 *
 *  @author Mano Brabant
 */
:- module(outils, [
                    replicate/3,
                    combine/3,
                    transpose/2,
                    coordonneesOuListe/3,
                    duneListeALautre/3,
                    ligneDeN/3,
                    lignesDeN/3
                  ]).




%% ligneDeN(+Val:any, Liste:list, +NbRepetition:int)
%
% Ce prédicat est satisfait si les nbRepetition premier elements de la liste sont Val
%
% @param Val La valeur a vérifier
% @param Liste La liste qui contient les elements
% @param NbRepetition Le nombre de premier elements qui doivent être Val
ligneDeN(Val, [Val|_], 1) :- !.
ligneDeN(Val, [Val|R], N) :- N1 is N - 1, ligneDeN(Val, R, N1).





%% lignesDeN(+Val:any, Grille:Grille, +NbRepetition:int)
%
% Ce prédicat est satisfait si la grille contient une ligne dont les nbRepetition premier elements sont Val
%
% @param Val La valeur a vérifier
% @param Liste La liste qui contient les elements
% @param NbRepetition Le nombre de premier elements qui doivent être Val
lignesDeN(_, [], _) :- fail.
lignesDeN(Val, [L|_], N) :- ligneDeN(Val, L, N), !.
lignesDeN(Val, [_|R], N) :- lignesDeN(Val, R, N).



%TODO :: toutesLesLignesDeLongueurSupAN(G, N, L)
%% toutesLesLignesDeLongueurSupAN(+Grille:grille, +Longueur:Int, ?Lignes:list)
%
% Ce prédicat est satisfait si la liste de ligne contient toutes les lignes de longueur supérieur ou égale à Longueur de la grille
% Toutles lignes contient les lignes, les colonnes, les diagonales.
%
% @param Grille La grille dans laquelle chercher les lignes
% @param Longueur La longuer minimale des lignes
% @param Lignes Les lignes de la grille de longuer supérieur ou égale à Longueur


%% replicate(+Val:any, +NbRep:int, ?Liste:list)
%
%  Ce prédicat est satisfait si une valeur est répété un certaine nombre de fois dans une liste.
%
% @param Val La valeur qui doit se répéter
% @param NbRep Le nombre de fois que la valeur doit se répéter
% @param Liste La liste qui contient NbRep fois Val
replicate(V, N, L) :- length(L, N), maplist(=(V), L).


combine2([], _, []).
combine2([L|LS], V, [[L,V]|R]) :- combine2(LS, V, R).


associe([], [], []).
associe([L1|R1], [L2|R2], [[L1,L2]|R]) :- associe(R1, R2, R).

%% combine(+Liste1:list, +Liste2:list, ?ListeRetour:list)
%
%  Ce prédicat est satisfait si la liste de retour est le produit cartésien de la liste 1 et 2.
%
% @param Liste1 La première liste
% @param Liste2 La deuxième liste
% @param ListeRetour La liste qui contient le produit cartésien de la liste 1 et 2
combine(_, [], []).
combine(L1, [L2|L2S], RS) :- combine2(L1, L2, V), combine(L1, L2S, R), append(V, R, RS).


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
