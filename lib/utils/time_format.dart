// Helper function to format the timestamp
import 'package:cloud_firestore/cloud_firestore.dart';

/*String formatTimeAgo(Timestamp timestamp) {
  final now = DateTime.now();
  final postTime = timestamp.toDate();
  final difference = now.difference(postTime);

  if (difference.inSeconds < 60) {
    return 'now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months months ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years years ago';
  }
}*/

String formatTimeAgo(Timestamp timestamp) {
  final now = DateTime.now();
  final postTime = timestamp.toDate();
  final difference = now.difference(postTime);

  if (difference.inSeconds < 5) {
    // For very recent posts
    return 'just now';
  } else if (difference.inMinutes < 1) {
    // If less than a minute, show seconds
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inHours < 1) {
    // If less than an hour, show minutes
    if (difference.inMinutes == 1) {
      return '1 minute ago';
    }
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inDays < 1) {
    // If less than a day, show hours
    if (difference.inHours == 1) {
      return '1 hour ago';
    }
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    // If less than a week, show days
    if (difference.inDays == 1) {
      // Use "Yesterday" for a more natural feel
      return 'Yesterday';
    }
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    // A new condition for weeks
    final weeks = (difference.inDays / 7).floor();
    if (weeks == 1) {
      return '1 week ago';
    }
    return '$weeks weeks ago';
  } else if (difference.inDays < 365) {
    // If less than a year, show months
    final months = (difference.inDays / 30).floor();
    if (months == 1) {
      return '1 month ago';
    }
    return '$months months ago';
  } else {
    // Show years
    final years = (difference.inDays / 365).floor();
    if (years == 1) {
      return '1 year ago';
    }
    return '$years years ago';
  }
}
