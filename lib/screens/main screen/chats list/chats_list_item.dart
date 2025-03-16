import 'package:chat_app/custom%20widgets/custom_circular_avatar.dart';
import 'package:chat_app/screens/chat%20screen/chat_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class ChatsListItem extends StatefulWidget {
  const ChatsListItem({super.key, required this.chatRef});
  final DocumentSnapshot<Map<String, dynamic>> chatRef;
  @override
  State<ChatsListItem> createState() => _ChatsListItemState();
}

class _ChatsListItemState extends State<ChatsListItem> {
  Future<DocumentSnapshot<Map<String, dynamic>>> onDisplay() async {
    final chatId = widget.chatRef.id;
    List<String> splitIds = chatId.split("_");

    String friendId = splitIds
        .firstWhere((part) => part != FirebaseAuth.instance.currentUser!.uid);
    final friendRef = await FirebaseFirestore.instance
        .collection('users_data')
        .doc(friendId)
        .get();

    return friendRef;
  }

  String humanReadableTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inSeconds < 60) {
      return "${difference.inSeconds} seconds ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else if (difference.inDays < 30) {
      return "${difference.inDays ~/ 7} weeks ago";
    } else if (difference.inDays < 365) {
      return "${difference.inDays ~/ 30} months ago";
    } else {
      return DateFormat('y/M/d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: onDisplay(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('error'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('laoding'),
            subtitle: Text('loading'),
            trailing: Text('1m years ago'),
          );
        }
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                      chatRef: widget.chatRef, friendRef: snapshot.data!),
                ));
          },
          child: ListTile(
            leading: Hero(
              tag: snapshot.data!['avatarURL'],
              child: CustomCircularAvatar(
                  url: snapshot.data!['avatarURL'], radius: 30),
            ),
            title: Text(snapshot.data!['userName']),
            subtitle: Text(widget.chatRef.data()!['lastMessage']),
            trailing: Text(
              humanReadableTimestamp(
                  widget.chatRef.data()!['lastMessageTime'].toDate()),
            ),
          ),
        );
      },
    );
  }
}
