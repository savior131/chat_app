import 'package:chat_app/screens/authentication%20screen/login.dart';
import 'package:chat_app/screens/authentication%20screen/signup.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

final auth = FirebaseAuth.instance;

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() {
    return _AuthenticationScreenState();
  }
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool login = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/files/images/no bg.png',
              color: colorScheme.primary.withOpacity(0.7),
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: login
                  ? Login(
                      onLogin: (login) {
                        setState(() {
                          this.login = login;
                        });
                      },
                    )
                  : Signup(
                      onLogin: (login) {
                        setState(() {
                          this.login = login;
                        });
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
