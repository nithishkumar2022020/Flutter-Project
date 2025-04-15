import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/constants.dart';
import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(20.0),
    child: Column(
      children: [
        HeroWidget(title: 'home',),
        Container(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(
                20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('basic layout',
                    style: KTextStyle.titleTealStyle),
                    Text('more layout on the layout',
                    style: KTextStyle.descriptionText)
                  ],
                ),
          ),
          
          ),
          ),
        )
      ],
      
    ),
    );
  }
}