

/** <module> Moteur
 *
 *  Ce module permet de lancer des jeux à 2 joueurs
 *
 *  @author Mano Brabant
 */
:- module(moteur, [
                    ticTacToe/0,
                    puissance4/0,
                    othello/0
                  ]).


ticTacToe :- lanceJeu('TicTacToe/ticTacToe.pl').
puissance4 :- lanceJeu('Puissance4/puissance4.pl').
othello :- lanceJeu('Othello/othello.pl').


%% lastFile
%
% Ce predicat est satisfait s'il contient le dernier fichier chargé
lastFile('').

:- dynamic(lastFile/1).

%% loadFile(+File:string)
%
% Ce prédicat permet de charger un fichier de jeu
%
% @param File Le chemin vers le fichier
loadJeu(File) :- lastFile(LastFile), unload_file(LastFile), consult(File),
  retractall(lastFile(LastFile)), assert(lastFile(File)).


%% lanceJeu(+File:string)
%
%  Cette méthode permet de lancer une partie de jeu à 2 joueurs.
%
% @param File le fichier du jeu
lanceJeu(File) :-
  loadJeu(File),
  jeu:initJeu,
  jeu:grilleDeDepart(G),
  afficheGrille(G),nl,
   writeln("L ordinateur est les x et vous etes les o."),
   writeln("Quel camp doit debuter la partie ? "),read(Camp),
  jeu:toutesLesCasesDepart(Camp, ListeCoups),
  moteur(G,ListeCoups,Camp).



%% afficheLigne(+Ligne:list)
%
% Affiche les éléments de la liste
%
% @param Ligne La liste à afficher
afficheLigne(L, N) :- write(N), tab(2), write("|"), tab(1), afficheLigne2(L).

afficheLigne2([]).
afficheLigne2([A|AS]) :-
  write(A), tab(1), write("|"), tab(1),
  afficheLigne2(AS).


%% afficheGrille(+Grille:grille)
%
% Affiche les éléments de la grille
%
% @param list La liste à afficher
afficheGrille(G) :- outils:listeNomColonne(LNC), tab(3), write("|"), tab(1), afficheNomColonne(LNC), afficheGrille2(G, 1).

afficheGrille2([], _).
afficheGrille2([A|AS], N) :-
  afficheLigne(A, N), nl,
  N1 is N + 1,
  afficheGrille2(AS, N1).

afficheNomColonne([]) :- writeln("").
afficheNomColonne([C|RNC]) :- write(C), tab(1), write("|"), tab(1), afficheNomColonne(RNC).


%%%%%%%%%%%%%%%%% Représentation %%%%%%%%%%%%%%%%%

%% caseVide(?Val:any)
%
% Ce prédicat représente la case vide
% Ce prédicat est satisfait quand la Val est égale à la représentation de la case vide
caseVide(-).

%% sizeLine(?Size:int)
%
% Ce prédicat est satisfait quand Size est égale à la dernière ligne de la grille du jeu en cours
sizeLine(S) :- size(S, _ ).

%% sizeColumn(?Size:char)
%
% Ce prédicat est satisfait quand Size est égale à la dernière colonne de la grille du jeu en cours
sizeColumn(S) :- size( _ , S).


%% init(+SizeLine:int, +SizeColumn:int)
%
% Ce prédicat permet d'initialiser la taille de la grille de jeu avec SizeLine et SizeColumn
init(SL, SC) :-
  retractall(size(_,_)),
  assert(size(SL, SC)),
  sizeLine(SL), sizeColumn(SC),
  retractall(succNum(_, _)),
  retractall(succAlpha(_, _)),
  retractall(equiv(_, _)),
  initSuccNum(1, SL),
  initSuccAlpha(a, SC),
  initEquiv(1, a, SC).


%% initSuccNum(+Debut:int, +Fin:int)
%
% Ce prédicat permet d'initialiser les prédicats succNum/2 pour pouvoir naviguer dans la grille
initSuccNum(D, S) :-  D < S, D1 is D + 1, assert(succNum(D, D1)), initSuccNum(D1, S).
initSuccNum(D, S) :-  D >= S.


%% initSuccAlpha(+Debut:char, +Fin:char)
%
% Ce prédicat permet d'initialiser les prédicats succAlpha/2 pour pouvoir naviguer dans la grille
initSuccAlpha(C, F) :- char_code(C, D), char_code(F, S),
                       D < S, D1 is D + 1,
                       char_code(C1, D1),
                       assert(succAlpha(C, C1)),
                       initSuccAlpha(C1, F).
initSuccAlpha(C, F) :- char_code(C, D), char_code(F, S),
                      D >= S.


