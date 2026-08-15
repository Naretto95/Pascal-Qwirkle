{ The computer player: for a single tile, find the highest-scoring legal
  square on the board; for a whole hand, brute-force every play order to
  find the best turn. }
unit QwirkleAI;

{$mode objfpc}

interface

uses
  QwirkleTypes, QwirkleBoard, QwirkleDeck;

{ Scans the [bottom+1..top-1] x [left+1..right-1] window and places `tile`
  wherever it scores the most points. anchorX/anchorY is the first tile
  placed so far this turn, or (0, 0) to mean "no tile placed yet" (any legal
  square is a valid start). totalScore and tileCount accumulate across the
  calls made during one AI turn; board and placedCoords are updated in place
  with the chosen placement. Returns (0, 0) when no legal placement exists. }
function FindBestPlacement(tile: TTile; top, bottom, left, right: Integer;
  var totalScore, tileCount: Integer; var placedCoords: TCoordList; var board: TBoard;
  lineHorizontal, lineVertical, isAI: Boolean; anchorX, anchorY: Integer): TCoord;

{ Tries every ordering of the 6 hand tiles and returns the moves of the
  best-scoring turn that plays out as a single straight line. A slot with
  HandIndex = 0 means no tile is played from that slot. }
function ComputeAIMove(hand: THand; board: TBoard; top, bottom, right, left: Integer;
  var lineHorizontal, lineVertical, isAI: Boolean): TMoveList;

implementation

function FindBestPlacement(tile: TTile; top, bottom, left, right: Integer;
  var totalScore, tileCount: Integer; var placedCoords: TCoordList; var board: TBoard;
  lineHorizontal, lineVertical, isAI: Boolean; anchorX, anchorY: Integer): TCoord;
var
  candidateX, candidateY, tileCountTrial, tileCountBest, scoreTrial, scoreBest: Integer;
  boardTrial, boardBest: TBoard;
  coordsTrial, coordsBest: TCoordList;
begin
  scoreBest := 0;
  tileCountBest := tileCount;
  boardBest := board;
  Result.X := 0;
  Result.Y := 0;
  coordsBest := placedCoords;

  for candidateY := bottom + 1 to top - 1 do
    for candidateX := left + 1 to right - 1 do
    begin
      boardTrial := board;
      tileCountTrial := tileCount;
      lineHorizontal := false;
      lineVertical := false;
      coordsTrial := placedCoords;
      if (anchorX = 0) and (anchorY = 0) then
        boardTrial := PlaceTile(candidateX, candidateY, candidateX, candidateY, tile.Color, tile.Shape,
          boardTrial, tileCountTrial, lineHorizontal, lineVertical, isAI)
      else
        boardTrial := PlaceTile(candidateX, candidateY, placedCoords[1].X, placedCoords[1].Y, tile.Color, tile.Shape,
          boardTrial, tileCountTrial, lineHorizontal, lineVertical, isAI);
      if tileCountTrial = tileCount + 1 then
      begin
        scoreTrial := ScoreMove(candidateX, candidateY, boardTrial, coordsTrial, tileCountTrial);
        if scoreTrial > scoreBest then
        begin
          scoreBest := scoreTrial;
          Result.X := candidateX;
          Result.Y := candidateY;
          boardBest := boardTrial;
          coordsBest := coordsTrial;
          tileCountBest := tileCountTrial;
        end;
      end;
    end;

  board := boardBest;
  placedCoords := coordsBest;
  tileCount := tileCountBest;
  totalScore := totalScore + scoreBest;
end;

function ComputeAIMove(hand: THand; board: TBoard; top, bottom, right, left: Integer;
  var lineHorizontal, lineVertical, isAI: Boolean): TMoveList;
var
  tileCount, turnScore, bestScore, i: Integer;
  perm1, perm2, perm3, perm4, perm5: Integer;
  matchXCount, matchYCount, checkIndex, clearIndex: Integer;
  turnAnchorX, turnAnchorY: Integer;
  searchBoard: TBoard;
  bestMoves, trialMoves: TMoveList;
  placedCoords: TCoordList;
  node, handList: PHandNode;
  found: TCoord;
