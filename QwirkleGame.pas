{ Turn handling (human and AI), end-of-game winner rules, and the four game
  modes: 2 players, 4 players, player vs AI, and AI vs AI. }
unit QwirkleGame;

{$mode objfpc}

interface

uses
  crt, SysUtils,
  QwirkleTypes, QwirkleDeck, QwirkleBoard, QwirkleDisplay, QwirkleAI;

procedure RunTwoPlayerGame;
procedure RunFourPlayerGame;
procedure RunPlayerVsAIGame;
procedure RunAIvsAIGame;

implementation

{ Asks a human player which tile to play and where, then applies the move.
  x and y receive the chosen board position (0, 0 on failure). }
procedure PlayTurnHuman(var hand: THand; var board: TBoard; var firstX, firstY, tileCount, x, y: Integer;
  var lineHorizontal, lineVertical, isAI: Boolean);
var
  handSlot, right, left, top, bottom, parseError, tileCountBefore: Integer;
  color, shape: Char;
  input: string;
begin
  tileCountBefore := tileCount;
  DrawBoard(board, right, left, top, bottom);
  Writeln('-- Voici votre main  : ');
  DrawHand(hand);
  Writeln;

  repeat
    repeat
      Writeln('quel pion souhaitez-vous jouer ? (indiquez le numero de la case correspondante dans votre main)  :');
      Readln(input);
      Val(input, handSlot, parseError);
    until parseError = 0;
  until (handSlot < 7) and (handSlot > 0) and (hand[handSlot].Color <> EMPTY);

  color := hand[handSlot].Color;
  shape := hand[handSlot].Shape;
  Writeln('A present, choisissez a quelle position vous souhaitez placer votre pion :');
  repeat
    Writeln('En x :');
    Readln(input);
    Val(input, x, parseError);
  until parseError = 0;
  repeat
    Writeln('En y :');
    Readln(input);
    Val(input, y, parseError);
  until parseError = 0;

  board := PlaceTile(x, y, firstX, firstY, color, shape, board, tileCount, lineHorizontal, lineVertical, isAI);
  DrawBoard(board, right, left, top, bottom);
  if tileCountBefore <> tileCount then
  begin
    hand[handSlot].Color := EMPTY;
    hand[handSlot].Shape := EMPTY;
  end;
end;

{ First turn of a game: firstX/firstY is the anchor tile already on the
  board (the game-opening tile placed before this call). }
procedure PlayerTurnFirst(var player: TPlayer; var hand: THand; var board: TBoard; var deck: PDeckNode;
  var tileCount, firstX, firstY: Integer; var placedCoords: TCoordList;
  var lineHorizontal, lineVertical, isAI: Boolean);
var
  handSlot, right, left, top, bottom, turnPoints, tileCountBefore, x, y: Integer;
  choice, again: Char;
begin
  turnPoints := 0;
  repeat
    Writeln('Souhaitez-vous placer un/des pion/s ou bien changer des pions de votre main ou alors passer votre tour ?  J/E/P ( jouer/echanger/passer)  :');
    Readln(choice);
  until (choice = 'J') or (choice = 'j') or (choice = 'E') or (choice = 'e') or (choice = 'P') or (choice = 'p');

  if (choice = 'J') or (choice = 'j') then
  begin
    repeat
      tileCountBefore := tileCount;
      PlayTurnHuman(hand, board, firstX, firstY, tileCount, x, y, lineHorizontal, lineVertical, isAI);
      if tileCountBefore <> tileCount then
        turnPoints := ScoreMove(x, y, board, placedCoords, tileCount);
      Writeln('Voulez-vous continuer a placer des pions ? Y/N :');
      Readln(again);
    until (again = 'N') or (again = 'n');
    player.Score := player.Score + turnPoints;
    hand := RefillHand(hand, deck);
  end;

  if (choice = 'E') or (choice = 'e') then
  begin
    repeat
      Writeln('Quel pion de votre main souhaitez-vous echanger ? (indiquez le numero de la case correspondante dans votre main)  :');
      Readln(handSlot);
      if (handSlot < 7) and (handSlot > 0) then
      begin
        if hand[handSlot].Color <> EMPTY then
        begin
          ReturnTileToDeck(hand[handSlot], deck);
          hand[handSlot].Color := EMPTY;
          hand[handSlot].Shape := EMPTY;
        end
        else
          Writeln('Entrez un numero de case contenant un pion');
      end
      else
        Writeln('Entrez un numero de case valide');
      Writeln('Voulez-vous continuer a echanger des pions ? Y/N :');
      Readln(again);
    until (again = 'N') or (again = 'n');
    hand := RefillHand(hand, deck);
  end;

  hand := RefillHand(hand, deck);
  DrawBoard(board, right, left, top, bottom);
