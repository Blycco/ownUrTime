# Task 01: Supabase 실 연결 — Phase 2

> **선제 조건**: Task 00 완료
> **Claude Code 담당**: 인터페이스 설계, userId propagation 아키텍처, 마이그레이션 SQL 설계, Realtime stream 설계
> **Codex 담당**: 모든 datasource 구현, repository 구현, provider 수정, 테스트 작성
> **PRD ref**: dart-patterns.md, folder-structure.md
> **읽기**: `.claude/context/dart-patterns.md`, `.claude/context/folder-structure.md`
> **Block**: 이 태스크 완료 전 데이터 영속성 0% — 앱 재시작 시 전체 데이터 소실

---

## 1. 설계 명세 (Claude Code)

### 1-1. 변경되는 Repository 인터페이스

**TaskRepository** — `watchTasks` 신규 추가:

```dart
abstract interface class TaskRepository {
  Future<List<Task>> getTasks(String userId);
  Future<Task> createTask(String userId, String title);
  Future<void> updateTask(Task task);
  Future<({List<String> steps, int remainingToday})> decomposeTask(
    String taskId, String title);

  // 신규: Supabase Realtime stream
  Stream<List<Task>> watchTasks(String userId);
}
```

**SessionRepository** — 신규 인터페이스:

```dart
abstract interface class SessionRepository {
  Future<Session> createSession({
    required String userId,
    required String taskId,
    required Duration targetDuration,
  });
  Future<void> completeSession(String sessionId, DateTime completedAt);
  Future<void> abandonSession(String sessionId);
  Future<List<Session>> getSessionsByUser(String userId);
  Stream<List<Session>> watchSessionsByUser(String userId);
}
```

**DistractionRepository** — 신규 인터페이스 (Phase 1에 없었음):

```dart
abstract interface class DistractionRepository {
  Future<Distraction> saveDistraction({
    required String sessionId,
    required DistractionType type,
    required DateTime occurredAt,
  });
  Future<void> markReturned(String distractionId, DateTime returnedAt);
  Future<List<Distraction>> getBySession(String sessionId);
  Future<int> getRecoveryCount(String userId); // comeback badge용
}
```

**MoodCheckRepository** — `saveMoodCheck` 신규:

```dart
abstract interface class MoodCheckRepository {
  Future<void> saveMoodCheck({
    required String userId,
    required int level,
    required DateTime checkedAt,
  });
  Future<List<MoodCheck>> getTodayMoodChecks(String userId);
}
```

### 1-2. userId propagation 아키텍처

**문제**: Phase 1에서 `_guestUserId = 'guest'` 하드코딩 → Phase 2에서 authProvider 연동 필요.

**설계 규칙**:
- 모든 Repository Provider는 `authProvider`를 watch
- 게스트 상태: userId = `'guest'` (로컬 저장에서 읽기 가능)
- 인증 상태: userId = `auth.uid()`
- authProvider가 변경되면 (로그인/로그아웃) 모든 Repository Provider 자동 재빌드

**Provider 연결 패턴** (각 feature/data/providers 파일에 적용):

```dart
// lib/features/task/data/providers/task_providers.dart
@riverpod
TaskRepository taskRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  // 인증 상태 변경 시 repository 재생성
  ref.watch(authProvider);
  final userId = ref.read(authProvider).currentUserId; // getter 추가 필요
  return TaskRepositoryImpl(
    SupabaseTaskDataSource(client),
    userId: userId,
  );
}
```

**AuthState에 currentUserId getter 추가**:

```dart
extension AuthStateX on AuthState {
  String get currentUserId => when(
    guest: () => 'guest',
    authenticated: (user) => user.id,
  );
}
```

### 1-3. Supabase 스키마 추가 마이그레이션

`supabase/migrations/20260518000001_add_profile_trigger.sql`:

```sql
-- user_profiles.updated_at 컬럼 추가
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 신규 사용자 프로필 자동 생성 트리거
CREATE OR REPLACE FUNCTION create_user_profile_on_signup()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile_on_signup();
```

`supabase/migrations/20260518000002_add_distractions_interface.sql`:

