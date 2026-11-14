import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
//import 'package:my_flutter_proj_dq/views/pages/home_page.dart';
import 'package:my_flutter_proj_dq/views/pages/welcome_page.dart';
import 'package:my_flutter_proj_dq/views/widget_tree.dart';
//import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';

TextEditingController controllerEmail = TextEditingController(text: '123');
TextEditingController controllerPassword = TextEditingController(text: '123');
String email='123';
String password='123';
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.title,
  });

final String title;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // @override
  // void dispose() {
  //   controllerPassword.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return WelcomePage();
                },
              ),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Lottie.asset('assets/lotties/login2.json'),
                
                  TextField(
                    controller: controllerEmail,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onEditingComplete: () {
                      setState(() {});
                    },
                  ),
                
                SizedBox(height: 10),
                  TextField(
                    controller: controllerPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onEditingComplete: () {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20),
                    OutlinedButton(onPressed: () {
                      LoginonPressed();
                    }, 
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40.0),
                    ),
                    child: Text(widget.title),
                    ),
                  
                
              ],
            ),
          ),
        ),
      ),
    );
  }
  void LoginonPressed() {
    if (email == controllerEmail.text && password == controllerPassword.text) {
    Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(
                      builder: (
                        context) {
                    return WidgetTree();
                  },
                  ),
                  (route) => false,
                  );

  }
}
}