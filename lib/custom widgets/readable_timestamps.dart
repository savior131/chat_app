import 'package:intl/intl.dart';

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
