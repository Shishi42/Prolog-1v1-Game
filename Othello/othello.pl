
/** <module> Othello
 *
 *  Ce module permet de jouer au jeu de Othello
 *
 *  @author Mano Brabant
 */
:- module(jeu, []).


:- consult('../moteurJ2J/outils.pl').


%% initJeu
%
%  Ce prédicat permet d'initialiser la taille de la grille.
initJeu :-
  moteur:init(8, h).


%% profondeurMinMax(?Val:int)
%
% Ce predicat est satisfait quand la valeur Val correspond à la profondeur jusqu'à laquelle peut aller
% un algorithme minmax pour ce jeu.
profondeurMinMax(4).


%% leCoupEstValide(+Colonne:char, +Ligne:int, +Grille:Grille)
% @see [[leCoupEstValide/3]]
% Cette méthode permet de savoir si on peut jouer dans une case dans une grille donnée
%
% @param Colonne La colonne de la case à vérifier
% @param Ligne La ligne de la case à vérifier
% @param Grille La grille dans laquelle on vérifie la case
leCoupEstValide(J,C,L,G) :- outils:coordonneesOuListe(C, L, CL), leCoupEstValide(J, G, CL).


%% partieGagnee(+Val:char, +Grille:Grille)
%
% Cette méthode permet de savoir si une grille est gagnante pour un joueur
% Il n'y a pas de situation gagnante à l'othello, on dertermine le gagant avec un score en fin de partie
%
% @param Val La valeur à vérifier
% @param Grille La grille à vérifier
partieGagnee(_, _) :- fail.



%% toutesLesCasesDepart(+Camp:any, ?ListeCases:list)
%
% Cette méthode permet de récupérer toutes les cases de départ pour un joueur
%
% @param Camp Le joueur pour lequelle on cherche les cases de départ
% @param ListeCases La liste des cases où l'on peut jouer
toutesLesCasesDepart(C, N) :- grilleDeDepart(G), moteur:toutesLesCasesValides(C, G, N).



%% grilleDeDepart(?Grille:Grille)
%
% Cette méthode permet de récupérer la grille de départ du jeu
%
% @param Grille La grille de départ
grilleDeDepart(G) :- moteur:size(SL, SCA), moteur:equiv(SCA, SC), moteur:caseVide(Cv),
	outils:replicate(Cv, SC, L), outils:replicate(L, SL, G1),
  outils:modifieGrille(G1, x, [[e,4],[d,5]], G2),
  outils:modifieGrille(G2, o, [[e,5],[d,4]], G).



%% terminal(+Joueur:any, +Grille:grille)
%
% Ce prédicat est satisfait si la Grille est une grille "terminale" pour le Joueur
%
% Un grille terminale est une grille dans laquelle un joueur spécifique ne peut pas jouer
%
% @param Joueur Le joueur que l'on vérifie pour la Grille
% @param Grille la grille que l'on vérifie pour le Joueur 
terminal(J, G) :- moteur:toutesLesCasesValides(J, G, LC), length(LC, L), L == 0.




%% eval(+Grille:grille, +Joueur:any, ?Eval:int)
%
% Ce prédicat permet d'évaluer une grille pour un joueur
%
% L'évaluation représente si le Joueur donnée à l'avantage ou non dans la Grille
%
% Plus la valeur Eval est grande plus la Grille est intéréssante pour le Joueur
%
% On utilise ce prédicat pour la fonction minmax
%
% @param Grille La grille à évaluer
% @param Joueur Le joueur pour lequelle on va évaluer la grille
% @param Eval Une valeur représentative de l'avantage du Joueur dans la Grille
%eval(G, J, _) :- moteur:afficheGrille(G), nl, write(J), nl, fail.

eval(G, J, N) :- score(G, J, NJ), moteur:campAdverse(J, A), score(G, A, NA), N is NJ - NA.

eval(_,_,5) :- !.