%% initEquiv(+DebutLigne:int, +DebutColonne:char, +Fin:char)
%
% Ce prédicat permet d'initialiser les prédicats equiv/2 pour pouvoir naviguer dans la grille
% Les predicats equiv/2 sont utilisés pour connaitre la position numérique d'une colonne
% Par exemple : La colonne c est à la position 3 (c'est la troisième colonne)
initEquiv(D, C, F) :- char_code(C, DA), char_code(F, SA),
                         DA =< SA, D1 is D + 1, DA1 is DA + 1,
                         char_code(C1, DA1),
                         assert(equiv(C, D)), initEquiv(D1, C1, F).
initEquiv(_, C, F) :- char_code(C, DA), char_code(F, SA),
                         DA >= SA.



%% ligneDeGrille(+NumLigne:int, +Grille:grille, ?Ligne:list).
%
% Ce prédicat est satisfait si Ligne est la ligne numero NumLigne dans la Grille
%
% @param NumLigne Le numéro de la ligne
% @param Grille La grille ou récupérer la ligne
% @param Ligne La ligne numéro NumLigne dans la grille
ligneDeGrille(1, [Test |_], Test) :- !.
ligneDeGrille(NumLigne, [_|Reste], Test) :- succNum(I, NumLigne),
		ligneDeGrille(I, Reste, Test).


%% caseDeLigne(+NomColonne:char, +Ligne:list, ?Case:any).
%
% Ce prédicat est satisfait si Case est la valeur à l'emplacement NomColonne dans la Ligne
%
% @param NomColonne Le nom de la colonne
% @param Ligne La ligne ou récupérer la case
% @param Case La case à l'emplacement NomColonne dans la Ligne
caseDeLigne(a, [A|_], A) :- !.
caseDeLigne(Col, [_|Reste], Test) :- succAlpha(I, Col), caseDeLigne(I,Reste, Test).


%% caseDeGrille(+NomColonne:char, +NumLigne:int, +Grille:grille, ?Case:any).
%
% Ce prédicat est satisfait si Case est la valeur à l'emplacement NomColonne et NumLigne dans la GRille
%
% @param NomColonne Le nom de la colonne
% @param NumLigne Le numéro de la ligne
% @param Grille La grille ou récupérer la case
% @param Case La case à l'emplacement NomColonne et NumLigne dans la Grille
caseDeGrille(C,L,G, Elt) :- ligneDeGrille(L,G,Res),caseDeLigne(C,Res,Elt).


%% afficheCaseDeGrille(+NomColonne:char, +NumLigne:int, +Grille:grille).
%
% Ce prédicat permet d'afficher une case de la grille
%
% @param NomColonne Le nom de la colonne
% @param NumLigne Le numéro de la ligne
% @param Grille La grille ou récupérer la case à afficher
afficheCaseDeGrille(C,L,G) :- caseDeGrille(C,L,G,Case),write(Case).




%% coupJoueDansLigne(+NomColonne:char, Val:any, +Ligne:list, ?LigneRetour:list).
%
% Ce prédicat permet de jouer un coup dans une ligne
%
% @param NomColonne Le nom de la colonne ou jouer le coup
% @param Val La valeur à affecter dans la case
% @param Ligne La ligne ou on va jouer le coup
% @param LigneRetour La ligne dans laquelle on a joué le coup
coupJoueDansLigne(a, Val, [_|Reste],[Val|Reste]) :- !.
coupJoueDansLigne(NomCol, Val, [X|Reste1],[X|Reste2]):-
		succAlpha(I,NomCol),
		coupJoueDansLigne(I, Val, Reste1, Reste2).



%% coupJoueDansLigne(+NomColonne:char, +NumLigne:int, Val:any, +Grille:grille, ?GrilleRetour:grille).
%
% Ce prédicat permet de jouer un coup dans une grille
%
% @param NomColonne Le nom de la colonne ou jouer le coup
% @param NomColonne Le numéro de la ligne ou jouer le coup
% @param Val La valeur à affecter dans la case
% @param Grille La grille ou on va jouer le coup
% @param GrilleRetour La grille dans laquelle on a joué le coup
coupJoueDansGrille(NCol,1,Val,[A|Reste],[B|Reste]):- coupJoueDansLigne(NCol, Val, A, B).
coupJoueDansGrille(NCol, NLig, Val, [X|Reste1], [X|Reste2]):- succNum(I, NLig),
					coupJoueDansGrille(NCol, I, Val, Reste1, Reste2).

%  ?- coupJoueDansGrille(a,2,x,[[-,-,x],[-,o,-],[x,o,o]],V).
%  V = [[-,-,x],[x,o,-],[x,o,o]] ;
%  no



%% minMaxOppose(?Val1, ?Val2)
%
% Ce predicat permet de passer de min à max pour l'algorithme minMax
minMaxOppose(min, max).
minMaxOppose(max, min).


%% minmax(+Joueur:any, +Profondeur:int, +MinMax:enum(min, max), ?GrilleArrive:grille, +Grille:grille, ?Eval:int)
%
% Ce predicat permet d'effectuer une recher minmax du meilleur(max)/pire(min) coup possible
%
% @param Joueur Le joueur qui cherche le meilleur coup
% @param Profondeur Le nombre d'hypothèse que l'on va faire en descendant dans l'arbre de recherche
% @param MinMax Egale à max si on cherche le meilleur coup, min si on cherche le meilleur coup pour l'adversaire (le pire pour nous)
% @param GrilleArrive La grille dans laquelle on a joué le coup
% @param Grille La grille dans laquelle on cherche le meilleur coup
% @param Eval La valeur du meilleur coup trouvé
minmax(Joueur, 0, _, _, Grille, E) :- jeu:eval(Grille, Joueur, E), !.

minmax(Joueur, _, _, _, Grille, E) :- campAdverse(Joueur, Adv),
                                      jeu:terminal(Joueur, Grille),
                                      jeu:terminal(Adv, Grille), jeu:eval(Grille, Joueur, E), !.


minmax(Joueur, P, MM, _, Grille, E) :-  jeu:terminal(Joueur, Grille),
                                        minMaxOppose(MM, MM2),
                                        P1 is P - 1,
                                        minmax(Joueur, P1, MM2, _, Grille, E), !.


minmax(Joueur, P, MM, _, Grille, E) :- campAdverse(Joueur, Adv),
                                       jeu:terminal(Adv, Grille),
                                       minMaxOppose(MM, MM2),
                                       P1 is P - 1,
                                       minmax(Joueur, P1, MM2, _, Grille, E), !.


minmax(Joueur, Profondeur, max, GrilleFin, Grille, E) :-

%  campAdverse(Joueur, Adv),
  toutesLesCasesValides(Joueur, Grille, ListeCoups),            %On regarde quel coup on peut faire
  maplist(joueLeCoup2(Joueur, Grille), GrilleArr, ListeCoups),  %On les joue
  P1 is Profondeur - 1,
  maplist(minmax(Joueur, P1, min), _, GrilleArr, Es),           %On voit ce que peut repondre l'adversaire pour chacun d'entre eux
  max_list(Es, E),                                              %On prend le coup le plus fort pour le joueur (le plus faible pour l'adversaire)
  outils:associe(GrilleArr, Es, GrilleEval),
  include(=([_, E]), GrilleEval, GrilleA),                      %On garde les coups les plus forts
  nth1(1, GrilleA, GrilleF),                                    %On prend le premier coup le plus fort (on pourrait l'améliorer avec
  nth1(1, GrilleF, GrilleFin).                                  % une fonction de prise au hasard)



minmax(Joueur, Profondeur, min, GrilleFin, Grille, E) :-

  campAdverse(Joueur, Adv),
  toutesLesCasesValides(Adv, Grille, ListeCoups),               %On regarde quel coup l'adversaire peut faire
  maplist(joueLeCoup2(Adv, Grille), GrilleArr, ListeCoups),     %On les joue
  P1 is Profondeur - 1,
  maplist(minmax(Joueur, P1, max), _, GrilleArr, Es),           %On voit ce que peut repondre le joueur pour chacun d'entre eux
  min_list(Es, E),                                              %On prend le coup le plus faible pour le joueur (le plus fort pour l'adversaire)
  outils:associe(GrilleArr, Es, GrilleEval),
  include(=([_, E]), GrilleEval, GrilleA),                      %On garde les coups les plus faibles
  nth1(1, GrilleA, GrilleF),                                    %On prend le premier coup le plus faible (on pourrait l'améliorer avec
  nth1(1, GrilleF, GrilleFin).                                  % une fonction de prise au hasard)



%% campCPU(?Val:any)
%
% Ce prédicat determine la valeur du joueur ordinateur (la façon dont est représenté ses pions sur la grille)
campCPU(x).


%% campAdverse(?Val1:any, ?Val2:any)
%
% Ce predicat permet de connaitre l'adversaire d'un autre joueur
campAdverse(x,o).
campAdverse(o,x).

%% joueLeCoup(+Case:list, +Valeur:any, +GrilleDep:grille, ?GrilleArr:grille)
%
% Ce prédicat est satisfait si GrilleArr corrspond à GrilleDep dans laquelle on aurait joué un coup Valeur dans la case Case
%
% @param Case La case dans laquelle on joue
% @param Valeur La valeur que l'on va affecter dans la case
% @param GrilleDep La grille dans laquelle on va jouer le coup
% @param GrilleArr La grille dans laquelle on a joué le coup
joueLeCoup(Case, Valeur, GrilleDep, GrilleArr) :-
	outils:coordonneesOuListe(Col, Lig, Case),
	jeu:leCoupEstValide(Valeur, Col, Lig, GrilleDep),
	coupJoueDansGrille(Col, Lig, Valeur, GrilleDep, GrilleArr2),
  jeu:consequencesCoupDansGrille(Col, Lig, Valeur, GrilleArr2, GrilleArr).

joueLeCoup2(Valeur, GrilleDep, GrilleArr, Case) :- joueLeCoup(Case, Valeur, GrilleDep, GrilleArr).


%% ecrireFichMinMax(+Liste:list, +Profondeur:int)
%
% Ce prédicat permet d'ecrire le contenue de Liste dans un fichier ProfX.txt avec X = Profondeur
% Ce prédicat à été utilisé pour faaire des vérification sur l'algorithme minmax
%
% @param Liste La liste de valeur à écrire
% @param Profondeur Une partie du nom du fichier
ecrireFichMinMax(L,P) :- !,
              number_string(P, Ps),
              string_concat("Prof", Ps, F),
              string_concat(F, ".txt", F1),
              open(F1, append, X),
              atomics_to_string(L, ',', L1),
              write(X,L1),
              write(X,"\n"),
              write(X,"\n"),
              close(X).





%% toutesLesCasesValides(+Camp:any, +Grille:Grille, ?NouveauListeCoups:list)
%
% Cette méthode permet de récupérer touts les coups disponibles pour le prochain joueur
%
% @param Camp Le joueur qui va jouer le coup
% @param Grille La grille dans laquelle on joue
% @param NouveauListeCoups La nouvelle liste des coups
toutesLesCasesValides(Camp, Grille, LC2) :-
  outils:toutesLesCases(LC1),
  include(jeu:leCoupEstValide(Camp, Grille), LC1, LC2).



%% moteur(+Grille:grille, +ListeCoups:list, +Camp:any)
%
% Ce prédicat permet de séquencer une partie de jeu à 2 joueurs
%
% @param Grille La grille dans laquelle on est entrain de jouer
% @param ListeCoups La liste des coup disponible pour le joueur
% @param Camp Le joueur qui va effectuer le prochain coup

/*
moteur(Grille,_,Camp):-
  writeln("La liste de coups"),
  toutesLesCasesValides(Camp, Grille, ListeCoupsNew),
  writeln(ListeCoupsNew),
  fail.
*/

% cas gagnant pour le joueur
moteur(Grille,_,Camp):-
	jeu:partieGagnee(Camp, Grille), nl,
	write('le camp '), write(Camp), write(' a gagne').

% cas gagnant pour le joueur adverse
moteur(Grille,_,Camp):-
	campAdverse(CampGagnant, Camp),
	jeu:partieGagnee(CampGagnant, Grille), nl,
	write('le camp '), write(CampGagnant), write(' a gagne').

% cas de match nul, plus de coups jouables possibles
moteur(G,[],_) :- jeu:determineGagnant(G).

% cas ou l ordinateur doit jouer
moteur(Grille, _, Camp) :-
	campCPU(Camp),
  campAdverse(AutreCamp, Camp),
  jeu:profondeurMinMax(ProfMinMax),
  minmax(Camp, ProfMinMax, max, GrilleArr, Grille, _),
  nl, afficheGrille(GrilleArr), nl,
  toutesLesCasesValides(AutreCamp, GrilleArr, ListeCoupsNew),
	moteur(GrilleArr, ListeCoupsNew, AutreCamp).

% cas ou c est l utilisateur qui joue
moteur(Grille, ListeCoups, Camp) :-
  campCPU(CPU),
  campAdverse(Camp, CPU),
  jeu:saisieUnCoup(Grille, Col,Lig),
  valide(Col, Lig, Grille, Camp, CPU, ListeCoups).


% Si le coup est valide on le joue
valide(Col, Lig, Grille, Camp, CPU, _) :-
  jeu:leCoupEstValide(Camp, Col, Lig, Grille),
  joueLeCoup([Col,Lig], Camp, Grille, GrilleArr),
  nl, afficheGrille(GrilleArr), nl,
  toutesLesCasesValides(CPU, GrilleArr, ListeCoupsNew),
  moteur(GrilleArr, ListeCoupsNew, CPU).

% Si le coup n'est pas valide on prévient le joueur et il recommence
valide(Col, Lig, Grille, Camp, _, ListeCoups) :-
  \+ jeu:leCoupEstValide(Camp, Col, Lig, Grille),
  write("Coup invalide"), nl,
	moteur(Grille, ListeCoups, Camp).
