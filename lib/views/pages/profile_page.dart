import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/notifiers.dart';
import 'package:my_flutter_proj_dq/views/pages/welcome_page.dart';
//import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.0,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHw%3D&w=1000&q=80',
            ),
          ),
          SizedBox(height: 40),
          FilledButton(
            onPressed: () {},
            
            style: FilledButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text('Edit Profile'),
          ),
          SizedBox(height: 20),
          Divider(thickness: 2,),
          ListTile(
            title: Text('Privacy and Secrity'),
            onTap: () {
              selectedPageNotifier.value = 0;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return WelcomePage();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              selectedPageNotifier.value = 0;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return WelcomePage();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
