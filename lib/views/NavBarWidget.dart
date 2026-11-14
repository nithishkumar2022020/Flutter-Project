import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/notifiers.dart';

class navbarwidgett extends StatelessWidget {
  const navbarwidgett({super.key});

 

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder:  (context, SelectedPage, child) {
        return NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home
              ), 
              label: 'home'
              ),
              NavigationDestination(
                icon: Icon(Icons.person
                ), 
                label: 'user'
                )
                ],
                onDestinationSelected: (int value) {
                  selectedPageNotifier.value = value;
                  
                },
                selectedIndex: SelectedPage,
                );
      },
    );
  }
}