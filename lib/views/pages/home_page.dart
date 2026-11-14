import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/constants.dart';
import 'package:my_flutter_proj_dq/views/pages/course_page.dart';
import 'package:my_flutter_proj_dq/views/widgets/container_widget.dart';
import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> list = [
      KValue.alert,
      KValue.activity,
      KValue.tracking,
      KValue.findLost,
      KValue.report,
    ];
    List<String> description = [
      KValue.d1,
      KValue.d2,
      KValue.d3,
      KValue.d4,
      KValue.d5,
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            HeroWidget(title: 'home', nextPage: coursePage(),
            ),

            ...List.generate(
              list.length,
              (index) => ContainerWidget(
                title: list.elementAt(index),
                description: description.elementAt(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