```sql
-- distractions 테이블에 RLS 추가 (Phase 1에서 누락됨)
ALTER TABLE distractions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own distractions"
  ON distractions FOR ALL
  USING (
    session_id IN (
      SELECT id FROM sessions WHERE user_id = auth.uid()
    )
  );

-- mood_checks RLS UPDATE 추가 (Phase 1 QA-05)
CREATE POLICY "Users can update own mood_checks"
  ON mood_checks FOR UPDATE
  USING (user_id = auth.uid());
```

### 1-4. MigrateLocalDataUseCase 원자적 처리

**기존 문제**: 비원자적 → 중간 실패 시 데이터 불일치.

**새 설계**: Supabase RPC로 일괄 처리:

```sql
-- supabase/migrations/20260518000003_migrate_local_data_fn.sql
CREATE OR REPLACE FUNCTION migrate_local_data(
  p_user_id UUID,
  p_tasks JSONB,
  p_sessions JSONB
) RETURNS void AS $$
BEGIN
  -- tasks 일괄 insert (conflict = skip)
  INSERT INTO tasks (id, user_id, title, decomposed_steps, status, created_at)
  SELECT
    (t->>'id')::UUID,
    p_user_id,
    t->>'title',
    (t->>'decomposed_steps')::JSONB,
    COALESCE(t->>'status', 'pending'),
    (t->>'created_at')::TIMESTAMPTZ
  FROM jsonb_array_elements(p_tasks) t
  ON CONFLICT (id) DO NOTHING;

  -- sessions 일괄 insert (conflict = skip)
  INSERT INTO sessions (id, user_id, task_id, target_duration_minutes, status, started_at, completed_at)
  SELECT
    (s->>'id')::UUID,
    p_user_id,
    (s->>'task_id')::UUID,
    (s->>'target_duration_minutes')::INTEGER,
    COALESCE(s->>'status', 'completed'),
    (s->>'started_at')::TIMESTAMPTZ,
    (s->>'completed_at')::TIMESTAMPTZ
  FROM jsonb_array_elements(p_sessions) s
  ON CONFLICT (id) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

Dart에서 호출:
```dart
await supabase.rpc('migrate_local_data', params: {
  'p_user_id': userId,
  'p_tasks': tasksJson,
  'p_sessions': sessionsJson,
});
```

### 1-5. 에러 케이스

| 상황 | 에러 | 처리 |
|------|------|------|
| Supabase 연결 없음 | `PostgrestException` | 로컬 캐시 반환 (있으면) 또는 empty state |
| RLS 정책 위반 | `PostgrestException(code: '42501')` | 로그아웃 처리 |
| 마이그레이션 중 네트워크 끊김 | RPC timeout | 재시도 가능 (ON CONFLICT DO NOTHING으로 멱등) |
| 게스트 userId로 Supabase 쿼리 | `'guest'` userId → RLS 거부 | 게스트 상태면 InMemory datasource 유지 |

**게스트 vs 인증 datasource 전환 패턴**:

```dart
// TaskRepositoryImpl — 게스트일 때 InMemory, 인증 시 Supabase
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _local;   // InMemory (게스트용)
  final TaskRemoteDataSource _remote; // Supabase (인증 시)
  final String _userId;

  bool get _isGuest => _userId == 'guest';

  @override
  Future<List<Task>> getTasks(String userId) async {
    if (_isGuest) return _local.getTasks(userId);
    final models = await _remote.getTasks(userId);
    return models.map((m) => m.toEntity()).toList();
  }
}
```

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task01-supabase-connect.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 01 — Supabase 실 연결. 모든 InMemory datasource를 Supabase로 교체.
참고: lib/features/task/data/datasources/task_remote_datasource.dart (현재 UnimplementedError stub)

## 구현 원칙
- 게스트(userId='guest'): InMemory datasource 유지
- 인증(userId=실제 UUID): Supabase datasource 사용
- Repository가 두 datasource 중 선택 (userId 기반)
- Realtime stream은 Supabase channel 구독 패턴 사용

## 항목 1: AuthState extension 추가
파일: lib/features/auth/presentation/providers/auth_provider.dart
기존 파일 하단에 추가:
```dart
extension AuthStateX on AuthState {
  String get currentUserId => when(
    guest: () => 'guest',
    authenticated: (user) => user.id,
  );
  bool get isAuthenticated => this is AuthStateAuthenticated;
}
```

## 항목 2: SupabaseTaskDataSource 전체 구현
파일: lib/features/task/data/datasources/task_remote_datasource.dart
```dart
class SupabaseTaskDataSource implements TaskRemoteDataSource {
  const SupabaseTaskDataSource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<TaskModel> createTask(String userId, String title) async {
    final response = await _client
        .from('tasks')
        .insert({'user_id': userId, 'title': title, 'status': 'pending'})
        .select()
        .single();
    return TaskModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _client
        .from('tasks')
        .update(task.toJson())
        .eq('id', task.id);
  }

