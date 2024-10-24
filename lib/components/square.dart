import 'package:chess/components/piece.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.onTap,
      required this.isValidMove});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    }
    else if(isValidMove) {
      squareColor = Colors.lightGreenAccent;
    }
    else {
      squareColor = isWhite ? Colors.grey[200] : Colors.grey[500];
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 1.0 : 0.0),
        child: piece != null ? Image.asset(piece!.imagePath) : null,
      ),
    );
  }
}
