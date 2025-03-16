import 'package:chat_app/screens/main%20screen/chats%20list/chats_list.dart';
import 'package:chat_app/screens/main%20screen/friends%20list/friends_list.dart';
import 'package:chat_app/screens/main%20screen/notifications%20list/notifications_list.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedScreen = 0;
  final titles = ['ChitChat', 'Your Friends', 'notifications'];
  final screens = [
    const ChatsList(),
    const FriendsList(),
    const NotificationsList(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              height: 0,
              color: Colors.white38,
            )),
        title: Text(titles[selectedScreen]),
        actions: [
          PopupMenuButton(
            offset: const Offset(0, 45),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: FirebaseAuth.instance.signOut,
                child: const Text(
                  'logout',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            ],
          ),
        ],
      ),
      body: screens[selectedScreen],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(
              color: Colors.white38,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              label: 'home',
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'friends',
              icon: Icon(Icons.group),
            ),
            BottomNavigationBarItem(
              label: 'notifications',
              icon: Icon(Icons.notifications),
            ),
          ],
          currentIndex: selectedScreen,
          onTap: (value) {
            setState(() {
              selectedScreen = value;
            });
          },
          selectedItemColor: Colors.white70,
          unselectedItemColor: Colors.white24,
        ),
      ),
    );
  }
}
