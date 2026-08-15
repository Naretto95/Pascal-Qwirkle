{ Board rules: placing a tile, scoring the tiles placed during a turn, and
  checking whether a hand still has a legal move anywhere on the board. }
unit QwirkleBoard;

{$mode objfpc}

interface

uses
  QwirkleTypes;

{ Tries to place (color, shape) at (x, y). firstX/firstY is the anchor tile
  of the current turn (the very first tile placed this turn, or (x, y) itself
  when this is that first tile). lineHorizontal/lineVertical remember, across
  the calls of a single turn, whether the tiles played so far form a fixed-row
  or fixed-column line; isAI relaxes that same-line check for the AI's search,
  which explores placements before committing to a turn. On success tileCount
  is incremented and the tile is written into the returned board; on failure
  the board is returned unchanged. }
function PlaceTile(x, y, firstX, firstY: Integer; color, shape: Char;
  board: TBoard; var tileCount: Integer;
  var lineHorizontal, lineVertical, isAI: Boolean): TBoard;

{ Scores the tiles placed so far this turn. (x, y) is the tile just placed;
  it is appended to placedCoords at index tileCount before scoring. }
function ScoreMove(x, y: Integer; board: TBoard; var placedCoords: TCoordList;
  tileCount: Integer): Integer;

{ True if at least one tile in hand can legally be placed somewhere inside
  the [bottom+1..top-1] x [left+1..right-1] window of the board. }
function HasPlayableMove(board: TBoard; hand: THand; top, bottom, right, left: Integer;
  var lineHorizontal, lineVertical, isAI: Boolean): Boolean;

implementation

function PlaceTile(x, y, firstX, firstY: Integer; color, shape: Char;
  board: TBoard; var tileCount: Integer;
  var lineHorizontal, lineVertical, isAI: Boolean): TBoard;
var
  errorCount, step, dx, dy, stepForward, stepBackward, emptyNeighbors: Integer;
  touchesPlacedTiles: Boolean;
begin
  errorCount := 0;
  touchesPlacedTiles := false;
  if (board[x, y].Color = EMPTY) and (board[x, y].Shape = EMPTY) then
  begin
    dx := 1;
    dy := 0;
    step := 1;
    stepForward := 1;
    stepBackward := 1;
    emptyNeighbors := 0;
    repeat
      if board[x + dx, y + dy].Color <> EMPTY then
      begin
        { walk outward along this direction: a tile sharing exactly one of
          color/shape with the new tile extends the line; a duplicate tile
          or one sharing neither is illegal }
        while (board[x + step * dx, y + step * dy].Color <> EMPTY) and (errorCount = 0) do
        begin
          if ((board[x + step * dx, y + step * dy].Color = color) and (board[x + step * dx, y + step * dy].Shape <> shape))
          or ((board[x + step * dx, y + step * dy].Color <> color) and (board[x + step * dx, y + step * dy].Shape = shape)) then
            step := step + 1
          else if (board[x + step * dx, y + step * dy].Color = color) and (board[x + step * dx, y + step * dy].Shape = shape) then
            errorCount := errorCount + 1
          else if (board[x + dx, y + dy].Color <> board[x, y].Color) and (board[x + dx, y + dy].Shape <> board[x, y].Shape) then
            errorCount := errorCount + 1;
        end;
        step := 1;

        { reject the move if it would create the same tile twice in the
          resulting line (once on each side of the new tile) }
        while board[x + stepForward * dx, y + stepForward * dy].Color <> EMPTY do
        begin
          while board[x - stepBackward * dx, y - stepBackward * dy].Color <> EMPTY do
          begin
            if (board[x + stepForward * dx, y + stepForward * dy].Color = board[x - stepBackward * dx, y - stepBackward * dy].Color)
            and (board[x + stepForward * dx, y + stepForward * dy].Shape = board[x - stepBackward * dx, y - stepBackward * dy].Shape) then
              errorCount := errorCount + 1;
            stepBackward := stepBackward + 1;
          end;
          stepBackward := 1;
          stepForward := stepForward + 1;
        end;
      end;

      if (firstX = x) and (firstY = y) then
        touchesPlacedTiles := true;
      while board[firstX + step * dx - dx, firstY + step * dy - dy].Color <> EMPTY do
      begin
        if (firstX + step * dx = x) and (firstY + step * dy = y) then
          touchesPlacedTiles := true;
        step := step + 1;
      end;
      step := 1;

      if board[x + dx, y + dy].Color = EMPTY then
        emptyNeighbors := emptyNeighbors + 1;

      { rotate (dx, dy) through the four cardinal directions: +x, -x, +y, -y }
      if (dx = 0) and (dy = -1) then
      begin
        dx := 0;
        dy := 0;
      end;
      if (dx = 0) and (dy = 1) then
      begin
        dx := 0;
        dy := -1;
      end;
      if (dx = -1) and (dy = 0) then
      begin
        dx := 0;
        dy := 1;
      end;
      if (dx = 1) and (dy = 0) then
      begin
        dx := -1;
        dy := 0;
      end;
    until (dx = 0) and (dy = 0);

    if isAI = false then
    begin
      if lineVertical = true then
        if x <> firstX then
          errorCount := errorCount + 1;
      if lineHorizontal = true then
        if y <> firstY then
          errorCount := errorCount + 1;
    end;
    if (firstX <> x) and (firstY <> y) then
      errorCount := errorCount + 1;
    if emptyNeighbors = 4 then
      errorCount := errorCount + 1;
  end;

  if (errorCount = 0) and (touchesPlacedTiles = true) then
  begin
    board[x, y].Color := color;
    board[x, y].Shape := shape;
    tileCount := tileCount + 1;
    if (firstX = x) and (firstY <> y) then
    begin
      lineVertical := true;
      lineHorizontal := false;
    end;
    if (firstY = y) and (firstX <> x) then
    begin
      lineHorizontal := true;
      lineVertical := false;
    end;
  end;

  Result := board;
