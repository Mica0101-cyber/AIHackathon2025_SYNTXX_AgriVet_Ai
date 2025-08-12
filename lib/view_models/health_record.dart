import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_record.dart';

class HealthRecordsViewModel extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  final int livestockId;  // siguraduhing int talaga ito
  List<HealthRecord> records = [];

  HealthRecordsViewModel({required this.livestockId});

  Future<void> fetchRecords() async {
    try {
      final data = await supabase
          .from('health_records')  // use plural everywhere
          .select()
          .eq('livestock_id', livestockId);

      records = (data as List)
          .map((m) => HealthRecord.fromJson(m as Map<String, dynamic>))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching health records: $e');
    }
  }

  Future<void> addRecord(HealthRecord record) async {
    try {
      await supabase.from('health_records').insert(record.toJson());
      await fetchRecords();
    } catch (e) {
      debugPrint('Error adding health record: $e');
    }
  }

  Future<void> deleteRecord(int id) async {
    try {
      await supabase.from('health_records').delete().eq('id', id);
      await fetchRecords();
    } catch (e) {
      debugPrint('Error deleting health record: $e');
    }
  }

  Future<void> updateRecord(HealthRecord record) async {
    if (record.id == null) return;
    try {
      await supabase
          .from('health_records')
          .update(record.toJson())
          .eq('id', record.id!);
      await fetchRecords();
    } catch (e) {
      debugPrint('Error updating health record: $e');
    }
  }
}