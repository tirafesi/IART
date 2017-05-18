/**
* This file implements everything related to the bots
*/

:- use_module(library(random)).
:- use_module(library(sets)).
:- ensure_loaded('board.pl').

/**
* Predicts best move for current player
*
* @param +Board: Current board
* @param +Player: Current player
* @param +Difficulty: 0 -> random move, 1+ -> depth of minimax algorithm
* @param -Move: Best move determined by thinkMove
*/
thinkMove(Board, Player, 0, Move):-
	getAllValidMoves(Board, Player, Plays),
	length(Plays, NPlays),
	random(0, NPlays, ChosenPlay),
	find(ChosenPlay, Plays, Move).
thinkMove(Board, Player, Difficulty, Move) :-
	minimax(Board, max, Player, 0, Difficulty, Move, _).

/**
* Gets list of valid moves
*
* @param +Board: Current board
* @param +Player: Current player
* @param -Plays: List of valid moves
*/

getAllValidMoves(Board, Player, Plays) :-
	findall(
		OOCol-OORow-NNCol-NNRow,
		validatePlay(Board, Player, OOCol, OORow, NNCol, NNRow),
		Plays
	).

/**
* Gets score of player on current game state
*
* @param +Board: Current game state
* @param +Player: Current player
* @param -Score: Player score
*/

getScore(_, atkplayer, Score) :- Score = 1.
getScore(_, defplayer, Score) :- Score = -1.

/**
* Maximizing level of minimax algorithm
*
* @param +Board: Current game state
* @param +ListMoves: List of valid moves
* @param +Depth: Current depth
* @param +Difficulty: Depth of minimax algorithm
* @param +Player: Current player
* @param +Eant: Previous best game state
* @param +Alpha: Alpha acts like max in MiniMax
* @param -Eres: Maximizing move
* @param -Vres: Score of maximizing move
* @param +Beta: Beta cut-off
*/

maxValue(_, [], _, _, _, E, V, E, V, _).
maxValue(Board, [OCol-ORow-NCol-NRow|OEs], Depth, Difficulty, Player, Eant, Alpha, Eres, Vres, Beta):-
	Depth1 is Depth + 1,
	move(Board, OCol, ORow, NCol, NRow, B1),
	switchPlayer(Player, NP),
	minimax(B1, min, NP, Depth1, Difficulty, _, V1),
	((V1 > Alpha, AlphaAux = V1, Eaux = OCol-ORow-NCol-NRow)
	; (AlphaAux = Alpha, Eaux = Eant)),
	((V1 >= Beta, Eres = OCol-ORow-NCol-NRow, Vres = Beta)
	; maxValue(Board, OEs, Depth, Difficulty, Player, Eaux, AlphaAux, Eres, Vres, Beta)).

/**
* Minimizing level of minimax algorithm
*
* @param +Board: Current game state
* @param +ListMoves: List of valid moves
* @param +Depth: Current depth
* @param +Difficulty: Depth of minimax algorithm
* @param +NP: Next player
* @param +Eant: Previous best game state
* @param +Beta: Beta acts like min in MiniMax
* @param -Eres: Minimizing move
* @param -Vres: Score of minimizing move
* @param +Alpha: Alpha cut-off
*/	

minValue(_, [], _, _, _, E, V, E, V, _).
minValue(Board, [OCol-ORow-NCol-NRow|OEs], Depth, Difficulty, NP, Eant, Beta, Eres, Vres, Alpha):-
	Depth1 is Depth + 1,
	move(Board, OCol, ORow, NCol, NRow, B1),
	switchPlayer(NP, Player),
	minimax(B1, max, Player, Depth1, Difficulty, _, V1),
	((V1 < Beta, BetaAux = V1, Eaux = OCol-ORow-NCol-NRow)
	; (BetaAux = Beta, Eaux = Eant)),
	((V1 =< Alpha, Eres = OCol-ORow-NCol-NRow, Vres = Alpha)
	; minValue(Board, OEs, Depth, Difficulty, NP, Eaux, BetaAux, Eres, Vres, Alpha)).

/**
* Minimax algorithm
*
* @param +Board: Current game state
* @param +Level: max or min
* @param +Player: Current player
* @param +Depth: Current depth
* @param +Difficulty: Depth of minimax algorithm
* @param -Move: Best move determined by minimax algorithm
* @param -Value: Score of best move
*/
	
minimax(Board, max, Player, Depth, Difficulty, Move, Value):-
	Depth \= Difficulty,
	getAllValidMoves(Board, Player, ListMoves),
	maxValue(Board, ListMoves, Depth, Difficulty, Player, _, -9999, Move, Value, 9999).
	
minimax(Board, min, NextPlayer, Depth, Difficulty, Move, Value):-
	Depth \= Difficulty,
	getAllValidMoves(Board, NextPlayer, ListMoves),
	minValue(Board, ListMoves, Depth, Difficulty, NextPlayer, _, 9999, Move, Value, -9999).
	
minimax(Board, _, Player, _, _, OCol-ORow-NCol-NRow, Value) :-
	move(Board, OCol, ORow, NCol, NRow, NewBoard),
	getScore(NewBoard, Player, Value).