end;

function ScoreMove(x, y: Integer; board: TBoard; var placedCoords: TCoordList;
  tileCount: Integer): Integer;
var
  step, i, maxIndex, minIndex, score, lineScore, hasCrossLine: Integer;
begin
  placedCoords[tileCount].X := x;
  placedCoords[tileCount].Y := y;
  score := 0;

  if placedCoords[1].X = placedCoords[tileCount].X then
  begin
    { tiles placed this turn form a vertical line (fixed X): score the line
      itself, then score the perpendicular (horizontal) line at each tile }
    lineScore := 0;
    maxIndex := 1;
    minIndex := 1;
    for step := 1 to tileCount do
      if placedCoords[maxIndex].Y < placedCoords[step].Y then
        maxIndex := step;
    for step := 1 to tileCount do
      if placedCoords[minIndex].Y > placedCoords[step].Y then
        minIndex := step;

    step := 1;
    while board[placedCoords[minIndex].X, placedCoords[minIndex].Y - step].Color <> EMPTY do
    begin
      lineScore := lineScore + 1;
      step := step + 1;
    end;
    step := 1;
    while board[placedCoords[maxIndex].X, placedCoords[maxIndex].Y + step].Color <> EMPTY do
    begin
      lineScore := lineScore + 1;
      step := step + 1;
    end;
    if (lineScore <> 0) or (tileCount <> 1) then
      lineScore := lineScore + placedCoords[maxIndex].Y - placedCoords[minIndex].Y + 1;
    if lineScore = 6 then
      lineScore := lineScore + 6;
    score := lineScore;
    lineScore := 0;

    for i := 1 to tileCount do
    begin
      hasCrossLine := 0;
      step := 1;
      while board[placedCoords[i].X + step, placedCoords[i].Y].Color <> EMPTY do
      begin
        lineScore := lineScore + 1;
        step := step + 1;
      end;
      if step <> 1 then
        hasCrossLine := hasCrossLine + 1;
      step := 1;
      while board[placedCoords[i].X - step, placedCoords[i].Y].Color <> EMPTY do
      begin
        lineScore := lineScore + 1;
        step := step + 1;
      end;
      if step <> 1 then
        hasCrossLine := hasCrossLine + 1;
      if lineScore = 6 then
        lineScore := lineScore + 6;
      if hasCrossLine <> 0 then
        lineScore := lineScore + 1;
      score := score + lineScore;
      lineScore := 0;
    end;
  end
  else if placedCoords[1].Y = placedCoords[tileCount].Y then
  begin
    { tiles placed this turn form a horizontal line (fixed Y): mirror of the
      block above, with the roles of X and Y swapped }
    lineScore := 0;
    maxIndex := 1;
    minIndex := 1;
    for step := 1 to tileCount do
      if placedCoords[maxIndex].X < placedCoords[step].X then
        maxIndex := step;
    for step := 1 to tileCount do
      if placedCoords[minIndex].X > placedCoords[step].X then
        minIndex := step;

    step := 1;
    while board[placedCoords[minIndex].X - step, placedCoords[minIndex].Y].Color <> EMPTY do
    begin
      lineScore := lineScore + 1;
      step := step + 1;
    end;
    step := 1;
    while board[placedCoords[maxIndex].X + step, placedCoords[maxIndex].Y].Color <> EMPTY do
    begin
      lineScore := lineScore + 1;
      step := step + 1;
    end;
    lineScore := lineScore + placedCoords[maxIndex].X - placedCoords[minIndex].X + 1;
    if lineScore = 6 then
      lineScore := lineScore + 6;
    score := lineScore;
    lineScore := 0;

    for i := 1 to tileCount do
    begin
      hasCrossLine := 0;
      step := 1;
      while board[placedCoords[i].X, placedCoords[i].Y + step].Color <> EMPTY do
      begin
        lineScore := lineScore + 1;
        step := step + 1;
      end;
      if step <> 1 then
        hasCrossLine := hasCrossLine + 1;
      step := 1;
      while board[placedCoords[i].X, placedCoords[i].Y - step].Color <> EMPTY do
      begin
        lineScore := lineScore + 1;
        step := step + 1;
      end;
      if step <> 1 then
        hasCrossLine := hasCrossLine + 1;
      if lineScore = 6 then
        lineScore := lineScore + 6;
      if hasCrossLine <> 0 then
        lineScore := lineScore + 1;
      score := score + lineScore;
      lineScore := 0;
    end;
  end;

  { a fully isolated tile (only possible for the very first tile of the
    game) is simply worth one point per tile placed }
  if (board[placedCoords[1].X + 1, placedCoords[1].Y].Color = EMPTY)
  and (board[placedCoords[1].X - 1, placedCoords[1].Y].Color = EMPTY)
  and (board[placedCoords[1].X, placedCoords[1].Y + 1].Color = EMPTY)
  and (board[placedCoords[1].X, placedCoords[1].Y - 1].Color = EMPTY)
  and (board[placedCoords[1].X, placedCoords[1].Y].Color <> EMPTY) then
    score := tileCount;

  Result := score;
