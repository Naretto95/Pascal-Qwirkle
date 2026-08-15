{ Qwirkle - a console reimplementation of the tile-laying board game.
  See README.md for the rules summary and build instructions.

  This file only wires up the top-level menu; the game itself lives in the
  QwirkleGame unit and the units it builds on (QwirkleTypes, QwirkleDeck,
  QwirkleBoard, QwirkleDisplay, QwirkleAI). }
program Qwirkle;

{$mode objfpc}

uses
  crt, SysUtils,
  QwirkleGame;

procedure RunGame;
var
  playerCount, parseError, choice: Integer;
  input: string;
begin
  Writeln('------------------------------------------');
  Writeln('  Bienvenue dans le jeu de Qwirkle !!!!!!!!');
  Writeln('------------------------------------------');
  Readln;
  Writeln;
  ClrScr;
  Writeln('---------------------------------------------------------------------------------------------------');
  Writeln('---- Voulez-vous au choix : (1)jouer avec des amis, ou bien si vous etes (malheureusement) seul (2)jouer contre l''IA, ou alors si vous etes d''humeur a ne rien faire, (3) faire se battre des IA  ? : ');
  Writeln('---------------------------------------------------------------------------------------------------');
  repeat
    Writeln('              ', '---- Veuillez entrer 1, 2 ou 3 : ----');
    Readln(input);
    Val(input, choice, parseError);
  until ((choice = 1) or (choice = 2) or (choice = 3)) and (parseError = 0);

  if choice = 2 then
  begin
    ClrScr;
    RunPlayerVsAIGame;
  end
  else if choice = 1 then
  begin
    ClrScr;
    Writeln('-----------------------------------------------------------------------------------');
    Writeln('--  Dans un premier temps, vous devez specifier le nombre de joueurs present :  --');
    Writeln('-------------------------------------------------------------------------------');
    Readln;
    ClrScr;
    Writeln('--------------------------------------------------------');
    Writeln('-- Veuillez entrer ci-dessous le nombre correspondant  :');
    Writeln('--------------------------------------------------------');
    repeat
      Writeln('- Veuillez entrer 2 ou 4 :');
      Readln(input);
      Val(input, playerCount, parseError);
    until ((playerCount = 2) or (playerCount = 4)) and (parseError = 0);
    Writeln;
    if playerCount = 2 then
      RunTwoPlayerGame;
    if playerCount = 4 then
      RunFourPlayerGame;
  end
  else if choice = 3 then
  begin
    ClrScr;
    RunAIvsAIGame;
  end;
end;

begin
  RunGame;
end.
