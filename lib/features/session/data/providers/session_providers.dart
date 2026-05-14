import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ownurtime/features/session/data/datasources/in_memory_session_datasource.dart';
import 'package:ownurtime/features/session/data/datasources/session_local_datasource.dart';
import 'package:ownurtime/features/session/data/repositories/session_repository_impl.dart';
import 'package:ownurtime/features/session/domain/repositories/session_repository.dart';

final sessionLocalDataSourceProvider = Provider<SessionLocalDataSource>(
  (Ref ref) => InMemorySessionDataSource(),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (Ref ref) => SessionRepositoryImpl(ref.watch(sessionLocalDataSourceProvider)),
);
