import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/notifiers.dart';
import 'package:my_flutter_proj_dq/views/pages/welcome_page.dart';
//import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(20.0),
    child: Column(
      children: [
        ListTile(
          title: Text('logout'),
          onTap: () {
            selectedPageNotifier.value = 0;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return WelcomePage();
            },
            ),
            );
          },
        )
      ],
    ),);
  }
}