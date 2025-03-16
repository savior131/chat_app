import 'package:chat_app/custom%20widgets/custom_circular_avatar.dart';
import 'package:chat_app/custom%20widgets/custom_snack_bar.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class FriendsListItem extends StatelessWidget {
  const FriendsListItem({super.key, required this.friendID});
  final String friendID;

  @override
  Widget build(BuildContext context) {
    removeFriend(String name) async {
      final chatId =
          friendID.hashCode >= FirebaseAuth.instance.currentUser!.uid.hashCode
              ? '${friendID}_${FirebaseAuth.instance.currentUser!.uid}'
              : '${FirebaseAuth.instance.currentUser!.uid}_$friendID';

      final batch = FirebaseFirestore.instance.batch();
      batch.update(
          FirebaseFirestore.instance.collection('users_data').doc(friendID), {
        'friendsList':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
      batch.update(
          FirebaseFirestore.instance
              .collection('users_data')
              .doc(FirebaseAuth.instance.currentUser!.uid),
          {
            'friendsList': FieldValue.arrayRemove([friendID])
          });

      batch.update(FirebaseFirestore.instance.collection('Chats').doc(chatId),
          {'status': 'closed'});
      customSnackBar('$name was removed from your friends list', context);
      await batch.commit();
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

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users_data')
          .doc(friendID)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('loading...'),
            subtitle: Text('loading...'),
          );
        } else {
          return ListTile(
            leading: CustomCircularAvatar(
                url: snapshot.data!['avatarURL'], radius: 25),
            title: Text(snapshot.data!['userName']),
            subtitle: Text(snapshot.data!['email']),
            trailing: IconButton(
              onPressed: () async {
                await onRemoveFriend(snapshot.data!['userName']);
              },
              icon: Icon(
                Icons.person_remove,
                color: colorScheme.error,
              ),
            ),
          );
        }
      },
    );
  }
}
