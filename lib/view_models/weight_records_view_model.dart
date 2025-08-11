// lib/view_models/weight_record_view_model.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weight_record.dart';
import '../services/notification_service.dart';

enum WeightBand { none, lechonon, disposal, overweight }

WeightBand classifyWeight(double kg) {
  if (kg >= 25 && kg <= 40) return WeightBand.lechonon;
  if (kg >= 80 && kg <= 100) return WeightBand.disposal;
  if (kg >= 101) return WeightBand.overweight;
  return WeightBand.none;
}

String bandLabel(WeightBand b) {
  switch (b) {
    case WeightBand.lechonon:
      return 'Lechonon (25–40 kg)';
    case WeightBand.disposal:
      return 'Disposal weight (80–100 kg)';
    case WeightBand.overweight:
      return 'Overweight (≥101 kg)';
    default:
      return '';
  }
}

double? _toDoubleSafe(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final cleaned = v.trim().replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned);
  }
  return null;
}

bool _enteredRange(double w, double min, double max) => w >= min && w <= max;

class WeightRecordsViewModel extends ChangeNotifier {
  final SupabaseClient supabase;
  final NotificationService notifications;
  int? currentLivestockId;

  WeightRecordsViewModel({
    required this.supabase,
    required this.notifications,
  });

  final List<WeightRecord> records = [];
  bool _loading = false;
  bool get loading => _loading;

  // ✅ Make sure this matches your actual table name
  static const String table = 'weight_record';
  static const bool inputIsDelta = true;

  // Toggle: notify on every entry inside a band (true) vs only when crossing in (false)
  static const bool notifyEveryTimeInBand = false;

