import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key, required this.title, required this.nextPage});

  final String title;
  final Widget ? nextPage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: nextPage !=null ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => nextPage!,
          ),
        );
      } : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: 'hero1',
            child: AspectRatio(
              aspectRatio: 1920/1080,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/image/apple-abstract-dark-red-4k-3m-3840x2160.jpg',
                  fit: BoxFit.cover,
                  color: Colors.teal,
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
          ),
          FittedBox(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.normal,
                letterSpacing: 50,
                color: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
