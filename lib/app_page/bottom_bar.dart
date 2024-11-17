// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';

import 'fact_check_page.dart';
import 'home_page.dart';
import 'more_page.dart';
import 'world_page.dart';

//แถบด้านล่างแอพ
class BottomBar extends StatefulWidget {
  const BottomBar({
    super.key,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.amber,
      child: Row(
        children: [
          ButtonIcon(
            icon: Icons.home,
            namePage: HomePage.routeName,
          ),
          ButtonIcon(
            icon: Icons.public,
            namePage: WorldPage.routeName,
          ),
          ButtonIcon(
            icon: Icons.fact_check,
            namePage: FactCheckPage.routeName,
          ),
          ButtonIcon(
            icon: Icons.widgets,
            namePage: MorePage.routeName,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }
}

//ปุ่มต่างๆในแถบด้านล่าง
class ButtonIcon extends StatelessWidget {
  IconData icon;
  String namePage;

  ButtonIcon({super.key, required this.icon, required this.namePage});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, namePage);
      },
      child: Icon(icon),
      style: ElevatedButton.styleFrom(shape: CircleBorder()),
    );
  }
}