  DateTime _toDateTime(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (v is DateTime) return v;
    if (v is String) return DateTime.parse(v);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<List<Map<String, dynamic>>> _allAsc(int livestockId) async {
    final rows = await supabase
        .from(table)
        .select()
        .eq('livestock_id', livestockId)
        .order('datetime', ascending: true);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  double _absWeight(dynamic v) => (_toDoubleSafe(v) ?? 0);

  Future<void> _shiftFollowing({
    required int livestockId,
    required DateTime afterDate, // strictly AFTER this datetime
    required double diff,
  }) async {
    if (diff == 0) return;

    final following = await supabase
        .from(table)
        .select()
        .eq('livestock_id', livestockId)
        .gt('datetime', afterDate.toIso8601String())
        .order('datetime', ascending: true);

    for (final row in (following as List)) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as int;
      final newAbs = _absWeight(map['weight']) + diff;
      await supabase.from(table).update({'weight': newAbs}).eq('id', id);
    }
  }

  Future<void> fetchRecords(int livestockId) async {
    currentLivestockId = livestockId;
    try {
      final data = await supabase
          .from(table)
          .select()
          .eq('livestock_id', livestockId)
          .order('datetime', ascending: false) as List;

      records
        ..clear()
        ..addAll(
          data.map((m) => WeightRecord.fromMap(m as Map<String, dynamic>)),
        );
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching weight records: $e');
    }
  }

  Future<void> addRecord(WeightRecord record) async {
    _loading = true;
    notifyListeners();
    try {
      final userId = supabase.auth.currentUser!.id;

      // 1) previous/latest absolute weight
      final prevRows = await supabase
          .from(table)
          .select()
          .eq('livestock_id', record.livestockId)
          .order('datetime', ascending: false)
          .limit(1) as List;

      final double? prevWeight = prevRows.isEmpty
          ? null
          : _toDoubleSafe((prevRows.first as Map)['weight']);

      // 2) compute the absolute weight we will store
      final double finalWeight = inputIsDelta
          ? (prevWeight ?? 0) + record.weight // treat input as gain
          : record.weight; // treat input as absolute

      debugPrint(
          '[WEIGHT] prev=$prevWeight input=${record.weight} final=$finalWeight (deltaMode=$inputIsDelta)');

      // 3) insert row (store the absolute weight)
      final inserted = await supabase
          .from(table)
          .insert({
            'livestock_id': record.livestockId,
            'weight': finalWeight,
            'datetime': record.datetime.toIso8601String(),
            'owner_id': userId, // remove if not in schema
          })
          .select()
          .single();

      // optimistic UI with absolute weight
      records.insert(
        0,
        WeightRecord(
          id: inserted['id'] as int?,
          livestockId: record.livestockId,
          datetime: record.datetime,
          weight: finalWeight,
        ),
      );
      notifyListeners();

      // 4) nice name
      final animal = await supabase
          .from('livestock')
          .select('name')
          .eq('id', inserted['livestock_id'])
          .maybeSingle();
      final name = (animal?['name'] as String?) ?? 'Livestock';

      // 5) crossing logic now compares prevWeight -> finalWeight
      bool shouldNotify = false;
      String label = '';

      if (prevWeight == null) {
        if (_enteredRange(finalWeight, 25, 40)) {
          label = 'Lechonon (25–40 kg)';
          shouldNotify = true;
        } else if (_enteredRange(finalWeight, 80, 100)) {
          label = 'Disposal weight (80–100 kg)';
          shouldNotify = true;
        } else if (finalWeight >= 101) {
          label = 'Overweight (≥101 kg)';
          shouldNotify = true;
        }
      } else {
        if (prevWeight < 25 && _enteredRange(finalWeight, 25, 40)) {
          label = 'Lechonon (25–40 kg)';
          shouldNotify = true;
        } else if (prevWeight < 80 && _enteredRange(finalWeight, 80, 100)) {
          label = 'Disposal weight (80–100 kg)';
          shouldNotify = true;
        } else if (prevWeight < 101 && finalWeight >= 101) {
          label = 'Overweight (≥101 kg)';
          shouldNotify = true;
        }
      }

      if (shouldNotify) {
        await notifications.create(
          recipientId: userId,
          title: 'Weight reminders',
          body: '$name reached $label • ${finalWeight.toStringAsFixed(1)} kg',
        );
      }
    } catch (e) {
      debugPrint('Error adding weight record & notifying: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecord(int id, int livestockId) async {
    try {
      final rows = await _allAsc(livestockId);
      final idx = rows.indexWhere((r) => r['id'] == id);
      if (idx == -1) {
        debugPrint('deleteRecord: row not found id=$id');
        return;
      }

      final target = rows[idx];
      final oldDate = _toDateTime(target['datetime']);
      final oldAbs = _absWeight(target['weight']);
      final prevAbs = idx == 0 ? 0.0 : _absWeight(rows[idx - 1]['weight']);

      // delta represented by this row
      final removedDelta = oldAbs - prevAbs;
      final diff = -removedDelta; // following rows should drop by this amount

      debugPrint(
          '[WEIGHT][DELETE] oldDate=$oldDate prevAbs=$prevAbs oldAbs=$oldAbs removedDelta=$removedDelta diff=$diff');

      // 1) Delete the row
      await supabase.from(table).delete().eq('id', id);

      // 2) Shift all following rows by diff (based on ORIGINAL position)
      await _shiftFollowing(
        livestockId: livestockId,
        afterDate: oldDate,
        diff: diff,
      );

      await fetchRecords(livestockId);
    } catch (e) {
      debugPrint('Error deleting weight record (cumulative): $e');
    }
  }

  Future<void> updateRecord(WeightRecord record) async {
    if (record.id == null) return;

    try {
      // 1) Load ascending to find original position and neighbors
      final rows = await _allAsc(record.livestockId);
      final idx = rows.indexWhere((r) => r['id'] == record.id);
      if (idx == -1) {
        debugPrint('updateRecord: row not found id=${record.id}');
        return;
      }

      final oldMap = rows[idx];
      final oldDate = _toDateTime(oldMap['datetime']);
      final prevAbs = idx == 0 ? 0.0 : _absWeight(rows[idx - 1]['weight']);
      final oldAbs = _absWeight(oldMap['weight']);

      // 2) Compute new absolute for this row (delta or absolute mode)
      final newAbs = inputIsDelta ? (prevAbs + record.weight) : record.weight;
      final diff = newAbs - oldAbs;

      debugPrint(
          '[WEIGHT][UPDATE] oldDate=$oldDate prevAbs=$prevAbs oldAbs=$oldAbs input=${record.weight} newAbs=$newAbs diff=$diff');

      // 3) Update the edited row (keep original datetime to avoid reordering)
      await supabase.from(table).update({
        'weight': newAbs,
        // 'datetime': record.datetime.toIso8601String(), // ← safer to NOT change datetime in cumulative mode
      }).eq('id', record.id!);

      // 4) Shift all following rows by diff (based on ORIGINAL position)
      await _shiftFollowing(
        livestockId: record.livestockId,
        afterDate: oldDate,
        diff: diff,
      );

      await fetchRecords(record.livestockId);
    } catch (e) {
      debugPrint('Error updating weight record (cumulative): $e');
    }
  }
}
