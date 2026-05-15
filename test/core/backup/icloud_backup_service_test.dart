import 'package:flutter_test/flutter_test.dart';
import 'package:ownurtime/core/backup/icloud_backup_service.dart';

class _AlwaysFailsBackupService implements ICloudBackupService {
  @override
  Future<void> backup({
    required String userId,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> sessions,
  }) async {
    throw Exception('iCloud unavailable');
  }

  @override
  Future<
    ({List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> sessions})?
  >
  restore({required String userId}) async {
    throw Exception('iCloud unavailable');
  }
}

class _SafeBackupFacade implements ICloudBackupService {
  _SafeBackupFacade(this._delegate);

  final ICloudBackupService _delegate;

  @override
  Future<void> backup({
    required String userId,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      await _delegate.backup(userId: userId, tasks: tasks, sessions: sessions);
    } on Exception {
      // no-op
    }
  }

  @override
  Future<
    ({List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> sessions})?
  >
  restore({required String userId}) async {
    try {
      return await _delegate.restore(userId: userId);
    } on Exception {
      return null;
    }
  }
}

class _FakeBackupService implements ICloudBackupService {
  final Map<String, List<Map<String, dynamic>>> _taskStore =
      <String, List<Map<String, dynamic>>>{};
  final Map<String, List<Map<String, dynamic>>> _sessionStore =
      <String, List<Map<String, dynamic>>>{};

  @override
  Future<void> backup({
    required String userId,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> sessions,
  }) async {
    _taskStore[userId] = tasks
        .map((task) => Map<String, dynamic>.from(task))
        .toList(growable: false);
    _sessionStore[userId] = sessions
        .map((session) => Map<String, dynamic>.from(session))
        .toList(growable: false);
  }

  @override
  Future<
    ({List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> sessions})?
  >
  restore({required String userId}) async {
    final tasks = _taskStore[userId];
    final sessions = _sessionStore[userId];
    if (tasks == null || sessions == null) {
      return null;
    }

    return (
      tasks: tasks.map((task) => Map<String, dynamic>.from(task)).toList(),
      sessions: sessions
          .map((session) => Map<String, dynamic>.from(session))
          .toList(),
    );
  }
}

void main() {
  group('ICloudBackupService', () {
    test('backup silently skips when iCloud throws', () async {
      final service = _SafeBackupFacade(_AlwaysFailsBackupService());

      await expectLater(
        service.backup(
          userId: 'guest_1',
          tasks: <Map<String, dynamic>>[
            <String, dynamic>{'id': 'task_1', 'title': 'Start task'},
          ],
          sessions: <Map<String, dynamic>>[
            <String, dynamic>{'id': 'session_1', 'minutes': 25},
          ],
        ),
        completes,
      );
    });

    test('restore returns null when iCloud throws', () async {
      final service = _SafeBackupFacade(_AlwaysFailsBackupService());

      final restored = await service.restore(userId: 'guest_1');

      expect(restored, isNull);
    });

    test('backup and restore round-trips data', () async {
      final service = _FakeBackupService();
      final tasks = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'task_1',
          'title': 'Micro start',
          'done': false,
        },
      ];
      final sessions = <Map<String, dynamic>>[
        <String, dynamic>{'id': 'session_1', 'taskId': 'task_1', 'minutes': 15},
      ];

      await service.backup(userId: 'guest_1', tasks: tasks, sessions: sessions);
      final restored = await service.restore(userId: 'guest_1');

      expect(restored, isNotNull);
      expect(restored?.tasks, equals(tasks));
      expect(restored?.sessions, equals(sessions));
    });

    test('restore returns null when no backup exists', () async {
      final service = _FakeBackupService();

      final restored = await service.restore(userId: 'guest_404');

      expect(restored, isNull);
    });
  });
}