%% consequencesCoupDansGrille(+Colonne:char, +Ligne:int, +Camp:any, +GrilleDep:grille, ?GrilleArr:grille)
%
% Ce prédicat est satisfait quand la GrilleArr est égale à la GrilleDep avec
% les conséquences d'avoir joué dans la case [Colonne, Ligne]
%
% @param Colonne Le nom de la colonne dans laquelle on a joué
% @param Ligne Le numéro de la ligne dans laquelle on a joué
% @param Camp Le joueur qui a joué dans la grille
% @param GrilleDep La grille de jeu sans les conséquences du coup dans la case [Colonne, Ligne]
% @param GrilleArr La grille de jeu avec les conséquences du coup dans la case [Colonne, Ligne]
consequencesCoupDansGrille(Colonne, Ligne, Camp, Grille0, GrilleArr) :-
  mangePion(1,Camp,Grille0,Grille1,[Colonne,Ligne]),
  mangePion(2,Camp,Grille1,Grille2,[Colonne,Ligne]),
  mangePion(3,Camp,Grille2,Grille3,[Colonne,Ligne]),
  mangePion(4,Camp,Grille3,Grille4,[Colonne,Ligne]),
  mangePion(5,Camp,Grille4,Grille5,[Colonne,Ligne]),
  mangePion(6,Camp,Grille5,Grille6,[Colonne,Ligne]),
  mangePion(7,Camp,Grille6,Grille7,[Colonne,Ligne]),
  mangePion(8,Camp,Grille7,GrilleArr,[Colonne,Ligne]),!.


%% determineGagnant(+Grille:grille)
%
% Ce prédicat permet d'afficher qui à gagné dans une grille donnée
%
% @param Grille La grille que l'on vérifie
determineGagnant(G) :- score(G, x, ScoreX), score(G, o, ScoreO), ScoreX > ScoreO, write('le camp '), write(x), write(' a gagne').
determineGagnant(G) :- score(G, x, ScoreX), score(G, o, ScoreO), ScoreX < ScoreO, write('le camp '), write(o), write(' a gagne').
determineGagnant(_) :- nl, write('egalité').


%% saisieUnCoup(+Grille:Grille, ?NomColonne:char, ?NumLigne:int)
%
% Cette méthode permet de demander à l'utilisateur de saisir un coup
%
% @param Grille La grille dans laquelle le joueur va jouer son coup
% @param NomColonne Le nom de la colonne dans laquelle le joueur va jouer son coup
% @param NumLigne Le numéro de la ligne dans laquelle le joueur va jouer son coup
saisieUnCoup(_, NomCol,NumLig) :-
	write("entrez le nom de la colonne a jouer : "),
  outils:listeNomColonne(LNC),
  writeln(LNC),
	read(NomCol), nl,
	write("entrez le numero de ligne a jouer : "),
  outils:listeNumLigne(LNL),
  writeln(LNL),
	read(NumLig),nl.

























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Le jeu d othello
%   -> regles.pl : module de modelisation des regles du jeu.
%
% Dependances :
%   -> othello.pl : module principal qui charge tous les modules necessaires au deroulement du jeu.
%   -> representation.pl : module de représentation du jeu (affichage, manipulation de la grille, etc).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% gestion des directions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% indiquer la direction selon la position par rapport à la case en cours C :
%  1  2  3
%  8  C  4
%  7  6  5
% ce qui donne en se servant de succnum et succ alpha :
% Predicat : caseSuivante/3
% Usage : caseSuivante(Direction,Case,CaseSuivante)

caseSuivante(1,[Colonne,Ligne],[ColonneSuiv,LigneSuiv]):-
	moteur:succAlpha(ColonneSuiv,Colonne),
	moteur:succNum(LigneSuiv,Ligne),!.

caseSuivante(2,[Colonne,Ligne],[Colonne,LigneSuiv]):-
	moteur:succNum(LigneSuiv,Ligne),!.

caseSuivante(3,[Colonne,Ligne],[ColonneSuiv,LigneSuiv]):-
	moteur:succAlpha(Colonne,ColonneSuiv),
	moteur:succNum(LigneSuiv,Ligne),!.

caseSuivante(4,[Colonne,Ligne],[ColonneSuiv,Ligne]):-
	moteur:succAlpha(Colonne,ColonneSuiv),!.

