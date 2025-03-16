import 'package:chat_app/screens/main%20screen/chats%20list/chats_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatefulWidget {
  const ChatsList({super.key});
  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> onViewChats() async {
    final userRef = await FirebaseFirestore.instance
        .collection('users_data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final chatIDs = userRef.data()!['chats'] ?? [];
    List<DocumentSnapshot<Map<String, dynamic>>> chatRefs = [];
    for (final chatID in chatIDs) {
      chatRefs.add(await FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatID)
          .get());
    }
    return chatRefs;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users_data')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
          future: onViewChats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('no chitchats yet, consider adding friends'),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('error loading chitchats'),
              );
            }
            final Refs = snapshot.data!;
            return ListView.builder(
              itemCount: Refs.length,
              itemBuilder: (context, index) =>
                  ChatsListItem(chatRef: Refs[index]),
            );
          },
        );
      },
    );
  }
}
