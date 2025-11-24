// Name: Julian Qapo
// Date: November 16th, 2025
// Description: note strucutre to display notes

//################## DONE ##################

import 'package:flutter/material.dart';
import 'package:note_app/edit_note.dart';

class NoteCard extends StatelessWidget {
  final String id;
  final String note;
  final String email;
  // final String name;
  final String createdAt;
  final String updatedAt;
  final bool liked;
  final bool showTimestamps;
  // pass function to note card
  final void Function(bool currentStatus)
  onLikeToggle; // New callback for handling tap

  const NoteCard({
    required this.id,
    required this.note,
    required this.email,
    // required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.liked,
    required this.showTimestamps,
    required this.onLikeToggle, // New required field
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // clickable widget to redirect to edit note screen
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            // pass not id and note to edit screen
            builder: (context) => EditNoteScreen(id: id, initialNote: note),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // split note card into two rows (avatar and note info)
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // avatar
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
            // space
            const SizedBox(width: 12),
            // note info
            Expanded(
              // split note info into three columns
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // split first column into two rows (email and favorite icon)
                  Row(
                    // make widget children far away from each other
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // name and email (I copied twitter style)
                      Row(
                        children: [
                          Text(
                            email.split('@').first,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '@${email.split('@').first}',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                      // wrap icon with click widget
                      GestureDetector(
                        onTap: () => onLikeToggle(liked),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 18,
                              // change color based on liked value
                              color: liked ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // add space
                  const SizedBox(height: 4),
                  // display note
                  Text(
                    note,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  // add space from the top and conditionally show timestamps
                  if (showTimestamps)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      // split this section into two (create at and updated at)
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // split string to remove extra time info
                            // "Created : ${createdAt.substring(0, 10)}",
                            createdAt,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),

                          Text(
                            "Updated : $updatedAt",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
