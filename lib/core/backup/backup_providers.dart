import 'package:ownurtime/core/backup/icloud_backup_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_providers.g.dart';

@riverpod
ICloudBackupService iCloudBackupService(Ref ref) => ICloudBackupServiceImpl();