end;

function HasPlayableMove(board: TBoard; hand: THand; top, bottom, right, left: Integer;
  var lineHorizontal, lineVertical, isAI: Boolean): Boolean;
var
  unchangedCount, a, c, i, j, tileIndex, dummyTileCount: Integer;
  trialBoard: TBoard;
begin
  { NOTE: kept exactly as in the original (ported as-is, not verified by a
    compiler run): the search below feeds the Y-bound range into PlaceTile's
    X slot and the X-bound range into its Y slot, the opposite of every
    other caller in this codebase. On an elongated board this likely
    searches the wrong sub-region. Left untouched rather than "corrected"
    without being able to test the fix. }
  unchangedCount := 0;
  for tileIndex := 1 to HAND_SIZE do
    for a := bottom + 1 to top - 1 do
      for c := left + 1 to right - 1 do
      begin
        trialBoard := PlaceTile(a, c, a, c, hand[tileIndex].Color, hand[tileIndex].Shape,
          board, dummyTileCount, lineHorizontal, lineVertical, isAI);
        for i := bottom + 1 to top - 1 do
          for j := left + 1 to right - 1 do
            if trialBoard[i, j].Color = board[i, j].Color then
              unchangedCount := unchangedCount + 1;
      end;
  Result := unchangedCount <> (top - bottom - 2) * (right - left - 2) * (top - bottom - 2) * (right - left - 2) * 6;
end;

end.
