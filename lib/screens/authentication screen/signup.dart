import 'dart:io';
import 'dart:ui';

import 'package:chat_app/custom%20widgets/custom_input_field.dart';
import 'package:chat_app/custom%20widgets/custom_snack_bar.dart';
import 'package:chat_app/custom%20widgets/custom_container.dart';
import 'package:chat_app/custom%20widgets/stroke_text.dart';
import 'package:chat_app/screens/authentication%20screen/authentication_screen.dart';

import 'package:chat_app/widgets/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Signup extends StatefulWidget {
  const Signup({super.key, required this.onLogin});
  final void Function(bool login) onLogin;
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _form = GlobalKey<FormState>();
  bool showPassword = false;
  bool firstPhase = true;
  bool isLoading = false;
  bool invalidAvatar = false;

  String enteredEmail = '';
  String? enteredPassword = '';
  String enteredUsername = '';
  File? selectedAvatar;

  void imagePicker() {}
  void onNext() {
    final valid = _form.currentState!.validate();
    if (!valid) {
      enteredPassword = '';
      return;
    }
    _form.currentState!.save();

    firstPhase = false;
  }

  void pickImage() async {
    XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 200,
        maxWidth: 200,
        imageQuality: 60);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      selectedAvatar = File(pickedImage.path);
    });
  }

  void onFinish() async {
    final valid = _form.currentState!.validate();
    if (!valid || selectedAvatar == null) {
      setState(() {
        invalidAvatar = true;
      });
      return;
    }
    isLoading = true;
    setState(() {
      invalidAvatar = false;
    });

    _form.currentState!.save();
    try {
      final userCredentials = await auth.createUserWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword!,
      );
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('usersAvatar')
          .child('${userCredentials.user!.uid}.jpg');

      await storageRef.putFile(selectedAvatar!);
      final avatarURL = await storageRef.getDownloadURL();
      FirebaseFirestore.instance
          .collection('users_data')
          .doc(userCredentials.user!.uid)
          .set({
        'avatarURL': avatarURL,
        'userName': enteredUsername,
        'email': enteredEmail,
        'friendsList': [],
        'openchats': [],
        'friendRequests': [],
        'uid': userCredentials.user!.uid,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        customSnackBar('Network error. Please try again later', context);
      } else if (e.code == 'email-already-in-use') {
        customSnackBar(
          'email is already in use',
          context,
          'login instead',
          () {
            widget.onLogin(true);
          },
        );
      } else {
        customSnackBar('an error occurred..', context);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase1 = [
      const SizedBox(
        height: 16,
      ),
      TextFormField(
        keyboardType: TextInputType.emailAddress,
        initialValue: enteredEmail,
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
        initialValue: enteredPassword,
        decoration: custumInputFieldDecoration(
          'password',
          icon: Icons.password,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
            icon: Icon(
              (showPassword) ? Icons.visibility : Icons.visibility_off,
              color: Colors.white38,
            ),
          ),
        ),
        obscureText: !showPassword,
        validator: (value) {
          enteredPassword = value;
          if (value == null || value.isEmpty) {
            return 'please enter a password';
          } else if (value.trim().length < 8) {
            return 'password is too short';
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
      TextFormField(
        initialValue: enteredPassword,
        decoration: custumInputFieldDecoration(
          'confirm password',
          icon: Icons.password,
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please confirm your password';
          } else if (value != enteredPassword) {
            return 'passwords don\'t match';
          }
          return null;
        },
      ),
      const SizedBox(
        height: 16,
      ),
      ElevatedButton(
        onPressed: () {
          setState(() {
            onNext();
          });
        },
        child: const Text(
          'next',
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
            'Already a Chitchater? ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          InkWell(
            onTap: () {
              widget.onLogin(true);
            },
            child: Text(
              'login',
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
    ];

    final phase2 = [
      const SizedBox(
        height: 8,
      ),
      InkWell(
        onTap: pickImage,
        child: CircleAvatar(
          backgroundColor:
              invalidAvatar ? colorScheme.tertiary : colorScheme.primary,
          radius: 40,
          backgroundImage: selectedAvatar == null
              ? null
              : FileImage(
                  selectedAvatar!,
                ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'lib/files/images/defualt avatar.png',
                color: selectedAvatar != null
                    ? Colors.transparent
                    : colorScheme.surface,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.image,
                  color: invalidAvatar
                      ? colorScheme.tertiary
                      : colorScheme.primary,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, -3),
                      blurRadius: 10,
                      color: colorScheme.surface,
                    ),
                    Shadow(
                      offset: const Offset(-3, 0),
                      blurRadius: 10,
                      color: colorScheme.surface,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(
        height: 16,
      ),
      TextFormField(
        decoration: custumInputFieldDecoration(
          'what should we call you?',
          icon: Icons.person,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'please enter your username';
          }
          return null;
        },
        onSaved: (newValue) {
          enteredUsername = newValue!;
        },
      ),
      const SizedBox(
        height: 16,
      ),
      if (!isLoading) ...[
        ElevatedButton(
          onPressed: onFinish,
          child: const Text(
            'finish',
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {
            setState(() {
              firstPhase = true;
              showPassword = false;
            });
          },
          child: Text(
            'back',
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: colorScheme.onSurface),
          ),
        ),
      ] else
        CircularProgressIndicator(
          color: colorScheme.onSurface,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StrokeText(
          firstPhase ? 'Welcome to' : 'Almost in',
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
                      children: firstPhase ? phase1 : phase2,
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