begin
  bestScore := 0;
  for i := 1 to HAND_SIZE do
  begin
    bestMoves[i].X := 0;
    bestMoves[i].Y := 0;
    bestMoves[i].HandIndex := 0;
  end;

  { try every ordering of the 6 hand tiles: perm1 picks 1 of 6, perm2 picks 1
    of the remaining 5, perm3 1 of the remaining 4, and so on down to the
    single tile left for the 6th slot. Each candidate turn stops as soon as
    a tile fails to find a legal placement. }
  for perm1 := 1 to 6 do
    for perm2 := 1 to 5 do
      for perm3 := 1 to 4 do
        for perm4 := 1 to 3 do
          for perm5 := 1 to 2 do
          begin
            for clearIndex := 1 to HAND_SIZE do
            begin
              placedCoords[clearIndex].X := 0;
              placedCoords[clearIndex].Y := 0;
            end;
            for clearIndex := 1 to HAND_SIZE do
            begin
              trialMoves[clearIndex].X := 0;
              trialMoves[clearIndex].Y := 0;
              trialMoves[clearIndex].HandIndex := 0;
            end;
            searchBoard := board;
            tileCount := 0;
            turnScore := 0;
            handList := HandToList(hand);
            node := GetNodeAt(perm1, handList);
            turnAnchorX := 0;
            turnAnchorY := 0;

            found := FindBestPlacement(node^.Tile, top, bottom, left, right, turnScore, tileCount,
              placedCoords, searchBoard, lineHorizontal, lineVertical, isAI, turnAnchorX, turnAnchorY);
            trialMoves[1].X := found.X;
            trialMoves[1].Y := found.Y;
            if (trialMoves[1].X <> 0) or (trialMoves[1].Y <> 0) then
            begin
              turnAnchorX := found.X;
              turnAnchorY := found.Y;
              trialMoves[1].HandIndex := node^.Index;
              RemoveNode(perm1, handList);
              node := GetNodeAt(perm2, handList);
            end;

            if (trialMoves[1].X <> 0) or (trialMoves[1].Y <> 0) then
            begin
              found := FindBestPlacement(node^.Tile, top, bottom, left, right, turnScore, tileCount,
                placedCoords, searchBoard, lineHorizontal, lineVertical, isAI, turnAnchorX, turnAnchorY);
              trialMoves[2].X := found.X;
              trialMoves[2].Y := found.Y;
              trialMoves[2].HandIndex := node^.Index;
              RemoveNode(perm2, handList);
              node := GetNodeAt(perm3, handList);
            end;

            if (trialMoves[2].X <> 0) or (trialMoves[2].Y <> 0) then
            begin
              found := FindBestPlacement(node^.Tile, top, bottom, left, right, turnScore, tileCount,
                placedCoords, searchBoard, lineHorizontal, lineVertical, isAI, turnAnchorX, turnAnchorY);
              trialMoves[3].X := found.X;
              trialMoves[3].Y := found.Y;
              trialMoves[3].HandIndex := node^.Index;
              RemoveNode(perm3, handList);
              node := GetNodeAt(perm4, handList);
            end;

            if (trialMoves[3].X <> 0) or (trialMoves[3].Y <> 0) then
            begin
              found := FindBestPlacement(node^.Tile, top, bottom, left, right, turnScore, tileCount,
                placedCoords, searchBoard, lineHorizontal, lineVertical, isAI, turnAnchorX, turnAnchorY);
              trialMoves[4].X := found.X;
              trialMoves[4].Y := found.Y;
              trialMoves[4].HandIndex := node^.Index;
              RemoveNode(perm4, handList);
              node := GetNodeAt(perm5, handList);
            end;

            if (trialMoves[4].X <> 0) or (trialMoves[4].Y <> 0) then
            begin
              found := FindBestPlacement(node^.Tile, top, bottom, left, right, turnScore, tileCount,
                placedCoords, searchBoard, lineHorizontal, lineVertical, isAI, turnAnchorX, turnAnchorY);
              trialMoves[5].X := found.X;
              trialMoves[5].Y := found.Y;
              trialMoves[5].HandIndex := node^.Index;
              RemoveNode(perm5, handList);
              node := GetNodeAt(1, handList);
            end;

            if (trialMoves[5].X <> 0) or (trialMoves[5].Y <> 0) then
            begin
              found := FindBestPlacement(node^.Tile, top, bottom, left, right, turnScore, tileCount,
                placedCoords, searchBoard, lineHorizontal, lineVertical, isAI, turnAnchorX, turnAnchorY);
              trialMoves[6].X := found.X;
              trialMoves[6].Y := found.Y;
              trialMoves[6].HandIndex := node^.Index;
              RemoveNode(1, handList);
            end;

            { every move after the first must share the anchor's X (a
              vertical line) or all share its Y (a horizontal line) - never
              a mix of both, and never neither }
            matchXCount := 0;
            matchYCount := 0;
            for checkIndex := 2 to HAND_SIZE do
              if (trialMoves[checkIndex].X <> 0) or (trialMoves[checkIndex].Y <> 0) then
              begin
                if trialMoves[checkIndex].X = turnAnchorX then
                  matchXCount := matchXCount + 1;
                if trialMoves[checkIndex].Y = turnAnchorY then
                  matchYCount := matchYCount + 1;
              end;

            if ((matchXCount = 0) and (matchYCount <> 0)) or ((matchXCount <> 0) and (matchYCount = 0)) then
              if bestScore < turnScore then
              begin
                for i := 1 to HAND_SIZE do
                  bestMoves[i] := trialMoves[i];
                bestScore := turnScore;
              end;
          end;

  Result := bestMoves;
end;

end.
