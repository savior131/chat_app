import 'package:chat_app/custom%20widgets/custom_circular_avatar.dart';
import 'package:chat_app/custom%20widgets/custom_snack_bar.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class NotifictionsListItem extends StatelessWidget {
  const NotifictionsListItem({super.key, required this.request});
  final dynamic request;

  @override
  Widget build(BuildContext context) {
    onRejectRequest() async {
      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(request['id'])
          .update({
        'status': 'rejected',
      });
    }

    onAcceptRequest() async {
      final batch = FirebaseFirestore.instance.batch();
      final chatId = request['sender'].hashCode >= request['reciever'].hashCode
          ? '${request['sender']}_${request['reciever']}'
          : '${request['reciever']}_${request['sender']}';
      final docRef = FirebaseFirestore.instance.collection('Chats').doc(chatId);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        docRef.set({
          'lastMessage': '',
          'lastMessageTime': Timestamp.now(),
          'status': 'open',
        });
      } else {
        docRef.update({
          'status': 'open',
        });
      }

      batch.update(
          FirebaseFirestore.instance
              .collection('friendRequests')
              .doc(request['id']),
          {
            'status': 'accepted',
          });

      batch.update(
        FirebaseFirestore.instance
            .collection('users_data')
            .doc(request['reciever']),
        {
          'friendsList': FieldValue.arrayUnion([
            request['sender'],
          ]),
          'chats': FieldValue.arrayUnion([
            docRef.id,
          ]),
        },
      );
      batch.update(
        FirebaseFirestore.instance
            .collection('users_data')
            .doc(request['sender']),
        {
          'friendsList': FieldValue.arrayUnion([
            request['reciever'],
          ]),
          'chats': FieldValue.arrayUnion([
            docRef.id,
          ]),
        },
      );
      await batch.commit();
    }

    getSender(bool forMe) async {
      final sender = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(forMe ? request['sender'] : request['reciever'])
          .get();

      return sender;
    }

    final forMe = request['reciever'] == FirebaseAuth.instance.currentUser!.uid;
    return FutureBuilder(
      future: getSender(forMe),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('loading...'),
            subtitle: Text('loading...'),
          );
        } else if (snapshot.hasError) {
          return const SizedBox();
        } else if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const SizedBox();
        }
        final status = request['status'];

        return ListTile(
          leading: CustomCircularAvatar(
              url: snapshot.data!.data()!['avatarURL'], radius: 25),
          title: Text(snapshot.data!.data()!['userName']),
          subtitle: Text(forMe
              ? status == 'pending'
                  ? 'wants to be your friend'
                  : status == 'accepted'
                      ? 'is now your friend'
                      : 'is so sad and rejected'
              : status == 'accepted'
                  ? 'accepted your friend request'
                  : 'rejected you ahahahaha'),
          trailing: status == 'pending'
              ? SizedBox(
                  width: 96,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          customSnackBar(
                              'request from ${snapshot.data!.data()!['userName']} has been removed',
                              context);

                          await onRejectRequest();
                        },
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.error,
                        ),
                      ),
                      IconButton.filled(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(colorScheme.primary)),
                        onPressed: () async {
                          customSnackBar(
                              '${snapshot.data!.data()!['userName']} is now your friend',
                              context);
                          await onAcceptRequest();
                        },
                        icon: Icon(
                          Icons.check,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                )
              : status == 'accepted'
                  ? const Text(
                      'accepted',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'rejected',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.error),
                    ),
        );
      },
    );
  }
}
