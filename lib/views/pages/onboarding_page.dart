import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_flutter_proj_dq/views/pages/register.dart';
//import 'package:my_flutter_proj_dq/views/pages/home_page.dart';
import 'package:my_flutter_proj_dq/views/pages/welcome_page.dart';
//import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';

TextEditingController controllerEmail = TextEditingController(text: '123');
TextEditingController controllerPassword = TextEditingController(text: '456');
String email='123';
String password='123';
class Onboarding_Page extends StatelessWidget {
  const Onboarding_Page({
    super.key,
    
  });



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
        title: Text(''),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Lottie.asset('assets/lotties/bus_travel.json'),
                
                SizedBox(height: 120),
                  
                  SizedBox(height: 60),
                  Text('Welcome to the app, lets get started with the onboarding process!'),
                  SizedBox(height: 10),
                    FilledButton(onPressed: () {
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Register_Page(
                            title: 'Register',
                          );
                        },
                      ),
            
                    );
                    }, 
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 40.0),
                    ),
                    child: Text('Lets Gooo!!!'),
                    ),
                  
                
              ],
            ),
          ),
        ),
      ),
    );
  }

}