{ Draw pile management and the linked-list view of a hand used by the AI
  while it searches for the best sequence of moves to play. }
unit QwirkleDeck;

{$mode objfpc}

interface

uses
  QwirkleTypes;

function CreateDeck: PDeckNode;
function RefillHand(hand: THand; var deck: PDeckNode): THand;
procedure ReturnTileToDeck(tile: TTile; var deck: PDeckNode);

function HandToList(const hand: THand): PHandNode;
function GetNodeAt(n: Integer; list: PHandNode): PHandNode;
procedure RemoveNode(n: Integer; var listHead: PHandNode);

implementation

{ The deck holds 3 copies of each of the 6 colors x 6 shapes = 108 tiles. }
function CreateDeck: PDeckNode;
var
  head, current, node: PDeckNode;
  copyIndex, colorIndex, shapeIndex: Integer;
  colors: TColorSet;
  shapes: TShapeSet;
begin
  colors := GetColorSet;
  shapes := GetShapeSet;
  head := nil;
  current := nil;
  for copyIndex := 1 to 3 do
    for colorIndex := 1 to 6 do
      for shapeIndex := 1 to 6 do
      begin
        New(node);
        node^.Tile.Color := colors[colorIndex];
        node^.Tile.Shape := shapes[shapeIndex];
        node^.Next := nil;
        if head = nil then
          head := node
        else
          current^.Next := node;
        current := node;
      end;
  Result := head;
end;

{ Draws tiles at random from the deck into the empty slots of hand, until the
  hand holds 6 tiles or the deck runs out. }
function RefillHand(hand: THand; var deck: PDeckNode): THand;
var
  handSlot, drawIndex, step, totalTiles: Integer;
  before, drawn: PDeckNode;
begin
  Randomize;
  handSlot := 1;
  while (handSlot <= HAND_SIZE) and (deck <> nil) do
  begin
    totalTiles := 0;
    drawn := deck;
    while drawn <> nil do
    begin
      totalTiles := totalTiles + 1;
      drawn := drawn^.Next;
    end;

    drawIndex := Random(totalTiles) + 1;
    before := nil;
    drawn := deck;
    for step := 2 to drawIndex do
    begin
      before := drawn;
      drawn := drawn^.Next;
    end;

    while hand[handSlot].Color <> EMPTY do
      handSlot := handSlot + 1;
    if handSlot <= HAND_SIZE then
    begin
      hand[handSlot] := drawn^.Tile;
      if before = nil then
        deck := drawn^.Next
      else
        before^.Next := drawn^.Next;
      Dispose(drawn);
    end;
  end;
  Result := hand;
end;

{ Appends a tile to the end of the deck, used when a player exchanges tiles
  or has to give back an unplayable hand. }
procedure ReturnTileToDeck(tile: TTile; var deck: PDeckNode);
var
  tail, node: PDeckNode;
begin
  New(node);
  node^.Tile := tile;
  node^.Next := nil;
  if deck = nil then
    deck := node
  else
  begin
    tail := deck;
    while tail^.Next <> nil do
      tail := tail^.Next;
    tail^.Next := node;
  end;
end;

{ Builds a linked list out of a hand (including its empty slots) so the AI
  can try tiles in different orders and drop the ones it has already used. }
function HandToList(const hand: THand): PHandNode;
var
  head, current, node: PHandNode;
  i: Integer;
begin
  head := nil;
  current := nil;
  for i := 1 to HAND_SIZE do
  begin
    New(node);
    node^.Index := i;
    node^.Tile := hand[i];
    node^.Next := nil;
    if head = nil then
      head := node
    else
      current^.Next := node;
    current := node;
  end;
  Result := head;
end;

function GetNodeAt(n: Integer; list: PHandNode): PHandNode;
var
  step: Integer;
  node: PHandNode;
begin
  node := list;
  for step := 1 to n - 1 do
    node := node^.Next;
  Result := node;
end;

procedure RemoveNode(n: Integer; var listHead: PHandNode);
var
  previous, current: PHandNode;
  step: Integer;
begin
  if n = 1 then
  begin
    current := listHead;
    listHead := listHead^.Next;
    Dispose(current);
  end
  else
  begin
    previous := listHead;
    for step := 1 to n - 2 do
      previous := previous^.Next;
    current := previous^.Next;
    previous^.Next := current^.Next;
    Dispose(current);
  end;
end;

end.
