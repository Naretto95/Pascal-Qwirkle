{ Core data types shared by every unit in the game, plus the small pure
  helpers that build the starting values for a board and a hand. }
unit QwirkleTypes;

{$mode objfpc}

interface

const
  BOARD_MIN = -108;
  BOARD_MAX = 108;
  HAND_SIZE = 6;
  EMPTY = '.';

type
  { A single tile: a color and a shape. Both are '.' when the square is empty. }
  TTile = record
    Color: Char;
    Shape: Char;
  end;

  { The board is oversized (217x217) and centered on (0,0), the square where
    the very first tile of the game is always placed. }
  TBoard = array[BOARD_MIN..BOARD_MAX, BOARD_MIN..BOARD_MAX] of TTile;

  THand = array[1..HAND_SIZE] of TTile;

  { Singly linked list used as the draw pile. }
  PDeckNode = ^TDeckNode;
  TDeckNode = record
    Tile: TTile;
    Next: PDeckNode;
  end;

  { Singly linked list used to enumerate a hand while trying out AI moves. }
  PHandNode = ^THandNode;
  THandNode = record
    Tile: TTile;
    Index: Integer;
    Next: PHandNode;
  end;

  TColorSet = array[1..6] of Char;
  TShapeSet = array[1..6] of Char;

  TPlayer = record
    Name: string;
    Score: Integer;
  end;

  TCoord = record
    X, Y: Integer;
  end;

  { One planned tile placement: board position plus the hand slot it came from. }
  TMove = record
    X, Y, HandIndex: Integer;
  end;

  TCoordList = array[1..HAND_SIZE] of TCoord;
  TMoveList = array[1..HAND_SIZE] of TMove;

function InitBoard: TBoard;
function InitHand: THand;
function GetColorSet: TColorSet;
function GetShapeSet: TShapeSet;
function CountTilesInHand(const hand: THand): Integer;

implementation

function InitBoard: TBoard;
var
  x, y: Integer;
  board: TBoard;
begin
  for x := BOARD_MIN to BOARD_MAX do
    for y := BOARD_MIN to BOARD_MAX do
    begin
      board[x, y].Color := EMPTY;
      board[x, y].Shape := EMPTY;
    end;
  Result := board;
end;

function InitHand: THand;
var
  hand: THand;
  i: Integer;
begin
  for i := 1 to HAND_SIZE do
  begin
    hand[i].Color := EMPTY;
    hand[i].Shape := EMPTY;
  end;
  Result := hand;
end;

{ The six Qwirkle colors: red, orange, yellow, green, blue, purple. }
function GetColorSet: TColorSet;
begin
  Result[1] := 'r';
  Result[2] := 'o';
  Result[3] := 'j';
  Result[4] := 'v';
  Result[5] := 'b';
  Result[6] := 'm';
end;

{ The six Qwirkle shapes: circle, cross, diamond, square, star, clover. }
function GetShapeSet: TShapeSet;
begin
  Result[1] := 'c';
  Result[2] := 'x';
  Result[3] := 'l';
  Result[4] := 'a';
  Result[5] := '*';
  Result[6] := 't';
end;

function CountTilesInHand(const hand: THand): Integer;
var
  i, count: Integer;
begin
  count := 0;
  for i := 1 to HAND_SIZE do
    if hand[i].Color <> EMPTY then
      count := count + 1;
  Result := count;
end;

end.
