import 'package:chat_app/custom%20widgets/custom_snack_bar.dart';
import 'package:chat_app/screens/chat%20screen/details.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chatRef, required this.friendRef});
  final DocumentSnapshot<Map<String, dynamic>> chatRef;
  final DocumentSnapshot<Map<String, dynamic>> friendRef;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String enteredText = '';
  final uid = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController controller = TextEditingController();
  Future<bool> hasPendingRequest() async {
    final friendRequests = widget.friendRef.data()!['friendRequests'] as List;
    final requestRefs = [];
    for (final friendRequest in friendRequests) {
      requestRefs.add(await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(friendRequest)
          .get());
    }
    final hasPending = requestRefs.any((request) =>
        request['sender'] == uid ||
        request['reciever'] == uid && request['status'] == 'pending');
    return hasPending;
  }

  onAddFriendRequest(context) async {
    final fid = widget.friendRef.data()!['uid'];
    final docRef =
        await FirebaseFirestore.instance.collection('friendRequests').add({
      'reciever': fid,
      'sender': uid,
      'createdAt': Timestamp.now(),
      'status': 'pending',
    });
    await docRef.update({
      'id': docRef.id,
    });

    final batch = FirebaseFirestore.instance.batch();
    batch.update(FirebaseFirestore.instance.collection('users_data').doc(fid), {
      'friendRequests': FieldValue.arrayUnion([docRef.id])
    });
    batch.update(FirebaseFirestore.instance.collection('users_data').doc(uid), {
      'friendRequests': FieldValue.arrayUnion([docRef.id])
    });
    customSnackBar('friend request sent', context);
    await batch.commit();
  }

  void sendMessage() async {
    enteredText = controller.text;
    if (enteredText.trim().isEmpty) {
      return;
    }
    controller.clear();
    final time = Timestamp.now();
    final chatClosed = widget.chatRef.data()!['status'] != 'closed';

    if (!chatClosed) {
      final isPendingRequest = await hasPendingRequest();
      if (!isPendingRequest) {
        customSnackBar(
            'can\'t chitchat with non friend ${widget.friendRef.data()!['userName']}',
            context,
            'send request', () async {
          await onAddFriendRequest(context);
        });
      } else {
        customSnackBar(
          'can\'t chitchat with non friend ${widget.friendRef.data()!['userName']} check your notifications',
          context,
        );
      }
      return;
    }
    await widget.chatRef.reference.collection('chat').add({
      'message': enteredText,
      'timeSent': time,
      'seen': false,
      'sender': FirebaseAuth.instance.currentUser!.uid,
    });
    await widget.chatRef.reference
        .update({'lastMessage': enteredText, 'lastMessageTime': time});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const Icon(Icons.arrow_back_rounded),
              Flexible(
                child: Hero(
                  tag: widget.friendRef.data()!['avatarURL'],
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.friendRef.data()!['avatarURL']),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: InkWell(
          splashColor: colorScheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Details(friendRef: widget.friendRef),
              ),
            );
          },
          child: SizedBox(
              width: double.infinity,
              child: Text(
                widget.friendRef.data()!['userName'],
              )),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/files/images/no bg.png',
              color: colorScheme.primary.withOpacity(0.3),
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              StreamBuilder(
                  stream: widget.chatRef.reference
                      .collection('chat')
                      .orderBy('timeSent', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Expanded(
                        child: Center(
                          child: Text('error loading chitchats'),
                        ),
                      );
                    } else if (snapshot.data!.docs.isEmpty) {
                      return const Expanded(child: SizedBox());
                    }
                    final loadedMessages = snapshot.data!.docs;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: ListView.builder(
                            reverse: true,
                            itemCount: loadedMessages.length,
                            itemBuilder: (context, index) {
                              final isMe = loadedMessages[index]['sender'] ==
                                  FirebaseAuth.instance.currentUser!.uid;
                              final messageId = loadedMessages[index]['sender'];
                              final nextMessageId =
                                  (index + 1 < loadedMessages.length)
                                      ? loadedMessages[index + 1]['sender']
                                      : null;
                              final firstMessage = messageId != nextMessageId;
                              return BubbleSpecialOne(
                                text: loadedMessages[index]['message'],
                                color: isMe
                                    ? colorScheme.primary
                                    : Color.lerp(colorScheme.surface,
                                        Colors.white, 0.07)!,
                                tail: firstMessage,
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                isSender: isMe,
                                seen: loadedMessages[index]['seen'],
                              );
                            }),
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) {
                          sendMessage();
                        },
                        controller: controller,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.white38),
                          hintText: 'message here..',
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
                      width: 8,
                    ),
                    IconButton(
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(0),
                        backgroundColor: WidgetStatePropertyAll(
                          colorScheme.onSurface,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: sendMessage,
                      icon: Icon(
                        Icons.send_rounded,
                        color: colorScheme.surface,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
