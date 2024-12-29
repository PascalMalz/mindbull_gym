// services/log_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LogService {
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/logs.txt');
  }

  Future<void> writeLog(String log) async {
    final file = await _localFile;
    await file.writeAsString('$log\n', mode: FileMode.append);
  }

  Future<String> readLogs() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }
}
