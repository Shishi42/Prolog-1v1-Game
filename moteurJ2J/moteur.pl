

/** <module> Moteur
 *
 *  Ce module permet de lancer des jeux à 2 joueurs
 *
 *  @author Mano Brabant
 */
:- module(moteur, [lanceJeu/1]).

lastFile('').

:- dynamic(lastFile/1).

loadJeu(File) :- lastFile(LastFile), unload_file(LastFile), consult(File),
  retractall(lastFile(LastFile)), assert(lastFile(File)).



%% lanceJeu(+File:string)
%
%  Cette méthode permet de lancer une partie de jeu à 2 joueurs.
%
% @param File le fichier du jeu
lanceJeu(File) :-
  loadJeu(File),
  jeu:initJeu(),
  jeu:grilleDeDepart(G),
  jeu:toutesLesCasesDepart(ListeCoups),
  afficheGrille(G),nl,
   writeln("L ordinateur est les x et vous etes les o."),
   writeln("Quel camp doit debuter la partie ? "),read(Camp),
  moteur(G,ListeCoups,Camp).



%% afficheLigne(+List:list)
%
% Affiche les éléments de la liste
%
% @param list La liste à afficher
afficheLigne2([]).
afficheLigne2([A|AS]) :-
  write(A), tab(1), write("|"), tab(1),
  afficheLigne2(AS).

afficheLigne(L, N) :- write(N), tab(2), write("|"), tab(1), afficheLigne2(L).

% TODO :: Afficher num lignes, nom colonnes
% Predicat : afficheGrille/1
afficheGrille2([], _).
afficheGrille2([A|AS], N) :-
  afficheLigne(A, N), nl,
  N1 is N + 1,
  afficheGrille2(AS, N1).

afficheNomColonne([]) :- writeln("").
afficheNomColonne([C|RNC]) :- write(C), tab(1), write("|"), tab(1), afficheNomColonne(RNC).

afficheGrille(G) :- outils:listeNomColonne(LNC), tab(3), write("|"), tab(1), afficheNomColonne(LNC), afficheGrille2(G, 1).


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
ligneDeGrille(NumLigne, [_|Reste], Test) :- succNum(I, NumLigne),
		ligneDeGrille(I, Reste, Test).

% Predicat : caseDeLigne(Col, Liste, Valeur).
% Satisfait si Valeur est dans la colonne Col de la Liste
caseDeLigne(a, [A|_], A) :- !.
caseDeLigne(Col, [_|Reste], Test) :- succAlpha(I, Col), caseDeLigne(I,Reste, Test).


% Predicat : caseDeGrille(NumCol, NumLigne, Grille, Case).
% Satisfait si Case est la case de la Grille en position NumCol-NumLigne
caseDeGrille(C,L,G, Elt) :- ligneDeGrille(L,G,Res),caseDeLigne(C,Res,Elt).


% Predicat : afficheCaseDeGrille(Colonne,Ligne,Grille) .
afficheCaseDeGrille(C,L,G) :- caseDeGrille(C,L,G,Case),write(Case).




%%%%%%%%%%%%%%%%% Coups autorisés %%%%%%%%%%%%%%%%%


% version recursive
coupJoueDansLigne(a, Val, [_|Reste],[Val|Reste]) :- !.
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


minmax(Joueur, 0, _, _, Grille, E) :- jeu:eval(Grille, Joueur, E), !.
minmax(Joueur, _, _, _, Grille, E) :- jeu:terminal(Grille), jeu:eval(Grille, Joueur, E), !.

minmax(Joueur, Profondeur, max, GrilleFin, Grille, E) :-

  toutesLesCasesValides(Grille, ListeCoups),
%  campAdverse(Joueur, Adv),
  maplist(joueLeCoup2(Joueur, Grille), GrilleArr, ListeCoups),
  P1 is Profondeur - 1,
  maplist(minmax(Joueur, P1, min), _, GrilleArr, Es),
  max_list(Es, E),
  outils:associe(GrilleArr, Es, GrilleEval),
  include(=([_, E]), GrilleEval, GrilleA),
  nth1(1, GrilleA, GrilleF),
  nth1(1, GrilleF, GrilleFin).



