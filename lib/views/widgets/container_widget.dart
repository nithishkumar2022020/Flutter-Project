import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/constants.dart';

class ContainerWidget extends StatelessWidget {
  const ContainerWidget({super.key,
  required this.title,
  required this.description});

  final String title;
  final String description;


  @override
  Widget build(BuildContext context) {
   
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: 0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KTextStyle.titleTealStyle),
                Text(
                  description,
                  style: KTextStyle.descriptionText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