  @override
  Stream<List<TaskModel>> watchTasks(String userId) {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((list) => list.map(TaskModel.fromJson).toList());
  }
}
```

## 항목 3: TaskRepositoryImpl 게스트/인증 분기 추가
파일: lib/features/task/data/repositories/task_repository_impl.dart
- 생성자: local(InMemory) + remote(Supabase) + userId 주입
- 모든 메서드: userId == 'guest' → local, 그 외 → remote
- watchTasks: 게스트면 Stream.value([]) 또는 local stream

## 항목 4: task providers userId 연동
파일: lib/features/task/data/providers/task_providers.dart (없으면 신규)
- taskRepositoryProvider: ref.watch(authProvider).currentUserId로 userId 주입
- authProvider 변경 시 재빌드됨

## 항목 5: SupabaseSessionDataSource 전체 구현
파일: lib/features/session/data/datasources/session_remote_datasource.dart (신규)
- createSession: insert → select().single()
- completeSession: update({status: 'completed', completed_at: ...})
- abandonSession: update({status: 'abandoned'})
- getSessionsByUser: select().eq('user_id').order('started_at')
- watchSessionsByUser: stream(primaryKey: ['id']).eq('user_id')

## 항목 6: SessionRepositoryImpl 게스트/인증 분기
파일: lib/features/session/data/repositories/session_repository_impl.dart
- 동일한 게스트/인증 분기 패턴 적용

## 항목 7: DistractionDataSource 인터페이스 + Supabase 구현
<!-- [FIX] datasource 인터페이스는 data 레이어에 위치 (RULE 04: domain에 datasource 계약 없음) -->
파일: lib/features/recovery/data/datasources/distraction_datasource.dart (인터페이스)
파일: lib/features/recovery/data/datasources/distraction_remote_datasource.dart (Supabase)
- saveDistraction: insert → single
- markReturned: update({returned_at: returnedAt.toIso8601String()})
- getBySession: select().eq('session_id')
- getRecoveryCount: select('id').not('returned_at', 'is', null) COUNT

## 항목 8: SupabaseMoodDataSource 구현
파일: lib/features/mood/data/datasources/mood_remote_datasource.dart
기존 InMemoryMoodDataSource를 SupabaseMoodDataSource로 교체:
- saveMoodCheck: insert
- getTodayMoodChecks: select().eq('user_id').gte('checked_at', today_midnight)

## 항목 9: MigrateLocalDataUseCase 교체
파일: lib/features/auth/domain/usecases/migrate_local_data_usecase.dart
<!-- [FIX] UseCase는 Repository 인터페이스만 호출 — Supabase 직접 호출은 RULE 03 위반 -->
- MigrationRepository (인터페이스: domain/) + MigrationRepositoryImpl (data/)를 신규 생성
- UseCase: _migrationRepository.migrateLocalData(userId, tasks, sessions)
- MigrationRepositoryImpl 내부에서 Supabase RPC 호출:
  supabase.rpc('migrate_local_data', params: {p_user_id, p_tasks: jsonList, p_sessions: jsonList})
- 성공 후 InMemory datasource clear() (datasource는 repository impl이 주입받아 호출)

## 항목 10: SQL 마이그레이션 파일 3개 작성
- supabase/migrations/20260518000001_add_profile_trigger.sql (설계 명세 그대로)
- supabase/migrations/20260518000002_add_distractions_interface.sql (설계 명세 그대로)
- supabase/migrations/20260518000003_migrate_local_data_fn.sql (설계 명세 그대로)

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과 (신규 fake 테스트 포함)
- supabase db reset: 전체 마이그레이션 통과
```

