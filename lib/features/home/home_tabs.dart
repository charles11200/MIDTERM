import 'package:flutter/cupertino.dart';
import '../home/home_screen.dart';
import '../../history/history_screen.dart';
import '../profile/profile_screen.dart';

class HomeTabs extends StatelessWidget {
  const HomeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house_fill), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.clock_fill), label: 'History'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_fill), label: 'Profile'),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 1) return const HistoryScreen();
        if (index == 2) return const ProfileScreen();
        return const HomeScreen();
      },
    );
  }
}
