import 'package:chat_app/custom%20widgets/custom_circular_avatar.dart';
import 'package:chat_app/custom%20widgets/custom_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestListItem extends StatelessWidget {
  const FriendRequestListItem({super.key, required this.element});
  final QueryDocumentSnapshot<Map<String, dynamic>> element;

  Future<DocumentSnapshot<Map<String, dynamic>>> onGetStatus() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fid = element['uid'];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('sender', isEqualTo: uid)
        .where('reciever', isEqualTo: fid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final docRef = querySnapshot.docs.first.reference;
      return FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(docRef.id)
          .get();
    }
    final querySnapshot2 = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('reciever', isEqualTo: uid)
        .where('sender', isEqualTo: fid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    final docRef = querySnapshot2.docs.first.reference;
    return FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(docRef.id)
        .get();
  }

  onAddFriendRequest(context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fid = element['uid'];
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
    customSnackBar('friend request sent to ${element['userName']}', context);
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCircularAvatar(url: element['avatarURL'], radius: 40),
          const SizedBox(
            height: 8,
          ),
          Text(
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            element['userName'],
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 8,
          ),
          FutureBuilder(
            future: onGetStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                return SizedBox(
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text((snapshot.data!['sender'] ==
                                FirebaseAuth.instance.currentUser!.uid)
                            ? 'pending'
                            : 'action required'),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.watch_later_outlined,
                          color: Colors.white54,
                          size: 20,
                        )
                      ]),
                );
              } else {
                return OutlinedButton(
                  onPressed: () async {
                    await onAddFriendRequest(context);
                  },
                  child: const Text('send request'),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
