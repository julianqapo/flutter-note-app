// Name: Julian Qapo
// Date: November 16th, 2025
// Description: edit or delete note

//################## DONE ##################

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:note_app/settings_helper.dart';

class EditNoteScreen extends StatefulWidget {
  final String id;
  final String initialNote;

  const EditNoteScreen({
    required this.id,
    required this.initialNote,
    super.key,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController _noteController;
  Timer? _autoSaveTimer;
  bool _autoSaveEnabled = false;
  bool _isAutoSaving = false;
  bool _hasUnsavedChanges = false;
  bool _hasAutoSaved = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
    _loadAutoSaveSetting();
  }

  // Load auto save setting
  Future<void> _loadAutoSaveSetting() async {
    final autoSave = await SettingsHelper.getAutoSave();
    if (mounted) {
      setState(() {
        _autoSaveEnabled = autoSave;
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  // Auto save function that triggers after user stops typing
  void _scheduleAutoSave() {
    if (!_autoSaveEnabled) return;

    final currentText = _noteController.text.trim();
    final initialText = widget.initialNote.trim();
    
    // Only schedule auto save if text has actually changed
    if (currentText == initialText || currentText.isEmpty) {
      _hasUnsavedChanges = false;
      _hasAutoSaved = false;
      _autoSaveTimer?.cancel();
      if (mounted) {
        setState(() {});
      }
      return;
    }

    _autoSaveTimer?.cancel();
    _hasUnsavedChanges = true;

    // Wait 2 seconds after user stops typing before auto saving
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _performAutoSave();
    });
  }

  // Perform the actual auto save
  Future<void> _performAutoSave() async {
    if (!_autoSaveEnabled || !_hasUnsavedChanges) return;

    final newNoteText = _noteController.text.trim();
    
    // Don't auto save if note is empty or hasn't changed
    if (newNoteText.isEmpty || newNoteText == widget.initialNote.trim()) {
      _hasUnsavedChanges = false;
      return;
    }

    try {
      setState(() {
        _isAutoSaving = true;
      });

      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.id)
          .update({
            'note': newNoteText,
            'updated_at': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        setState(() {
          _isAutoSaving = false;
          _hasUnsavedChanges = false;
          _hasAutoSaved = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAutoSaving = false;
        });
      }
      // Silently fail for auto save - don't show error to user
    }
  }

  // update note
  Future<void> _updateNote() async {
    // Cancel auto save timer since we're manually saving
    _autoSaveTimer?.cancel();
    
    // get note and remove leading spaces
    final newNoteText = _noteController.text.trim();
    // if it's empty, do nothing
    if (newNoteText.isEmpty) return;
    // if not empty
    try {
      // make a request to update the note
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.id)
          .update({
            'note': newNoteText,
            'updated_at': FieldValue.serverTimestamp(),
          });
      
      // Mark as saved
      setState(() {
        _hasUnsavedChanges = false;
      });
      
      // show message to inform the user of success request
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note updated!')));
      // redirect to notes screen
      Navigator.of(context).pop();
      // somtheing goes wrong
    } catch (e) {
      // show error message to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    }
  }

  // function to delete the note
  Future<void> _deleteNote() async {
    // show modal of type bool (confirmation) to avoid accedintal delete
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Note?',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          ElevatedButton(
            // return false, and abort delete (return false)
            onPressed: () => Navigator.of(context).pop(false),
            // adding style to the button
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.black,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            // confirm delete (return true)
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    // delete note if the value is true
    if (shouldDelete == true) {
      try {
        // make a request to firebase store to remove the note based on its id
        await FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.id)
            .delete();
        // display confirmation message of successful request
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note deleted!')));
        // redirect to notes screen
        Navigator.of(context).pop();
        // handle error
      } catch (e) {
        // display error message if the request to firebase store was not successful
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting note: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // note's letter count
    final noteLength = _noteController.text.length;
    FlutterTts flutterTts = FlutterTts();
    ShakeDetector detector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) async {
        // Access detailed shake information
        print('Shake direction: ${event.direction}');
        print('Shake force: ${event.force}');
        print('Shake timestamp: ${event.timestamp}');
        await flutterTts.speak(widget.initialNote);
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        // show back icon to navigate back to the notes screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // redirect to notes screen, save first if auto save is enabled
          onPressed: () async {
            // Cancel pending auto save timer
            _autoSaveTimer?.cancel();
            
            // If auto save is enabled and there are unsaved changes, save before leaving
            if (_autoSaveEnabled && _hasUnsavedChanges) {
              await _performAutoSave();
            }
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Row(
          children: [
            const Text(
              'Edit Post',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            if (_autoSaveEnabled && _isAutoSaving)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
            if (_autoSaveEnabled && !_isAutoSaving && !_hasUnsavedChanges && _hasAutoSaved)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.check_circle, color: Colors.green, size: 16),
              ),
          ],
        ),
        // add widget list
        actions: [
          // delete button widget
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _deleteNote,
            tooltip: 'Delete Post',
          ),
          const SizedBox(width: 8),
          // update button
          ElevatedButton(
            onPressed: _updateNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Signature Blue color
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Rounded pill shape
              ),
            ),
            child: const Text(
              'Update', // The action text
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // add space
          const SizedBox(width: 18),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // expand screen, take available space
            Expanded(
              child: TextField(
                controller: _noteController,
                onChanged: (_) {
                  // rebuild widget to update letter counter
                  setState(() {});
                  // Schedule auto save if enabled
                  _scheduleAutoSave();
                },
                decoration: InputDecoration(
                  // remove border
                  border: InputBorder.none,
                  hintText: "What's happening? (Edit your note here)",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.4,
                  color: Colors.black,
                ),
                // number of lines to show
                maxLines: null,
              ),
            ),

            // line
            Divider(color: Colors.lightGreen),

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
              child: Row(
                // display from the right side
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    // letter counter
                    '$noteLength characters',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
