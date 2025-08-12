import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feed_record.dart';

class FeedRecordsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<FeedRecord> records = [];

  /// Fetch feeding records for a specific livestock
  Future<void> fetchRecords(int livestockId) async {
    try {
      final data = await supabase
          .from('feeding_record')
          .select()
          .eq('livestock_id', livestockId);
      records = (data as List)
          .map((m) => FeedRecord.fromMap(m as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching feed records: $e');
    }
  }

  /// Add a new feed record
  Future<void> addRecord(FeedRecord record) async {
    try {
      await supabase.from('feeding_record').insert(record.toMap());
      await fetchRecords(record.livestockId);
    } catch (e) {
      debugPrint('Error adding feed record: $e');
    }
  }

  /// Delete a feed record
  Future<void> deleteRecord(int id, int livestockId) async {
    try {
      await supabase.from('feeding_record').delete().eq('id', id);
      await fetchRecords(livestockId);
    } catch (e) {
      debugPrint('Error deleting feed record: $e');
    }
  }

  /// Update an existing feed record
  Future<void> updateRecord(FeedRecord record) async {
    if (record.id == null) return;
    try {
      await supabase
          .from('feeding_record')
          .update(record.toMap())
          .eq('id', record.id!);
      await fetchRecords(record.livestockId);
    } catch (e) {
      debugPrint('Error updating feed record: $e');
    }
  }
}
