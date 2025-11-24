// Name: Julian Qapo
// Date: November 16th, 2025
// Description: display all notes, add note

//################## DONE ##################

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/note_card.dart';
import 'package:note_app/settings_helper.dart';

class UserNotesScreen extends StatefulWidget {
  const UserNotesScreen({super.key});

  @override
  State<UserNotesScreen> createState() => _UserNotesScreenState();
}

class _UserNotesScreenState extends State<UserNotesScreen> {
  bool _showTimestamps = true;
  String _sortOrder = 'newest';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings when screen initializes
  Future<void> _loadSettings() async {
    final showTimestamps = await SettingsHelper.getShowTimestamps();
    final sortOrder = await SettingsHelper.getSortOrder();
    if (mounted) {
      setState(() {
        _showTimestamps = showTimestamps;
        _sortOrder = sortOrder;
      });
    }
  }

  // Reload settings when returning from settings page
  Future<void> _reloadSettings() async {
    await _loadSettings();
  }

  // function to update liked for each note in firestore database
  Future<void> _toggleLikeStatus(String noteId, bool currentStatus) async {
    try {
      // make request to change liked value based on its id
      await FirebaseFirestore.instance.collection('notes').doc(noteId).update({
        // make it the opposite
        'liked': !currentStatus,
      });
    } catch (e) {
      print('something went wrong: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // get user if there is one
    final user = FirebaseAuth.instance.currentUser;
    // get email from user object
    final userEmail = user?.email;

    // if no email, redirect to home page
    if (userEmail == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
      // while updating the state, show circular progress
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // if user is signed in, make request to retrieve notes and filter them based on email
    // Always query with descending: true to use existing index, then reverse in memory if needed
    final notesStream = FirebaseFirestore.instance
        .collection('notes')
        .where('email', isEqualTo: userEmail)
        .orderBy('created_at', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        // display user email
        title: Text(
          'Hello ${userEmail.split('@').first}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // settings button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () async {
              await Navigator.of(context).pushNamed('/settings');
              // Reload settings when returning from settings page
              _reloadSettings();
            },
          ),
          // sign out button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            // log out and redirect to home page
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      // display data in real time to monitor any change
      body: StreamBuilder<QuerySnapshot>(
        stream: notesStream,
        builder: (context, snapshot) {
          // error message if it fails to load the notes
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          }
          // loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            // show circular progress while loading notes
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          // retrieve notes
          var notes = snapshot.data!.docs;
          
          // Reverse the list if we want oldest first (to avoid needing a new Firestore index)
          if (_sortOrder == 'oldest') {
            notes = notes.reversed.toList();
          }
          
          // no note has been created yet
          if (notes.isEmpty) {
            // centre widget to centre the text content wrapted with padding widget to add spaceing
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Your notes are empty. Tap the blue button to create your first note!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            );
          }
          // if notes are note empty
          return ListView.builder(
            itemCount: notes.length,
            // loop through the notes
            itemBuilder: (context, index) {
              // get each note starting from index 0
              final noteDocument = notes[index];
              final noteData = noteDocument.data()! as Map<String, dynamic>;
              return Column(
                children: [
                  NoteCard(
                    // pass parameter to noteCard widget that was created in note_card.dart
                    note: noteData['note'] as String,
                    email: noteData['email'] as String,
                    // because it takes time for data to be retrieved from the database
                    // I was getting an error for less than one second
                    // Another exception was thrown: type 'Null' is not a subtype of type 'Timestamp' in type cast
                    // I looked it up online, (Firestore processes this asynchronously. For a very brief period immediately after creation, a document read might return null for these fields, as the server hasn't yet written the actual timestamp value.)
                    createdAt: (noteData['created_at'] == null)
                        ? "wating for data"
                        // ? ""
                        // convert timestamp to string
                        : (noteData['created_at'] as Timestamp)
                              .toDate()
                              .toString()
                              .substring(0, 10),
                    // updatedAt: (noteData['updated_at'] is String)
                    updatedAt: (noteData['updated_at'] == null)
                        // empty string, because it overflows
                        ? "Never updated"
                        // : (noteData['updated_at'] == noteData['created_at'])
                        // ? "Never updated"
                        : (noteData['updated_at'] as Timestamp)
                              .toDate()
                              .toString()
                              .substring(0, 10),
                    id: noteDocument.id,
                    liked: (noteData['liked'] as bool),
                    showTimestamps: _showTimestamps,
                    // pass the toggle function with note id to be able to change liked once clicked
                    onLikeToggle: (currentStatus) =>
                        _toggleLikeStatus(noteDocument.id, currentStatus),
                  ),
                  // line at the end of each note to split them
                  const Divider(height: 1, thickness: 0.5, color: Colors.green),
                ],
              );
            },
          );
        },
      ),
      // floating button to add note
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context, userEmail),
        // change style
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// function to make request to firebase store to add note
Future<void> _showAddNoteDialog(BuildContext context, String userEmail) {
  // track text field
  final TextEditingController noteController = TextEditingController();
  // show modal
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Add Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          // track text content
          controller: noteController,
          decoration: InputDecoration(
            hintText: "What's on your mind today?",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          maxLines: 5,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteController.text.trim().isNotEmpty) {
                // FieldValue time = FieldValue.serverTimestamp();
                final newNote = <String, dynamic>{
                  "email": userEmail,
                  "note": noteController.text.trim(),
                  // automatically assign value with current time
                  // "created_at": time,
                  // "updated_at": time,
                  "created_at": FieldValue.serverTimestamp(),
                  "updated_at": null,
                  "liked": false, // 🆕 Initialize new notes as not liked
                };
                // make request to store the note in notes collection
                await FirebaseFirestore.instance
                    .collection("notes")
                    .add(newNote);
                Navigator.of(context).pop();
                // print("");
                // print("#########\n\n\n\n\n\n\n\n");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
