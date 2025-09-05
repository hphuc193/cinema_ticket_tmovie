// lib/widgets/rating_display.dart
import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;

  const RatingDisplay({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(maxRating, (index) {
            double currentRating = rating / 2; // Convert from 10 to 5 star system
            if (index < currentRating.floor()) {
              return Icon(
                Icons.star,
                color: Colors.amber,
                size: size,
              );
            } else if (index < currentRating) {
              return Icon(
                Icons.star_half,
                color: Colors.amber,
                size: size,
              );
            } else {
              return Icon(
                Icons.star_border,
                color: Colors.amber,
                size: size,
              );
            }
          }),
        ),
        SizedBox(width: 4),
        Text(
          rating.toString(),
          style: TextStyle(
            fontSize: size - 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