caseSuivante(5,[Colonne,Ligne],[ColonneSuiv,LigneSuiv]):-
	moteur:succAlpha(Colonne,ColonneSuiv),
	moteur:succNum(Ligne,LigneSuiv),!.

caseSuivante(6,[Colonne,Ligne],[Colonne,LigneSuiv]):-
	moteur:succNum(Ligne,LigneSuiv),!.

caseSuivante(7,[Colonne,Ligne],[ColonneSuiv,LigneSuiv]):-
	moteur:succAlpha(ColonneSuiv,Colonne),
	moteur:succNum(Ligne,LigneSuiv),!.

caseSuivante(8,[Colonne,Ligne],[ColonneSuiv,Ligne]):-
	moteur:succAlpha(ColonneSuiv,Colonne),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat : leCoupEstValide/3
% Usage : leCoupEstValide(Camp,Grille,Coup) verifie qu il n y a rien dans
%         la case et que le pion va entoure des pions adverses
% ce qui est equivalent a leCoupEstValide/4 en decomposant le coup en ligne/colonne
leCoupEstValide(Camp,Grille,[Colonne,Ligne]):-
  moteur:caseVide(Cv),
	moteur:caseDeGrille(Colonne,Ligne,Grille,Cv),
	lePionEncadre(_Direction,Camp,Grille,[Colonne,Ligne]),!.


% Predicat : lePionEncadre/4
% Usage : lePionEncadre(Direction,Camp,Grille,Case) verifie qu il existe
%	  un pion adverse dans une des directions autour du pion
%     utilise la question 8 pour les direction

lePionEncadre(Direction,Camp,Grille,Case):-
    % on verifie la valeur de la direction
	member(Direction,[1,2,3,4,5,6,7,8]),
	% on parcourt la case suivante dans une direction donnee
	caseSuivante(Direction,Case,[ColonneSuiv,LigneSuiv]),
	% on cherche si il y a un adversaire dans cette position
	moteur:campAdverse(Camp,CampAdv),
	moteur:caseDeGrille(ColonneSuiv,LigneSuiv,Grille,CampAdv),
	% on regarde si il y a bien un pion a 'nous' dans la case suivante
	caseSuivante(Direction,[ColonneSuiv,LigneSuiv],Case3),
	trouvePion(Direction,Camp,Grille,Case3),!.


% Predicat : trouvePion/4
% Usage : trouvePion(Direction,Camp,Grille,Case) verifie que le pion adverse
%            est bien entoure de l autre cote par un pion du Camp

trouvePion(_Direction,Camp,Grille,[Colonne,Ligne]):-
	moteur:caseDeGrille(Colonne,Ligne,Grille,Camp),!.

trouvePion(Direction,Camp,Grille,[Colonne,Ligne]):-
	moteur:campAdverse(Camp,CampAdv),
	moteur:caseDeGrille(Colonne,Ligne,Grille,CampAdv),
	caseSuivante(Direction,[Colonne,Ligne],CaseSuiv),
	trouvePion(Direction,Camp,Grille,CaseSuiv).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  --> placer le pion ou on veut jouer
%%%  --> retourner les autres pions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat : placePionDansLigne/4
% Usage : placePionDansLigne(NomCol,Val,LigneDep,LigneArr) est satisfait si LigneArr
%         peut etre obtenue a partir de LigneDep en jouant le coup valide qui consiste
%         a mettre la valeur Val en NomCol, NumLig.
%	  On suppose donc que le coup que l on desire jouer est valide.

placePionDansLigne(a,Val,[_|SuiteLigneDep],[Val|SuiteLigneDep]):-!.

placePionDansLigne(NomCol,Val,[Tete|SuiteLigneDep],[Tete|SuiteLigneArr]):-
	moteur:succAlpha(Predecesseur,NomCol),
	placePionDansLigne(Predecesseur,Val,SuiteLigneDep,SuiteLigneArr).


% Predicat : placePionDansGrille/5
% Usage : placePionDansGrille(NomCol,NumLig,Val,GrilleDep,GrilleArr) est satisfait
%         si GrilleArr est obtenue a partir de GrilleDep dans laquelle on a joue
%         Val en NomCol, NumLig, et cela etant d autre part un coup valide.

