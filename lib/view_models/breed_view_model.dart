import 'package:flutter/material.dart';
import '../models/breeding_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BreedingRecordsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<BreedingRecord> records = [];

  /// Fetch breeding records for a specific livestock
  Future<void> fetchRecords(int livestockId) async {
    try {
      final data = await supabase
          .from('breeding_record')
          .select()
          .eq('livestock_id', livestockId);

      records = (data as List)
          .map((m) => BreedingRecord.fromMap(m as Map<String, dynamic>))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching breeding records: $e');
    }
  }

  /// Add a new breeding record
  Future<void> addRecord(BreedingRecord record) async {
    try {
      await supabase.from('breeding_record').insert(record.toMap());
      await fetchRecords(record.livestockId);
    } catch (e) {
      debugPrint('Error adding breeding record: $e');
    }
  }

  /// Delete a breeding record
  Future<void> deleteRecord(int id, int livestockId) async {
    try {
      await supabase.from('breeding_record').delete().eq('id', id);
      await fetchRecords(livestockId);
    } catch (e) {
      debugPrint('Error deleting breeding record: $e');
    }
  }

  /// Update an existing breeding record
  Future<void> updateRecord(BreedingRecord record) async {
    if (record.id == null) return;
    try {
      await supabase
          .from('breeding_record')
          .update(record.toMap())
          .eq('id', record.id!);
      await fetchRecords(record.livestockId);
    } catch (e) {
      debugPrint('Error updating breeding record: $e');
    }
  }
}
