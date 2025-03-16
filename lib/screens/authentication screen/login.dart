import 'dart:ui';

import 'package:chat_app/custom%20widgets/custom_input_field.dart';
import 'package:chat_app/custom%20widgets/custom_snack_bar.dart';
import 'package:chat_app/custom%20widgets/custom_container.dart';
import 'package:chat_app/custom%20widgets/stroke_text.dart';
import 'package:chat_app/screens/authentication%20screen/authentication_screen.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.onLogin});
  final void Function(bool login) onLogin;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _form = GlobalKey<FormState>();
  bool showPassword = false;
  String enteredEmail = '';
  String enteredPassword = '';
  bool isLoading = false;

  void onSave() async {
    final valid = _form.currentState!.validate();

    if (!valid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      await auth.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'network-request-failed') {
        customSnackBar('Network error. Please try again later', context);
      } else if (e.code == 'invalid-email' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        customSnackBar('email or password is not correct', context);
      } else {
        customSnackBar('an error occurred', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StrokeText(
          'Welcome to',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          strokeSize: 4,
          strokeColor: colorScheme.surface,
        ),
        StrokeText(
          'ChitChat',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          strokeSize: 6,
          strokeColor: colorScheme.surface,
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: CustomContainer(
                color: colorScheme.surface.withOpacity(0.5),
                radius: 8,
                border: Border.all(color: Colors.white38, width: 1),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Form(
                    key: _form,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: custumInputFieldDecoration(
                            'email',
                            icon: Icons.email_sharp,
                          ),
                          validator: (value) {
                            final emailRegExp = RegExp(
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$");
                            if (value == null || value.isEmpty) {
                              return 'please enter an email';
                            } else if (!emailRegExp.hasMatch(value.trim())) {
                              return 'email entered is not correct';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            enteredEmail = newValue!;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          decoration: custumInputFieldDecoration(
                            'password',
                            icon: Icons.password,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                });
                              },
                              icon: Icon(
                                color: Colors.white38,
                                (showPassword)
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: !showPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter a password';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            enteredPassword = newValue!;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (!isLoading) ...[
                          ElevatedButton(
                            onPressed: onSave,
                            child: const Text(
                              'login',
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          const Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white38,
                                  thickness: 1,
                                  endIndent: 5,
                                ),
                              ),
                              Text('or'),
                              Expanded(
                                child: Divider(
                                  color: Colors.white38,
                                  thickness: 1,
                                  indent: 5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Not a Chitchater yet? ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              InkWell(
                                onTap: () {
                                  widget.onLogin(false);
                                },
                                child: Text(
                                  'signup',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: colorScheme.onSurface),
                                ),
                              ),
                              Text(
                                ' instead.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ] else
                          const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
