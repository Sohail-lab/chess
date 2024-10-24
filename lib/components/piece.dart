enum PieceType { pawn, rook, horse, bishop, queen, king }

class ChessPiece {
  final PieceType type;
  final bool isWhite;
  final String imagePath;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });
}
