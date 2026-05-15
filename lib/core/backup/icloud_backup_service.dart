import 'dart:convert';
import 'dart:io';

import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';

const String _containerId = 'iCloud.com.ownurtime.app';

abstract interface class ICloudBackupService {
  /// iCloud에 tasks + sessions JSON 저장. 실패해도 예외 전파 안 함.
  Future<void> backup({
    required String userId,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> sessions,
  });

  /// iCloud에서 복원. 파일 없거나 iCloud 불가 시 null 반환.
  Future<
    ({List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> sessions})?
  >
  restore({required String userId});
}

class ICloudBackupServiceImpl implements ICloudBackupService {
  @override
  Future<void> backup({
    required String userId,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      final tmpDir = await getTemporaryDirectory();

      final tasksFile = File('${tmpDir.path}/own_ur_time_tasks_$userId.json');
      await tasksFile.writeAsString(jsonEncode(tasks));
      await ICloudStorage.upload(
        containerId: _containerId,
        filePath: tasksFile.path,
        destinationRelativePath: 'own_ur_time_tasks_$userId.json',
        onProgress: null,
      );

      final sessionsFile = File(
        '${tmpDir.path}/own_ur_time_sessions_$userId.json',
      );
      await sessionsFile.writeAsString(jsonEncode(sessions));
      await ICloudStorage.upload(
        containerId: _containerId,
        filePath: sessionsFile.path,
        destinationRelativePath: 'own_ur_time_sessions_$userId.json',
        onProgress: null,
      );
    } on Exception {
      // iCloud 불가 시 silently skip
    }
  }

  @override
  Future<
    ({List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> sessions})?
  >
  restore({required String userId}) async {
    try {
      final tmpDir = await getTemporaryDirectory();

      final tasksPath = '${tmpDir.path}/own_ur_time_tasks_$userId.json';
      final sessionsPath = '${tmpDir.path}/own_ur_time_sessions_$userId.json';

      await ICloudStorage.download(
        containerId: _containerId,
        relativePath: 'own_ur_time_tasks_$userId.json',
        destinationFilePath: tasksPath,
        onProgress: null,
      );
      await ICloudStorage.download(
        containerId: _containerId,
        relativePath: 'own_ur_time_sessions_$userId.json',
        destinationFilePath: sessionsPath,
        onProgress: null,
      );

      final tasksJson = await File(tasksPath).readAsString();
      final sessionsJson = await File(sessionsPath).readAsString();

      final taskList = jsonDecode(tasksJson) as List<Object?>;
      final sessionList = jsonDecode(sessionsJson) as List<Object?>;

      final tasks = taskList
          .map(
            (item) => Map<String, dynamic>.from(item as Map<Object?, Object?>),
          )
          .toList();
      final sessions = sessionList
          .map(
            (item) => Map<String, dynamic>.from(item as Map<Object?, Object?>),
          )
          .toList();

      return (tasks: tasks, sessions: sessions);
    } on Exception {
      return null;
    }
  }
}