minmax(Joueur, Profondeur, min, GrilleFin, Grille, E) :-

  toutesLesCasesValides(Grille, ListeCoups),
  campAdverse(Joueur, Adv),
  maplist(joueLeCoup2(Adv, Grille), GrilleArr, ListeCoups),
  P1 is Profondeur - 1,
  maplist(minmax(Joueur, P1, max), _, GrilleArr, Es),
  min_list(Es, E),
  outils:associe(GrilleArr, Es, GrilleEval),
  include(=([_, E]), GrilleEval, GrilleA),
  nth1(1, GrilleA, GrilleF),
  nth1(1, GrilleF, GrilleFin).

%%%%%%%%%%%%%%%%% Joueur artificiel %%%%%%%%%%%%%%%%%

campCPU(x).


campAdverse(x,o).
campAdverse(o,x).

joueLeCoup2(Valeur, GrilleDep, GrilleArr, Case) :- joueLeCoup(Case, Valeur, GrilleDep, GrilleArr).

joueLeCoup(Case, Valeur, GrilleDep, GrilleArr) :-
	outils:coordonneesOuListe(Col, Lig, Case),
	jeu:leCoupEstValide(Col, Lig, GrilleDep),
	coupJoueDansGrille(Col, Lig, Valeur, GrilleDep, GrilleArr2),
  jeu:consequencesCoupDansGrille(Col, Lig, Valeur, GrilleArr2, GrilleArr).




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





%% toutesLesCasesValides(+Grille:Grille, ?NouveauListeCoups:list)
%
% Cette méthode permet de récupérer touts les coups disponibles pour le prochain joueur
%
% @param Grille La grille dans laquelle on joue
% @param NouveauListeCoups La nouvelle liste des coups
toutesLesCasesValides(Grille, LC2) :-
  outils:toutesLesCases(LC1),
  include(jeu:leCoupEstValide(Grille), LC1, LC2).



% Predicat : moteur/3
% Usage : moteur(Grille,ListeCoups,Camp) prend en parametre une grille dans
% laquelle tous les coups sont jouables et pour laquelle
% Camp doit jouer.


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
% TODO :: Système de point a regarder en fin de partie
moteur(_,[],_) :-nl, write('game over').

% cas ou l ordinateur doit jouer
moteur(Grille, _, Camp) :-
	campCPU(Camp),
  campAdverse(AutreCamp, Camp),
  jeu:profondeurMinMax(ProfMinMax),
  minmax(Camp, ProfMinMax, max, GrilleArr, Grille, E),
  nl, afficheGrille(GrilleArr), nl,
  write(E), nl,
  toutesLesCasesValides(GrilleArr, ListeCoupsNew),
	moteur(GrilleArr, ListeCoupsNew, AutreCamp).

% cas ou c est l utilisateur qui joue
moteur(Grille, ListeCoups, Camp) :-
  campCPU(CPU),
  campAdverse(Camp, CPU),
  jeu:saisieUnCoup(Grille, Col,Lig),
  valide(Col, Lig, Grille, Camp, CPU, ListeCoups).


% Si le coup est valide on le joue
valide(Col, Lig, Grille, Camp, CPU, _) :-
  jeu:leCoupEstValide(Col, Lig, Grille),
  joueLeCoup([Col,Lig], Camp, Grille, GrilleArr),
  nl, afficheGrille(GrilleArr), nl,
  toutesLesCasesValides(GrilleArr, ListeCoupsNew),
  moteur(GrilleArr, ListeCoupsNew, CPU).

% Si le coup n'est pas valide on prévient le joueur et il recommence
valide(Col, Lig, Grille, Camp, _, ListeCoups) :-
  \+ jeu:leCoupEstValide(Col, Lig, Grille),
  write("Coup invalide"), nl,
	moteur(Grille, ListeCoups, Camp).