placePionDansGrille(NomCol,1,Val,[Ligne1|SuiteGrille],[Ligne2|SuiteGrille]):-
	placePionDansLigne(NomCol,Val,Ligne1,Ligne2),!.

placePionDansGrille(NomCol,NumLig,Val,[Ligne1|SuiteGrilleDep],[Ligne1|SuiteGrilleArr]):-
	moteur:succNum(Predecesseur,NumLig),
	placePionDansGrille(NomCol,Predecesseur,Val,SuiteGrilleDep,SuiteGrilleArr).



% Predicat : mangePion/5
% Usage : mangePion(Direction,Camp,Grille,GrilleArr,Case) retourne les pions entoures

mangePion(Direction,_Camp,Grille,Grille,Case):-
	not(caseSuivante(Direction,Case,_CaseSuiv)),!.

mangePion(Direction,Camp,Grille,Grille,Case):-
	caseSuivante(Direction,Case,CaseSuiv),
	not(trouvePion(Direction,Camp,Grille,CaseSuiv)),!.

mangePion(Direction,Camp,Grille,Grille,Case):-
	caseSuivante(Direction,Case,[Colonne,Ligne]),
	moteur:caseDeGrille(Colonne,Ligne,Grille,Camp),!.

mangePion(Direction,Camp,Grille,GrilleArr,Case):-
	caseSuivante(Direction,Case,[Colonne,Ligne]),
	trouvePion(Direction,Camp,Grille,[Colonne,Ligne]),
	moteur:campAdverse(Camp,CampAdv),
	moteur:caseDeGrille(Colonne,Ligne,Grille,CampAdv),
	placePionDansGrille(Colonne,Ligne,Camp,Grille,GrilleProv),
	mangePion(Direction,Camp,GrilleProv,GrilleArr,[Colonne,Ligne]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  --> placer le pion ou on veut jouer
%%%  --> retourner les autres pions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Predicat : joueLeCoupDansGrille/4
% Usage : joueLeCoupDansGrille(Camp,Coups,Grille,GrilleArr) place le pion
%         Camp dans la Grille, retourne les pions entoures puis rend
%         la Grille d arrivee GrilleArr
/*
joueLeCoupDansGrille(Camp,[Colonne,Ligne],Grille,GrilleArr):-
        leCoupEstValide(Camp,Grille,[Colonne,Ligne]),
	placePionDansGrille(Colonne,Ligne,Camp,Grille,_Grille0),
	mangePion(1,Camp,_Grille0,_Grille1,[Colonne,Ligne]),
	mangePion(2,Camp,_Grille1,_Grille2,[Colonne,Ligne]),
	mangePion(3,Camp,_Grille2,_Grille3,[Colonne,Ligne]),
	mangePion(4,Camp,_Grille3,_Grille4,[Colonne,Ligne]),
	mangePion(5,Camp,_Grille4,_Grille5,[Colonne,Ligne]),
	mangePion(6,Camp,_Grille5,_Grille6,[Colonne,Ligne]),
	mangePion(7,Camp,_Grille6,_Grille7,[Colonne,Ligne]),
	mangePion(8,Camp,_Grille7,GrilleArr,[Colonne,Ligne]),!.
*/




























%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat : scoreLigne/3
% Usage : scoreLigne(Ligne,Camp,Score) donne le nombre de pion Camp dans
%	  la ligne de grille Ligne

scoreLigne([],_Camp,0):-!.

scoreLigne([Camp|Suite],Camp,Score):-
	scoreLigne(Suite,Camp,Score1),
	Score is Score1 +1.

scoreLigne([Tete|Suite],Camp,Score):-
	Tete \== Camp,
	scoreLigne(Suite,Camp,Score).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat : score/3
% Usage : score(Grille,Camp,Score) donne le nombre de pion Camp dans la
%         grille Grille

score([],_Camp,0):-!.

score([Ligne1|Suite],Camp,Score):-
	scoreLigne(Ligne1,Camp,Score1),
	score(Suite,Camp,Score2),
	Score is Score1 + Score2.
