// Name: Tayyib Azam
// Date: November 24th, 2025
// Description: helper functions to read settings

//################## DONE ##################

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsHelper {
  // get user email for settings document ID
  static String? _getUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  // get show timestamps setting from Firestore
  static Future<bool> getShowTimestamps() async {
    try {
      final userEmail = _getUserEmail();
      if (userEmail == null) return true;

      final doc = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userEmail)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['show_timestamps'] as bool? ?? true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  // Get auto save setting from Firestore
  static Future<bool> getAutoSave() async {
    try {
      final userEmail = _getUserEmail();
      if (userEmail == null) return true;

      final doc = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userEmail)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['auto_save'] as bool? ?? true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  // Get sort order setting from Firestore
  static Future<String> getSortOrder() async {
    try {
      final userEmail = _getUserEmail();
      if (userEmail == null) return 'newest';

      final doc = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userEmail)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['sort_order'] as String? ?? 'newest';
      }
      return 'newest';
    } catch (e) {
      return 'newest';
    }
  }
}
