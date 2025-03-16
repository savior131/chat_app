import 'package:chat_app/custom%20widgets/custom_circular_avatar.dart';
import 'package:chat_app/custom%20widgets/custom_snack_bar.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class Details extends StatelessWidget {
  const Details({
    super.key,
    required this.friendRef,
  });
  final DocumentSnapshot<Map<String, dynamic>> friendRef;
  @override
  Widget build(BuildContext context) {
    removeFriend(String name) async {
      final chatId = friendRef.id.hashCode >=
              FirebaseAuth.instance.currentUser!.uid.hashCode
          ? '${friendRef.id}_${FirebaseAuth.instance.currentUser!.uid}'
          : '${FirebaseAuth.instance.currentUser!.uid}_$friendRef.id';

      final batch = FirebaseFirestore.instance.batch();
      batch.update(
          FirebaseFirestore.instance.collection('users_data').doc(friendRef.id),
          {
            'friendsList':
                FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
          });
      batch.update(
          FirebaseFirestore.instance
              .collection('users_data')
              .doc(FirebaseAuth.instance.currentUser!.uid),
          {
            'friendsList': FieldValue.arrayRemove([friendRef.id])
          });

      batch.update(FirebaseFirestore.instance.collection('Chats').doc(chatId),
          {'status': 'closed'});
      customSnackBar('$name was removed from your friends list', context);

      await batch.commit();
      Navigator.pop(context);
    }

    onRemoveFriend(String name) async {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('remove $name'),
          content: const Text(
              'removing friends means you can no longer chitchat with them.\nare you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await removeFriend(name);
              },
              child: const Text('sure'),
            ),
          ],
        ),
      );
    }

    bool isFriend = friendRef
        .data()!['friendsList']
        .contains(FirebaseAuth.instance.currentUser!.uid);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        actions: isFriend
            ? [
                PopupMenuButton(
                  offset: const Offset(0, 45),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () async {
                        await onRemoveFriend(friendRef.data()!['userName']);
                      },
                      child: const Text(
                        'remove friend',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  ],
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: friendRef.data()!['avatarURL'],
                child: CustomCircularAvatar(
                  url: friendRef.data()!['avatarURL'],
                  radius: 60,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                friendRef.data()!['userName'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                friendRef.data()!['email'],
                style: const TextStyle(color: Colors.white38),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isFriend ? 'friend' : 'not a friend',
                    style: TextStyle(
                        color:
                            isFriend ? colorScheme.primary : colorScheme.error,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  isFriend
                      ? Icon(Icons.check, color: colorScheme.primary)
                      : Icon(Icons.close, color: colorScheme.error),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
