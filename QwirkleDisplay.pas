{ Everything that writes to the console: the colored board, a player's hand,
  and the score lines shown between turns. }
unit QwirkleDisplay;

{$mode objfpc}

interface

uses
  crt,
  QwirkleTypes;

procedure DrawTile(tile: TTile);
procedure DrawBoard(board: TBoard; var right, left, top, bottom: Integer);
procedure DrawHand(hand: THand);
procedure DrawScores2(player1, player2: TPlayer);
procedure DrawScores4(player1, player2, player3, player4: TPlayer);

implementation

{ Draws one tile as its shape character on a background matching its color. }
procedure DrawTile(tile: TTile);
begin
  HighVideo;
  if tile.Color = 'r' then
    TextBackground(Red)
  else if tile.Color = 'o' then
    TextBackground(Brown)
  else if tile.Color = 'j' then
    TextBackground(LightCyan)
  else if tile.Color = 'v' then
    TextBackground(Green)
  else if tile.Color = 'b' then
    TextBackground(Blue)
  else if tile.Color = 'm' then
    TextBackground(Magenta);
  Write(tile.Shape);
  NormVideo;
end;

{ Renders only the sub-grid of the (oversized) board that actually holds
  tiles, with X/Y coordinate labels, and reports its bounds to the caller. }
procedure DrawBoard(board: TBoard; var right, left, top, bottom: Integer);
var
  i, col, row, touched: Integer;
begin
  touched := 1;
  i := 0;
  while touched <> 0 do
  begin
    touched := 0;
    for col := BOARD_MIN to BOARD_MAX do
      if board[i, col].Color <> EMPTY then
        touched := touched + 1;
    i := i + 1;
  end;
  right := i;

  i := 0;
  touched := 1;
  while touched <> 0 do
  begin
    touched := 0;
    for col := BOARD_MIN to BOARD_MAX do
      if board[i, col].Color <> EMPTY then
        touched := touched + 1;
    i := i - 1;
  end;
  left := i;

  i := 0;
  touched := 1;
  while touched <> 0 do
  begin
    touched := 0;
    for col := BOARD_MIN to BOARD_MAX do
      if board[col, i].Color <> EMPTY then
        touched := touched + 1;
    i := i + 1;
  end;
  top := i;

  i := 0;
  touched := 1;
  while touched <> 0 do
  begin
    touched := 0;
    for col := BOARD_MIN to BOARD_MAX do
      if board[col, i].Color <> EMPTY then
        touched := touched + 1;
    i := i - 1;
  end;
  bottom := i;

  Write('   ');
  for i := left + 1 to right - 1 do
  begin
    Write('|');
    Write(i);
    if i >= 0 then
      Write('|');
  end;
  HighVideo;
  TextBackground(White);
  TextColor(Black);
  Write('X');
  NormVideo;
  Writeln;

  for row := bottom + 1 to top - 1 do
  begin
    if row < 0 then
      Write(row)
    else
      Write(' ', row);
    Write('|');
    for i := left + 1 to right - 1 do
    begin
      Write('|');
      DrawTile(board[i, row]);
      Write('|');
    end;
    Writeln;
  end;

  Write(' ');
  HighVideo;
  TextBackground(White);
  TextColor(Black);
  Write('Y');
  NormVideo;
  Writeln;
  Writeln;
end;

procedure DrawHand(hand: THand);
var
  i: Integer;
begin
  for i := 1 to HAND_SIZE do
  begin
    Write('|');
    DrawTile(hand[i]);
  end;
  Write('|');
  Writeln;
  for i := 1 to HAND_SIZE do
  begin
    TextBackground(White);
    TextColor(Black);
    Write('|', i);
  end;
  Write('|');
  NormVideo;
end;

procedure DrawScores2(player1, player2: TPlayer);
begin
  Writeln('-- Nombre de points :');
  Writeln('-- ', player1.Name, '  :', player1.Score);
  Writeln('-- ', player2.Name, '  :', player2.Score);
end;

procedure DrawScores4(player1, player2, player3, player4: TPlayer);
begin
  Writeln('-- Nombre de points :');
  Writeln('-- ', player1.Name, '  :', player1.Score);
  Writeln('-- ', player2.Name, '  :', player2.Score);
  Writeln('-- ', player3.Name, '  :', player3.Score);
  Writeln('-- ', player4.Name, '  :', player4.Score);
end;

end.