### 2-2. 구현 파일 목록

| 파일 | 담당 |
|------|------|
| `lib/features/auth/presentation/providers/auth_provider.dart` | Codex (extension 추가) |
| `lib/features/task/data/datasources/task_remote_datasource.dart` | Codex (UnimplementedError → 실 구현) |
| `lib/features/task/data/repositories/task_repository_impl.dart` | Codex (게스트/인증 분기) |
| `lib/features/task/data/providers/task_providers.dart` | Codex (신규 또는 수정) |
| `lib/features/session/data/datasources/session_remote_datasource.dart` | Codex (신규) |
| `lib/features/session/data/repositories/session_repository_impl.dart` | Codex |
| `lib/features/session/data/providers/session_providers.dart` | Codex (신규) |
| `lib/features/recovery/domain/datasources/distraction_datasource.dart` | Codex (신규 인터페이스) |
| `lib/features/recovery/data/datasources/distraction_remote_datasource.dart` | Codex (신규) |
| `lib/features/recovery/data/repositories/distraction_repository_impl.dart` | Codex (신규) |
| `lib/features/mood/data/datasources/mood_remote_datasource.dart` | Codex (교체) |
| `lib/features/auth/domain/usecases/migrate_local_data_usecase.dart` | Codex (RPC로 교체) |
| `supabase/migrations/20260518000001_add_profile_trigger.sql` | Codex |
| `supabase/migrations/20260518000002_add_distractions_interface.sql` | Codex |
| `supabase/migrations/20260518000003_migrate_local_data_fn.sql` | Codex |

---

## 3. 테스트 명세

### `test/features/task/data/task_remote_datasource_test.dart`

```
TC-01: getTasks — 정상 반환
  setup: FakeSupabaseClient.from('tasks').select() → [{id: 'a', user_id: 'u1', ...}]
  기대: List<TaskModel> 길이 1, id == 'a'

TC-02: createTask — insert 후 반환
  setup: FakeSupabaseClient.insert() → {id: 'new-id', title: 'test', ...}
  기대: TaskModel.id == 'new-id', title == 'test'

TC-03: watchTasks — stream 첫 값
  setup: FakeSupabaseClient.stream() → [task1]
  기대: Stream 첫 emit == [TaskModel(id: task1.id)]
```

### `test/features/session/data/session_repository_impl_test.dart`

```
TC-04: 게스트 userId → InMemory 호출
  setup: userId = 'guest'
  기대: _local.createSession 호출됨, _remote.createSession 미호출

TC-05: 인증 userId → Supabase 호출
  setup: userId = 'real-uuid'
  기대: _remote.createSession 호출됨, _local 미호출
```

### `test/features/auth/domain/migrate_local_data_usecase_test.dart`

```
TC-06: migrate 성공 → InMemory clear 호출됨
  setup: FakeSupabaseClient.rpc('migrate_local_data') → completes
  기대: FakeInMemoryDataSource.clear() 호출됨

TC-07: migrate 실패 → InMemory clear 미호출 (롤백)
  setup: FakeSupabaseClient.rpc() → throws PostgrestException
  기대: FakeInMemoryDataSource.clear() 미호출됨, exception rethrow
```

---

## 4. l10n 추가 (Codex)

없음 (이 태스크는 데이터 레이어 — UI 문자열 없음)

---

## 5. Done When

- [ ] 앱 재시작 후 tasks 목록 유지됨 (실기기 또는 Supabase 대시보드에서 데이터 확인)
- [ ] 게스트 → Apple Sign In → 로컬 task 1개 Supabase로 마이그레이션됨 확인
- [ ] `supabase db reset` 5개 마이그레이션 통과
- [ ] `supabase functions serve delete-account` 로컬 테스트 통과
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` 전체 통과 (TC-01 ~ TC-07 포함)
- [ ] Supabase Dashboard: tasks 테이블에 실제 데이터 insert 확인
