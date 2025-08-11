import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/livestock.dart';
import '../services/notification_service.dart';

class LivestockViewModel extends ChangeNotifier {
  /// List of all livestock entries
  List<Livestock> livestocks = [];

  /// Supabase client instance
  final supabase = Supabase.instance.client;

  /// Fetches all livestock records from the 'livestock' table
  Future<void> fetchLivestocks() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user – cannot fetch livestocks.');
        return;
      }

      // Query only the rows whose user_id matches the current user
      final data =
          await supabase.from('livestock').select().eq('user_id', user.id);

      livestocks = (data as List)
          .map((row) => Livestock.fromMap(row as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (error) {
      debugPrint('Error fetching livestocks: $error');
    }
  }

  /// Adds a new livestock record
  Future<void> addLivestock(Livestock livestock) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final inserted = await supabase
          .from('livestock')
          .insert(livestock.toMap()..['owner_id'] = userId)
          .select()
          .single();
      await supabase.from('livestock').insert(livestock.toMap());
      // 👇 INSERT NOTIFICATION **AFTER SUCCESS**
      await NotificationService(supabase).create(
        recipientId: userId,
        title: 'Livestock added',
        body: '“${inserted['name']}” has been added.',
      );
      await fetchLivestocks();
    } catch (error) {
      debugPrint('Error adding livestock: $error');
    }
  }

  /// Updates an existing livestock record
  Future<void> updateLivestock(Livestock livestock) async {
    if (livestock.id == null) return;
    try {
      final userId = supabase.auth.currentUser!.id;

      final updated = await supabase
          .from('livestock')
          .update(livestock.toMap())
          .eq('id', livestock.id!)
          .select()
          .single();

      // 👇 notification
      await NotificationService(supabase).create(
        recipientId: userId,
        title: 'Livestock updated',
        body: '“${updated['name']}” details were updated.',
      );
      await fetchLivestocks();
    } catch (error) {
      debugPrint('Error updating livestock: $error');
    }
  }

  /// Deletes a livestock record by ID
  Future<void> deleteLivestock(int id) async {
    try {
      await supabase.from('livestock').delete().eq('id', id);
      await fetchLivestocks();
    } catch (error) {
      debugPrint('Error deleting livestock: $error');
    }
  }
}
