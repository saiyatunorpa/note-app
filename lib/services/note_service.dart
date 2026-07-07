import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

/// Service class that handles all Firestore CRUD operations for notes.
class NoteService {
  static const String _collection = 'notes';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the notes collection reference ordered by most recently updated.
  Query<Map<String, dynamic>> get notesQuery =>
      _db.collection(_collection).orderBy('updatedAt', descending: true);

  /// Stream of all notes, sorted by updatedAt descending.
  Stream<List<Note>> notesStream() {
    return notesQuery.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList(),
        );
  }

  /// Adds a new note to Firestore. Returns the new document ID.
  Future<String> addNote({
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final docRef = await _db.collection(_collection).add({
      'title': title.trim(),
      'description': description.trim(),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return docRef.id;
  }

  /// Updates an existing note in Firestore.
  Future<void> updateNote({
    required String id,
    required String title,
    required String description,
  }) async {
    await _db.collection(_collection).doc(id).update({
      'title': title.trim(),
      'description': description.trim(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Deletes a note from Firestore by its document ID.
  Future<void> deleteNote(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
