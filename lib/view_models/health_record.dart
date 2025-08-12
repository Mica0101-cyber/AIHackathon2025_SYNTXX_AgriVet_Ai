import 'package:flutter/material.dart';
import '../models/health_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthRecordsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<HealthRecord> records = [];

  /// Fetch health records for a specific livestock
  Future<void> fetchRecords(int livestockId) async {
    try {
      final data = await supabase
          .from('health_record')
          .select()
          .eq('livestock_id', livestockId);
      records = (data as List)
          .map((m) => HealthRecord.fromMap(m as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching health records: $e');
    }
  }

  /// Add a new health record
  Future<void> addRecord(HealthRecord record) async {
    try {
      await supabase.from('health_record').insert(record.toMap());
      await fetchRecords(record.livestockId);
    } catch (e) {
      debugPrint('Error adding health record: $e');
    }
  }

  /// Delete a health record
  Future<void> deleteRecord(int id, int livestockId) async {
    try {
      await supabase.from('health_record').delete().eq('id', id);
      await fetchRecords(livestockId);
    } catch (e) {
      debugPrint('Error deleting health record: $e');
    }
  }

  /// Update an existing health record
  Future<void> updateRecord(HealthRecord record) async {
    if (record.id == null) return;
    try {
      await supabase
          .from('health_record')
          .update(record.toMap())
          .eq('id', record.id!);
      await fetchRecords(record.livestockId);
    } catch (e) {
      debugPrint('Error updating health record: $e');
    }
  }
}
