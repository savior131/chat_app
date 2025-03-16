import 'package:chat_app/screens/add%20friend%20screen/add_friend_screen.dart';
import 'package:chat_app/screens/main%20screen/friends%20list/friends_list_item.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users_data')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          return Stack(children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (snapshot.hasError)
              const Text('an error occured...')
            else if (snapshot.data!['friendsList'].isEmpty)
              const Center(
                child: Text('damn bro you have no fiends 0-0'),
              )
            else
              ListView.builder(
                itemCount: snapshot.data!['friendsList'].length + 1,
                itemBuilder: (context, index) =>
                    index < snapshot.data!['friendsList'].length
                        ? FriendsListItem(
                            friendID: snapshot.data!['friendsList'][index],
                          )
                        : const SizedBox(height: 150),
              ),
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddFriendScreen(),
                  ),
                ),
                child: Card(
                  color: colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.group_add,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ]);
        });
  }
}
