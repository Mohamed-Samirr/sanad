import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/journal_model.dart';

abstract class JournalLocalDataSource {
  Future<List<JournalModel>> getEntries();
  Future<void> saveEntry(JournalModel entry);
  Future<void> deleteEntry(String id);
  Stream<void> watchChanges();
}

class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  Box<JournalModel> get _box => Hive.box<JournalModel>(HiveBoxes.journal);

  @override
  Future<List<JournalModel>> getEntries() async {
    try {
      final entries = _box.values.toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveEntry(JournalModel entry) async {
    try {
      await _box.put(entry.id, entry);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Stream<void> watchChanges() {
    return _box.watch().map((_) {});
  }
}
