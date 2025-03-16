import 'package:chat_app/screens/add%20friend%20screen/friend_request_list_item.dart';

import 'package:chat_app/widgets/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final controller = TextEditingController();
  String enteredUsername = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;
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
        title: const Text('discover new friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    enteredUsername = controller.text;
                  });
                },
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.search),
                  prefixIcon: const Icon(null),
                  hintStyle: const TextStyle(color: Colors.white38),
                  hintText: 'search via username..',
                  filled: true,
                  fillColor: colorScheme.surface,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users_data')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  const Center(
                    child: Text('how unexpected!! something went wrong..'),
                  );
                }

                final loadedStrangers = snapshot.data!.docs
                    .where(
                      (element) =>
                          element['uid'] != uid &&
                          !element['friendsList'].contains(uid) &&
                          (enteredUsername == ''
                              ? true
                              : element['userName'].contains(enteredUsername)),
                    )
                    .toList();
                if (loadedStrangers.isEmpty && enteredUsername.isNotEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text('no matches found..'),
                    ),
                  );
                } else if (loadedStrangers.isEmpty && enteredUsername.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text(
                          'seems like bro is already friend to everyone ^-^'),
                    ),
                  );
                }

                return Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemCount: loadedStrangers.length,
                    itemBuilder: (context, index) => FriendRequestListItem(
                      element: loadedStrangers[index],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