end;

{ Any turn after the first: there is no pre-existing anchor, so the first
  tile placed becomes its own anchor and the turn retries until one lands. }
procedure PlayerTurnNext(var player: TPlayer; var hand: THand; var board: TBoard; var deck: PDeckNode;
  var tileCount: Integer; var placedCoords: TCoordList;
  var lineHorizontal, lineVertical, isAI: Boolean);
var
  handSlot, right, left, top, bottom, turnPoints, tileCountBefore, firstX, firstY, x, y: Integer;
  choice, again: Char;
begin
  turnPoints := 0;
  repeat
    Writeln('Souhaitez-vous placer un/des pion/s ou bien changer des pions de votre main  ou alors de passer votre tour?  J/E/P ( jouer/echanger/passer)  :');
    Readln(choice);
  until (choice = 'J') or (choice = 'j') or (choice = 'E') or (choice = 'e') or (choice = 'P') or (choice = 'p');

  if (choice = 'J') or (choice = 'j') then
  begin
    again := 'Y';
    repeat
      tileCountBefore := tileCount;
      PlayTurnHuman(hand, board, x, y, tileCount, x, y, lineHorizontal, lineVertical, isAI);
      firstX := x;
      firstY := y;
      if tileCountBefore <> tileCount then
        turnPoints := ScoreMove(x, y, board, placedCoords, tileCount);
      Writeln('Voulez-vous continuer a placer des pions ? Y/N :');
      Readln(again);
    until (tileCount = 1) or (again = 'N') or (again = 'n');

    if (again = 'Y') or (again = 'y') then
      repeat
        tileCountBefore := tileCount;
        PlayTurnHuman(hand, board, firstX, firstY, tileCount, x, y, lineHorizontal, lineVertical, isAI);
        if tileCountBefore <> tileCount then
          turnPoints := ScoreMove(x, y, board, placedCoords, tileCount);
        Writeln('Voulez-vous continuer a placer des pions ? Y/N :');
        Readln(again);
      until (again = 'N') or (again = 'n');
    player.Score := player.Score + turnPoints;
    hand := RefillHand(hand, deck);
  end;

  if (choice = 'E') or (choice = 'e') then
  begin
    repeat
      Writeln('Quel pion de votre main souhaitez-vous echanger ? (indiquez le numero de la case correspondante dans votre main)  :');
      Readln(handSlot);
      if (handSlot < 7) and (handSlot > 0) then
      begin
        if hand[handSlot].Color <> EMPTY then
        begin
          ReturnTileToDeck(hand[handSlot], deck);
          hand[handSlot].Color := EMPTY;
          hand[handSlot].Shape := EMPTY;
        end
        else
          Writeln('Entrez un numero de case contenant un pion');
      end
      else
        Writeln('Entrez un numero de case valide');
      Writeln('Voulez-vous continuer a echanger des pions ? Y/N :');
      Readln(again);
    until (again = 'N') or (again = 'n');
    hand := RefillHand(hand, deck);
  end;

  hand := RefillHand(hand, deck);
  DrawBoard(board, right, left, top, bottom);
end;

{ Lets the AI play a full turn (up to 6 tiles), or return its hand to the
  deck and draw a fresh one when it has no legal move. }
procedure PlayTurnAI(var player: TPlayer; var hand: THand; var board: TBoard;
  lineHorizontal, lineVertical, isAI: Boolean; var deck: PDeckNode);
