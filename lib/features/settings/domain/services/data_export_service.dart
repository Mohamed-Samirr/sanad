import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../../core/errors/failures.dart';

class DataExportService {
  Future<Either<Failure, void>> exportData() async {
    try {

      final boxes = [
        HiveBoxes.habits,
        HiveBoxes.habitLogs,
        HiveBoxes.settings,
        HiveBoxes.toolbox,
        HiveBoxes.journal,
        HiveBoxes.behaviors,
        HiveBoxes.urgeEntries,
        HiveBoxes.triggers,
        HiveBoxes.supportContacts,
      ];

      for (final boxName in boxes) {
        if (!Hive.isBoxOpen(boxName)) {
          await Hive.openBox(boxName);
        }
      }

      // Approach 2: Export actual .hive files
      final appDir = await getApplicationDocumentsDirectory();
      final hiveFiles = <XFile>[];
      
      for (final boxName in boxes) {
        final file = File('${appDir.path}/$boxName.hive');
        if (await file.exists()) {
          hiveFiles.add(XFile(file.path));
        }
      }

      if (hiveFiles.isEmpty) {
        return const Left(CacheFailure('No data found to export.'));
      }

      await SharePlus.instance.share(ShareParams(
        files: hiveFiles, 
        text: 'Sanad Backup Files'
      ));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Export failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> importData() async {
    try {
      final result = await FilePicker.pickFiles(allowMultiple: true);
      if (result == null || result.paths.isEmpty) {
        return const Right(null); // User canceled
      }

      final appDir = await getApplicationDocumentsDirectory();
      
      // Close all boxes first to safely replace files
      final boxes = [
        HiveBoxes.habits,
        HiveBoxes.habitLogs,
        HiveBoxes.settings,
        HiveBoxes.toolbox,
        HiveBoxes.journal,
        HiveBoxes.behaviors,
        HiveBoxes.urgeEntries,
        HiveBoxes.triggers,
        HiveBoxes.supportContacts,
      ];

      for (final boxName in boxes) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }
      }

      // Replace files
      for (final path in result.paths) {
        if (path != null && path.endsWith('.hive')) {
          final file = File(path);
          final fileName = path.split(Platform.pathSeparator).last;
          await file.copy('${appDir.path}/$fileName');
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Import failed: ${e.toString()}'));
    }
  }
}
