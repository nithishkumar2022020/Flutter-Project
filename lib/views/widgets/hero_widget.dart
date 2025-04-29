import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/main.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: 'hero1',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/image/apple-abstract-dark-red-4k-3m-3840x2160.jpg',
              color: Colors.teal,
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),
        FittedBox(
          child: Text(
            title,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.normal,letterSpacing: 50,color: Colors.white38),
          ),
        ),
      ],
    );
  }
}