var
  moves: TMoveList;
  right, left, top, bottom, tileCount, tileCountBefore, handSlot, turnPoints: Integer;
  placedCoords: TCoordList;
begin
  turnPoints := 0;
  tileCount := 0;
  DrawBoard(board, right, left, top, bottom);
  moves := ComputeAIMove(hand, board, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
  Writeln;

  if (moves[1].X <> 0) or (moves[1].Y <> 0) then
  begin
    board := PlaceTile(moves[1].X, moves[1].Y, moves[1].X, moves[1].Y, hand[moves[1].HandIndex].Color,
      hand[moves[1].HandIndex].Shape, board, tileCount, lineHorizontal, lineVertical, isAI);
    turnPoints := ScoreMove(moves[1].X, moves[1].Y, board, placedCoords, tileCount);
    DrawBoard(board, right, left, top, bottom);
    if tileCount <> 0 then
    begin
      hand[moves[1].HandIndex].Color := EMPTY;
      hand[moves[1].HandIndex].Shape := EMPTY;
    end;
  end
  else if (moves[1].X = 0) or (moves[1].Y = 0) then
  begin
    for handSlot := 1 to HAND_SIZE do
      if hand[handSlot].Color <> EMPTY then
      begin
        ReturnTileToDeck(hand[handSlot], deck);
        hand[handSlot].Color := EMPTY;
        hand[handSlot].Shape := EMPTY;
      end;
    hand := RefillHand(hand, deck);
  end;

  for handSlot := 2 to HAND_SIZE do
    if moves[handSlot].HandIndex <> 0 then
    begin
      tileCountBefore := tileCount;
      board := PlaceTile(moves[handSlot].X, moves[handSlot].Y, moves[1].X, moves[1].Y,
        hand[moves[handSlot].HandIndex].Color, hand[moves[handSlot].HandIndex].Shape,
        board, tileCount, lineHorizontal, lineVertical, isAI);
      if tileCountBefore <> tileCount then
      begin
        turnPoints := ScoreMove(moves[handSlot].X, moves[handSlot].Y, board, placedCoords, tileCount);
        hand[moves[handSlot].HandIndex].Color := EMPTY;
        hand[moves[handSlot].HandIndex].Shape := EMPTY;
      end;
      DrawBoard(board, right, left, top, bottom);
    end;

  player.Score := player.Score + turnPoints;
end;

function DetermineWinner2(name1, name2: string; score1, score2: Integer): string;
begin
  if score1 < score2 then
    Result := name2;
  if score1 > score2 then
    Result := name1;
  if score1 = score2 then
    Result := name1 + ',' + name2;
end;

function DetermineWinner4(name1, name2, name3, name4: string;
  score1, score2, score3, score4: Integer): string;
var
  players: array[1..4] of TPlayer;
  i, bestScore: Integer;
  winners: string;
begin
  players[1].Name := name1; players[1].Score := score1;
  players[2].Name := name2; players[2].Score := score2;
  players[3].Name := name3; players[3].Score := score3;
  players[4].Name := name4; players[4].Score := score4;

  bestScore := players[1].Score;
  for i := 2 to 4 do
    if players[i].Score > bestScore then
      bestScore := players[i].Score;

  winners := '';
  for i := 1 to 4 do
    if players[i].Score = bestScore then
    begin
      if winners = '' then
        winners := players[i].Name
      else
        winners := winners + ',' + players[i].Name;
    end;
  Result := winners;
end;

{ Reads a player's chosen hand slot for the very first tile of the game and
  places it at the board's center (0, 0). }
procedure PlaceOpeningTile(var player: TPlayer; var hand: THand; var board: TBoard; var tileCount: Integer);
var
  right, left, top, bottom, slot, parseError: Integer;
  input: string;
  placedCoords: TCoordList;
begin
  Writeln('------------------------------------------------');
  Writeln('-- ', player.Name, ', c''est a vous de commencer !!');
  Readln;
  Writeln('-- Pour commencer, veuillez choisir un pion de votre main qui sera place au centre de la grille, (entez son numero de case) :');
  Writeln('---------------------------------------------------------------------------------------------------');
  Writeln('-- Voici votre main : ');
  DrawHand(hand);
  Writeln;
  repeat
    Readln(input);
    Val(input, slot, parseError);
  until (slot < 7) and (slot > 0) and (parseError = 0);
  board[0, 0].Color := hand[slot].Color;
  board[0, 0].Shape := hand[slot].Shape;
  hand[slot].Color := EMPTY;
  hand[slot].Shape := EMPTY;
  tileCount := 1;
  ScoreMove(0, 0, board, placedCoords, tileCount);
  Writeln;
  DrawBoard(board, right, left, top, bottom);
end;

procedure RunTwoPlayerGame;
var
  hand1, hand2: THand;
  canPlay1, canPlay2: Boolean;
  tileCount, right, left, top, bottom: Integer;
  board: TBoard;
  deck: PDeckNode;
  player1, player2: TPlayer;
  firstX, firstY: Integer;
  placedCoords: TCoordList;
  lineHorizontal, lineVertical, isAI: Boolean;
begin
  lineHorizontal := false;
  lineVertical := false;
  isAI := false;
  Writeln('----------------------------------------------------------------------------------------------------------------------------------');
  Writeln('-- Ensuite, entrez votre pseudo en tant que joueur, il faut savoir que le joueur 1 commence en premier... Hein faut le savoir : --');
  Writeln('----------------------------------------------------------------------------------------------------------------------------------');
  Readln;
  ClrScr;
  Writeln('-- Pseudo joueur 1 :');
  repeat
    Readln(player1.Name);
  until player1.Name <> '';
  Writeln('-- Pseudo joueur 2 :');
  repeat
    Readln(player2.Name);
  until player2.Name <> '';
  Writeln('--------------');
  Readln;
  ClrScr;
  Writeln('------------------------------------------');
  Writeln('-- Bien nous pouvons commencer a present, ');
  Writeln('------------------------------------------');
  Readln;
  ClrScr;

  player1.Score := 0;
  player2.Score := 0;
  hand1 := InitHand;
  hand2 := InitHand;
  board := InitBoard;
  deck := CreateDeck;
  hand1 := RefillHand(hand1, deck);
  firstX := 0;
  firstY := 0;

  PlaceOpeningTile(player1, hand1, board, tileCount);
  PlayerTurnFirst(player1, hand1, board, deck, tileCount, firstX, firstY, placedCoords, lineHorizontal, lineVertical, isAI);
  if player1.Score = 0 then
    player1.Score := 1;
  lineHorizontal := false;
  lineVertical := false;
  Readln;
  DrawScores2(player1, player2);
  Readln;

  repeat
    ClrScr;
    hand2 := RefillHand(hand2, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay2 := HasPlayableMove(board, hand2, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Writeln('-------------------------------------------');
    Writeln('-- ', player2.Name, ', c''est a vous de jouer :');
    Readln;
    tileCount := 0;
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand2);
    Writeln;
    PlayerTurnNext(player2, hand2, board, deck, tileCount, placedCoords, lineHorizontal, lineVertical, isAI);
    DrawScores2(player1, player2);
    Readln;
    lineHorizontal := false;
    lineVertical := false;
    canPlay2 := HasPlayableMove(board, hand2, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;

    ClrScr;
    Writeln('-------------------------------------------');
    Writeln('-- ', player1.Name, ', c''est a vous de jouer :');
    Readln;
    tileCount := 0;
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand1);
    Writeln;
    PlayerTurnNext(player1, hand1, board, deck, tileCount, placedCoords, lineHorizontal, lineVertical, isAI);
    DrawScores2(player1, player2);
    hand1 := RefillHand(hand1, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay1 := HasPlayableMove(board, hand1, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;
  until (deck = nil) or ((canPlay1 = false) and (canPlay2 = false))
     or ((CountTilesInHand(hand1) = 0) and (CountTilesInHand(hand2) = 0));

  ClrScr;
  Writeln('--------------------------------');
  Writeln('---- FIN DE LA PARTIE ----');
  Writeln('--------------------------------');
  Writeln;
  Writeln('Le gagnant est .............................');
  Readln;
  Writeln('------', DetermineWinner2(player1.Name, player2.Name, player1.Score, player2.Score));
end;

procedure RunFourPlayerGame;
var
  hand1, hand2, hand3, hand4: THand;
  canPlay1, canPlay2, canPlay3, canPlay4: Boolean;
  tileCount, right, left, top, bottom: Integer;
  board: TBoard;
  deck: PDeckNode;
  player1, player2, player3, player4: TPlayer;
  firstX, firstY: Integer;
  placedCoords: TCoordList;
  lineHorizontal, lineVertical, isAI: Boolean;
begin
  lineHorizontal := false;
  lineVertical := false;
  isAI := false;
  Writeln('----------------------------------------------------------------------------------------------------------------------------------');
  Writeln('-- Ensuite, entrez votre pseudo en tant que joueur, il faut savoir que le joueur 1 commence en premier... Hein faut le savoir : --');
  Writeln('----------------------------------------------------------------------------------------------------------------------------------');
  Readln;
  ClrScr;
  Writeln('-- Pseudo joueur 1 :');
  repeat
    Readln(player1.Name);
  until player1.Name <> '';
  Writeln('-- Pseudo joueur 2 :');
  repeat
    Readln(player2.Name);
  until player2.Name <> '';
  Writeln('-- Pseudo joueur 3 :');
  repeat
    Readln(player3.Name);
  until player3.Name <> '';
  Writeln('-- Pseudo joueur 4 :');
  repeat
    Readln(player4.Name);
  until player4.Name <> '';
  Writeln('--------------');
  Readln;
  ClrScr;
  Writeln('------------------------------------------');
  Writeln('-- Bien nous pouvons commencer a present, ');
  Writeln('------------------------------------------');
  Readln;
  ClrScr;

  player1.Score := 0;
  player2.Score := 0;
  player3.Score := 0;
  player4.Score := 0;
  hand1 := InitHand;
  hand2 := InitHand;
  hand3 := InitHand;
  hand4 := InitHand;
  board := InitBoard;
  deck := CreateDeck;
  hand1 := RefillHand(hand1, deck);
  firstX := 0;
  firstY := 0;

  PlaceOpeningTile(player1, hand1, board, tileCount);
  PlayerTurnFirst(player1, hand1, board, deck, tileCount, firstX, firstY, placedCoords, lineHorizontal, lineVertical, isAI);
  if player1.Score = 0 then
    player1.Score := 1;
  lineHorizontal := false;
  lineVertical := false;
  Readln;
  DrawScores4(player1, player2, player3, player4);
  Readln;

  repeat
    ClrScr;
    hand2 := RefillHand(hand2, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay2 := HasPlayableMove(board, hand2, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Writeln('-------------------------------------------');
    Writeln('-- ', player2.Name, ', c''est a vous de jouer :');
    Readln;
    tileCount := 0;
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand2);
    Writeln;
    PlayerTurnNext(player2, hand2, board, deck, tileCount, placedCoords, lineHorizontal, lineVertical, isAI);
    DrawScores4(player1, player2, player3, player4);
    Readln;

    ClrScr;
    Writeln('-------------------------------------------');
    Writeln('-- ', player3.Name, ', c''est a vous de jouer :');
    Readln;
    hand3 := RefillHand(hand3, deck);
    tileCount := 0;
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand3);
    Writeln;
    PlayerTurnNext(player3, hand3, board, deck, tileCount, placedCoords, lineHorizontal, lineVertical, isAI);
    DrawScores4(player1, player2, player3, player4);
    hand3 := RefillHand(hand3, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay3 := HasPlayableMove(board, hand3, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;

    ClrScr;
    Writeln('-------------------------------------------');
    Writeln('-- ', player4.Name, ', c''est a vous de jouer :');
    Readln;
    hand4 := RefillHand(hand4, deck);
    tileCount := 0;
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand4);
    Writeln;
    PlayerTurnNext(player4, hand4, board, deck, tileCount, placedCoords, lineHorizontal, lineVertical, isAI);
    DrawScores4(player1, player2, player3, player4);
    hand4 := RefillHand(hand4, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay4 := HasPlayableMove(board, hand4, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;

    ClrScr;
    Writeln('-------------------------------------------');
    Writeln('-- ', player1.Name, ', c''est a vous de jouer :');
    Readln;
    hand1 := RefillHand(hand1, deck);
    tileCount := 0;
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand1);
    Writeln;
    PlayerTurnNext(player1, hand1, board, deck, tileCount, placedCoords, lineHorizontal, lineVertical, isAI);
    DrawScores4(player1, player2, player3, player4);
    hand1 := RefillHand(hand1, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay1 := HasPlayableMove(board, hand1, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;
  until (deck = nil)
     or ((canPlay1 = false) and (canPlay2 = false) and (canPlay3 = false) and (canPlay4 = false))
     or ((CountTilesInHand(hand1) = 0) and (CountTilesInHand(hand2) = 0)
     and (CountTilesInHand(hand3) = 0) and (CountTilesInHand(hand4) = 0));

  ClrScr;
  Writeln('--------------------------------');
  Writeln('---- FIN DE LA PARTIE ----');
  Writeln('--------------------------------');
  Writeln;
  Writeln('Le gagnant est .............................');
  Readln;
  Writeln('------', DetermineWinner4(player1.Name, player2.Name, player3.Name, player4.Name,
    player1.Score, player2.Score, player3.Score, player4.Score));
end;

procedure RunPlayerVsAIGame;
var
  hand1, hand2: THand;
  canPlay1, canPlay2: Boolean;
  tileCount, right, left, top, bottom: Integer;
  board: TBoard;
  deck: PDeckNode;
  player1, player2: TPlayer;
  firstX, firstY: Integer;
  placedCoords: TCoordList;
  lineHorizontal, lineVertical, isAI: Boolean;
begin
  lineHorizontal := false;
  lineVertical := false;
  isAI := false;
  Writeln('-------------------------------------------------------------');
  Writeln('-- Ensuite, entrez votre pseudo en tant que joueur : --');
  Writeln('-------------------------------------------------------------');
  Readln;
  ClrScr;
  Writeln('-- Votre pseudo  :');
  repeat
    Readln(player1.Name);
  until player1.Name <> '';
  player2.Name := 'IA';
  Writeln('--------------');
  Readln;
  ClrScr;
  Writeln('------------------------------------------');
  Writeln('-- Bien nous pouvons commencer a present, ');
  Writeln('------------------------------------------');
  Readln;
  ClrScr;

  player1.Score := 0;
  player2.Score := 0;
  hand1 := InitHand;
  hand2 := InitHand;
  board := InitBoard;
  deck := CreateDeck;
  hand1 := RefillHand(hand1, deck);
  firstX := 0;
  firstY := 0;

  PlaceOpeningTile(player1, hand1, board, tileCount);
  PlayerTurnFirst(player1, hand1, board, deck, tileCount, firstX, firstY, placedCoords, lineHorizontal, lineVertical, isAI);
  if player1.Score = 0 then
    player1.Score := 1;
  lineHorizontal := false;
  lineVertical := false;
  Readln;
  DrawScores2(player1, player2);
  Readln;

  repeat
    ClrScr;
    hand2 := RefillHand(hand2, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay2 := HasPlayableMove(board, hand2, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    tileCount := 0;
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand2);
    Writeln;
    Readln;
    isAI := true;
    PlayTurnAI(player2, hand2, board, lineHorizontal, lineVertical, isAI, deck);
    isAI := false;
    DrawHand(hand2);
    DrawScores2(player1, player2);
    Readln;
    lineHorizontal := false;
    lineVertical := false;
    canPlay2 := HasPlayableMove(board, hand2, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;

    ClrScr;
    Writeln('-------------------------------------------');
    Writeln('-- ', player1.Name, ', c''est a vous de jouer :');
    Readln;
    tileCount := 0;
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand1);
    Writeln;
    PlayerTurnNext(player1, hand1, board, deck, tileCount, placedCoords, lineHorizontal, lineVertical, isAI);
    DrawScores2(player1, player2);
    hand1 := RefillHand(hand1, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay1 := HasPlayableMove(board, hand1, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;
  until (deck = nil) or ((canPlay1 = false) and (canPlay2 = false))
     or ((CountTilesInHand(hand1) = 0) and (CountTilesInHand(hand2) = 0));

  ClrScr;
  Writeln('--------------------------------');
  Writeln('---- FIN DE LA PARTIE ----');
  Writeln('--------------------------------');
  Writeln;
  Writeln('Le gagnant est .............................');
  Readln;
  Writeln('------', DetermineWinner2(player1.Name, player2.Name, player1.Score, player2.Score));
end;

procedure RunAIvsAIGame;
var
  hand1, hand2: THand;
  canPlay1, canPlay2: Boolean;
  right, left, top, bottom, firstTileSlot: Integer;
  board: TBoard;
  deck: PDeckNode;
  player1, player2: TPlayer;
  lineHorizontal, lineVertical, isAI: Boolean;
begin
  lineHorizontal := false;
  lineVertical := false;
  isAI := true;
  ClrScr;
  player1.Name := 'IA-1';
  player2.Name := 'IA-2';
  Writeln('------------------------------------------');
  Writeln('-- Bien nous pouvons commencer a present, ');
  Writeln('------------------------------------------');
  Writeln('-- Appuyez sur entrer pour lancer le match d''IA !!  --');
  Readln;
  ClrScr;

  player1.Score := 0;
  player2.Score := 0;
  hand1 := InitHand;
  hand2 := InitHand;
  board := InitBoard;
  deck := CreateDeck;
  hand1 := RefillHand(hand1, deck);
  Writeln('La main de l''IA qui commence le jeu est la suivante :');
  DrawHand(hand1);
  Writeln;
  Randomize;
  firstTileSlot := Random(5) + 1;
  board[0, 0].Color := hand1[firstTileSlot].Color;
  board[0, 0].Shape := hand1[firstTileSlot].Shape;
  hand1[firstTileSlot].Color := EMPTY;
  hand1[firstTileSlot].Shape := EMPTY;
  Writeln('le plateau de jeu initialise par l''IA est le suivant :');
  Writeln;
  DrawBoard(board, right, left, top, bottom);
  player1.Score := 1;
  Readln;
  DrawScores2(player1, player2);
  Readln;

  repeat
    ClrScr;
    Writeln('L''IA-2 joue :');
    hand2 := RefillHand(hand2, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay2 := HasPlayableMove(board, hand2, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand2);
    Writeln;
    isAI := true;
    PlayTurnAI(player2, hand2, board, lineHorizontal, lineVertical, isAI, deck);
    DrawHand(hand2);
    DrawScores2(player1, player2);
    Readln;
    lineHorizontal := false;
    lineVertical := false;
    canPlay2 := HasPlayableMove(board, hand2, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;

    ClrScr;
    Writeln('L''IA-1 joue :');
    hand1 := RefillHand(hand1, deck);
    lineHorizontal := false;
    lineVertical := false;
    canPlay1 := HasPlayableMove(board, hand1, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    DrawBoard(board, right, left, top, bottom);
    Writeln;
    DrawHand(hand1);
    Writeln;
    isAI := true;
    PlayTurnAI(player1, hand1, board, lineHorizontal, lineVertical, isAI, deck);
    DrawHand(hand1);
    DrawScores2(player1, player2);
    Readln;
    lineHorizontal := false;
    lineVertical := false;
    canPlay1 := HasPlayableMove(board, hand1, top, bottom, right, left, lineHorizontal, lineVertical, isAI);
    Readln;
  until (deck = nil) or ((canPlay1 = false) and (canPlay2 = false))
     or ((CountTilesInHand(hand1) = 0) and (CountTilesInHand(hand2) = 0));

  ClrScr;
  Writeln('--------------------------------');
  Writeln('---- FIN DE LA PARTIE ----');
  Writeln('--------------------------------');
  Writeln;
  Writeln('L''IA gagnante est .............................');
  Readln;
  Writeln('------', DetermineWinner2(player1.Name, player2.Name, player1.Score, player2.Score));
end;

end.
