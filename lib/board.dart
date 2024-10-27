import 'dart:math';
import 'package:chess/components/deadPiece.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;

  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;

  List<List<int>> validMoves = [];

  List<ChessPiece> whitePiecesDead = [];
  List<ChessPiece> blackPiecesDead = [];

  bool isWhiteTurn = true;

  List<int> whiteKingPosition = [0,3];
  List<int> blackKingPosition = [7,3];
  bool checkStatus = false;


  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  bool isInBoard(int row, int col) {
    return row >= 0 && col >= 0 && row < 8 && col < 8;
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: PieceType.pawn,
          isWhite: true,
          imagePath: 'lib/components/pieces/pawnw.png');
    }
    for (int i = 0; i < 8; i++) {
      newBoard[6][i] = ChessPiece(
          type: PieceType.pawn,
          isWhite: false,
          imagePath: 'lib/components/pieces/pawnb.png');
    }

    // rooks
    newBoard[0][0] = ChessPiece(
        type: PieceType.rook,
        isWhite: true,
        imagePath: 'lib/components/pieces/rookw.png');
    newBoard[0][7] = ChessPiece(
        type: PieceType.rook,
        isWhite: true,
        imagePath: 'lib/components/pieces/rookw.png');
    newBoard[7][0] = ChessPiece(
        type: PieceType.rook,
        isWhite: false,
        imagePath: 'lib/components/pieces/rookb.png');
    newBoard[7][7] = ChessPiece(
        type: PieceType.rook,
        isWhite: false,
        imagePath: 'lib/components/pieces/rookb.png');

    // horses
    newBoard[0][1] = ChessPiece(
        type: PieceType.horse,
        isWhite: true,
        imagePath: 'lib/components/pieces/horsew.png');
    newBoard[0][6] = ChessPiece(
        type: PieceType.horse,
        isWhite: true,
        imagePath: 'lib/components/pieces/horsew.png');
    newBoard[7][1] = ChessPiece(
        type: PieceType.horse,
        isWhite: false,
        imagePath: 'lib/components/pieces/horseb.png');
    newBoard[7][6] = ChessPiece(
        type: PieceType.horse,
        isWhite: false,
        imagePath: 'lib/components/pieces/horseb.png');

    // bishops
    newBoard[0][2] = ChessPiece(
        type: PieceType.bishop,
        isWhite: true,
        imagePath: 'lib/components/pieces/bishopw.png');
    newBoard[0][5] = ChessPiece(
        type: PieceType.bishop,
        isWhite: true,
        imagePath: 'lib/components/pieces/bishopw.png');
    newBoard[7][2] = ChessPiece(
        type: PieceType.bishop,
        isWhite: false,
        imagePath: 'lib/components/pieces/bishopb.png');
    newBoard[7][5] = ChessPiece(
        type: PieceType.bishop,
        isWhite: false,
        imagePath: 'lib/components/pieces/bishopb.png');

    // queen
    newBoard[0][4] = ChessPiece(
        type: PieceType.queen,
        isWhite: true,
        imagePath: 'lib/components/pieces/queenw.png');
    newBoard[7][4] = ChessPiece(
        type: PieceType.queen,
        isWhite: false,
        imagePath: 'lib/components/pieces/queenb.png');

    // king
    newBoard[0][3] = ChessPiece(
        type: PieceType.king,
        isWhite: true,
        imagePath: 'lib/components/pieces/kingw.png');
    newBoard[7][3] = ChessPiece(
        type: PieceType.king,
        isWhite: false,
        imagePath: 'lib/components/pieces/kingb.png');

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if(board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      validMoves =
          calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? 1 : -1;

    switch (piece.type) {
      case PieceType.pawn:
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        if ((row == 1 && piece.isWhite) || (row == 6 && !piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case PieceType.rook:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.horse:
        var horseMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];

        for (var move in horseMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case PieceType.bishop:
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.queen:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.king:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
    }

    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    if(checkSimulation) {
      for(var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        if(simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    }
    else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesDead.add(capturedPiece);
      } else {
        blackPiecesDead.add(capturedPiece);
      }
    }

    if(selectedPiece!.type == PieceType.king) {
      if(selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      }
      else {
        blackKingPosition = [newRow, newCol];
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    if(isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    }
    else {
      checkStatus = false;
    }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if(isCheckMate(!isWhiteTurn)) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("CHECK MATE!"),
        actions: [
          TextButton(onPressed: resetGame, child: Text("Play Again")),
        ],
      ));
    }

    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

    for(int i = 0; i < 8; i++) {
      for(int j = 0; j < 8; j++) {
        if(board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], false);

        if(pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    List<int>? originalKingPosition;
    if(piece.type == PieceType.king) {
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

      if(piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      }
      else {
        blackKingPosition = [endRow, endCol];
      }
    }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    if(piece.type == PieceType.king) {
      if(piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      }
      else {
        blackKingPosition = originalKingPosition!;
      }
    }

    return !kingInCheck;
  }

  bool isCheckMate(bool isWhiteKing) {
    if(!isKingInCheck(isWhiteKing)) {
      return false;
    }

    for(int i = 0; i < 8; i++) {
      for(int j = 0; j < 8; j++) {
        if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], true);

        if(pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesDead.clear();
    blackPiecesDead.clear();
    whiteKingPosition = [0,3];
    blackKingPosition = [7,3];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: whitePiecesDead.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                    imagePath: whitePiecesDead[index].imagePath,
                    isWhite: true,
                  ))),

          Text(checkStatus ? "CHECK!" : ""),

          Expanded(
            flex: 3,
            child: GridView.builder(
                itemCount: 8 * 8,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;

                  bool isWhite = (row + col) % 2 == 0;

                  bool isSelected = selectedRow == row && selectedCol == col;

                  bool isValidMove = false;
                  for (var position in validMoves) {
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }

                  return Square(
                    isWhite: isWhite,
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    onTap: () => pieceSelected(row, col),
                  );
                }),
          ),
          Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                  itemCount: blackPiecesDead.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                    imagePath: blackPiecesDead[index].imagePath,
                    isWhite: false,
                  ))),
        ],
      ),
    );
  }
}
