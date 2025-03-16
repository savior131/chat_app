import 'package:chat_app/screens/main%20screen/notifications%20list/notifictions_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key});
  getIncommingRequests(List<dynamic> requests) async {
    final requestIds = [];
    for (var request in requests) {
      requestIds.add(await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(request)
          .get());
    }
    final incommingnotifications = requestIds.where((element) =>
        !(element['status'] == 'pending' &&
            element['sender'] == FirebaseAuth.instance.currentUser!.uid));
    return incommingnotifications.toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users_data')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('error loading your notifications..'),
          );
        }

        final requests = snapshot.data!.data()!['friendRequests'];
        return FutureBuilder(
          future: getIncommingRequests(requests),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('error loading your notifications..'),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text('no notifications yet ;-;'),
              );
            }

            final incommingRequests = snapshot.data! as List<dynamic>;

            return ListView.builder(
              itemCount: incommingRequests.length,
              itemBuilder: (context, index) =>
                  NotifictionsListItem(request: incommingRequests[index]),
            );
          },
        );
      },
    );
  }
}
