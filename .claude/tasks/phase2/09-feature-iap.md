# Task 09: 인앱 결제 인프라 (RevenueCat) — Phase 2

> **선제 조건**: Task 05 완료 (Badge lock 화면 연결), Task 06 완료 (Apple Sign In 완성)
> **Claude Code 담당**: 구독 아키텍처, 게이팅 포인트 정의, SubscriptionRepository 인터페이스, Paywall 화면 설계
> **Codex 담당**: 모든 코드 작성 (RevenueCat 연동, SubscriptionNotifier, Paywall UI, 게이팅 위젯, 테스트 전부)
> **PRD ref**: business.md (Freemium, ₩4,900/월, ₩33,000/연)
> **핵심**: IAP 인프라 + 레이어 2/3 보상 게이팅 연결 (수익화 포인트 완성)

---

## 1. 설계 명세 (Claude Code)

### 1-1. SubscriptionStatus 엔티티

```dart
// lib/features/subscription/domain/entities/subscription_status.dart
@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    required PremiumTier tier,
    DateTime? expiresAt,         // null이면 활성 (갱신형 구독)
    String? productId,           // 'com.ownurtime.app.pro.monthly' 등
    @Default(false) bool isInTrial,
  }) = _SubscriptionStatus;

  const SubscriptionStatus._();

  bool get isPremium => tier != PremiumTier.free;
}

enum PremiumTier { free, monthly, annual }
```

### 1-2. SubscriptionRepository 인터페이스

```dart
// lib/features/subscription/domain/repositories/subscription_repository.dart
abstract interface class SubscriptionRepository {
  /// 현재 구독 상태 확인 (RevenueCat 캐시 우선, 네트워크 폴백).
  Future<SubscriptionStatus> getStatus();

  /// 상태 변경 실시간 스트림.
  Stream<SubscriptionStatus> watchStatus();

  /// 구독 구매.
  /// [productId]: 'com.ownurtime.app.pro.monthly' or 'com.ownurtime.app.pro.annual'
  /// Throws [PurchaseCanceledException] if user cancels.
  /// Throws [PurchaseFailedException] on failure.
  Future<SubscriptionStatus> purchase(String productId);

  /// 이전 구매 복원.
  Future<SubscriptionStatus> restore();

  /// 구독 상품 목록 (가격 포함).
  Future<List<SubscriptionProduct>> getProducts();
}

@freezed
class SubscriptionProduct with _$SubscriptionProduct {
  const factory SubscriptionProduct({
    required String productId,
    required String title,       // "OwnUrTime Pro 월간"
    required String priceString, // "₩4,900" (로케일 포맷)
    required String period,      // 'monthly' or 'annual'
    String? introductoryPrice,   // 무료 체험 기간 표시용
  }) = _SubscriptionProduct;
}
```

**예외 클래스**:

```dart
// lib/features/subscription/domain/exceptions/subscription_exceptions.dart
class PurchaseCanceledException implements Exception {
  const PurchaseCanceledException();
}

class PurchaseFailedException implements Exception {
  const PurchaseFailedException(this.message);
  final String message;
}
```

**UseCases**:

```dart
// lib/features/subscription/domain/usecases/get_subscription_status_usecase.dart
class GetSubscriptionStatusUseCase {
  const GetSubscriptionStatusUseCase(this._repository);
  final SubscriptionRepository _repository;
  Future<SubscriptionStatus> call() => _repository.getStatus();
}

// lib/features/subscription/domain/usecases/purchase_subscription_usecase.dart
class PurchaseSubscriptionUseCase {
  const PurchaseSubscriptionUseCase(this._repository);
  final SubscriptionRepository _repository;
  Future<SubscriptionStatus> call(String productId) =>
      _repository.purchase(productId);
}

// lib/features/subscription/domain/usecases/restore_purchases_usecase.dart
class RestorePurchasesUseCase {
  const RestorePurchasesUseCase(this._repository);
  final SubscriptionRepository _repository;
  Future<SubscriptionStatus> call() => _repository.restore();
}
```

### 1-3. SubscriptionNotifier 상태

```dart
@freezed
sealed class SubscriptionUiState with _$SubscriptionUiState {
  const factory SubscriptionUiState.loading() = _Loading;
  const factory SubscriptionUiState.loaded({
    required SubscriptionStatus status,
    required List<SubscriptionProduct> products,
  }) = _Loaded;
  const factory SubscriptionUiState.purchasing() = _Purchasing;
  const factory SubscriptionUiState.error(String message) = _Error;
}
```

**동작**:
```
build() →
  getStatus() + getProducts() 병렬 → loaded
  
purchase(productId) →
  state = purchasing()
  purchaseSubscriptionUseCase(productId)
    성공 → loaded(status: premium)
    PurchaseCanceledException → loaded(기존 상태 유지, 에러 없음)
    PurchaseFailedException → error(message) → 3초 후 loaded

restore() →
  restorePurchasesUseCase()
    성공 → loaded(updated status)
    복원할 것 없음 → SnackBar "구독 내역 없음"
```

### 1-4. 전역 isPremium 접근 패턴

모든 기능에서 `isPremiumProvider`로 접근:

```dart
// lib/features/subscription/presentation/providers/subscription_provider.dart

/// 구독 여부 빠른 접근 (gate 위젯에서 사용).
@riverpod
bool isPremium(Ref ref) {
  final state = ref.watch(subscriptionNotifierProvider);
  return state.whenOrNull(
    loaded: (status, _) => status.isPremium,
  ) ?? false;
}
```

### 1-5. 유료 게이팅 포인트

| 기능 | 조건 | 게이팅 위치 |
|------|------|-----------|
| 레이어 3 뱃지 | isPremium | `BadgeCollectionScreen` PremiumLockCard |
| AI 분해 한도 초과 (11회+) | isPremium | `TaskStartScreen` 한도 초과 메시지 |
| 주간 상세 리포트 | isPremium | `StatsScreen` 잠금 overlay |

### 1-6. PremiumGateWidget 설계

```dart
// lib/features/subscription/presentation/widgets/premium_gate_widget.dart

/// 유료 기능을 감싸는 게이팅 위젯.
/// isPremium=true → child 표시
/// isPremium=false → lock overlay 표시
class PremiumGateWidget extends ConsumerWidget {
  const PremiumGateWidget({
    super.key,
    required this.feature,   // 기능명 (l10n key)
    required this.child,
  });

  final String feature;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) return child;
    return _LockOverlay(feature: feature);
  }
}

class _LockOverlay extends StatelessWidget {
  // 잠금 아이콘 + 기능명 + "OwnUrTime Pro" 버튼
  // 버튼 탭 → GoRouter.push('/paywall')
}
```

### 1-7. Paywall 화면 설계

```
Scaffold(backgroundColor: dark)
├── AppBar: "OwnUrTime Pro" + X 닫기 버튼
├── 기능 비교 리스트 (Free vs Pro)
│   ├── ✓ 핵심 3기능 (착수/유지/복귀) — Free
│   ├── ✓ AI 할일 분해 10회/일 — Free
│   ├── 🔒 AI 할일 분해 무제한 — Pro
│   ├── ✓ 레이어 2 뱃지 (동기부여 기본) — Free  <!-- [FIX] Task 05: 레이어2는 public -->
│   ├── 🔒 레이어 3 뱃지 (전문가 달성) — Pro    <!-- 레이어3만 Pro 게이팅 -->
│   ├── 🔒 Apple 캘린더 연동 — Pro             <!-- [PRD FIX] business.md: Calendar = Paid -->
│   ├── 🔒 주간 상세 리포트 — Pro
│   └── 🔒 개인화 AI 인사이트 — Pro (Phase 3)
├── 구독 플랜 선택 (2개 카드)
│   ├── 월간: ₩4,900/월
│   └── 연간: ₩33,000/연 (₩2,750/월 — 44% 절약) [기본 선택]
├── ElevatedButton: "시작하기" → purchase(selectedProductId)
├── TextButton: "구매 복원"
└── TextButton: "취소" (닫기)
```

### 1-8. RevenueCat 설정 설계

**상품 ID**:
- 월간: `com.ownurtime.app.pro.monthly`
- 연간: `com.ownurtime.app.pro.annual`

**RevenueCat Entitlement ID**: `premium`

**초기화 위치**: `main.dart`에서 앱 시작 시
```dart
await Purchases.configure(PurchasesConfiguration(revenueCatApiKey)
  ..appUserID = null // RevenueCat이 자동 생성
);
```

로그인 후 RevenueCat userId 연결:
```dart
// [HIGH-9 FIX] logIn 실패 시 보상 트랜잭션 — Pro 상태 보장 필요
try {
  await Purchases.logIn(user.id);
} catch (_) {
  // logIn 실패: SharedPreferences에 'pending_rc_login_user_id' 저장
  // 다음 앱 포어그라운드 진입 시 재시도 (AppLifecycleState.resumed)
  // Pro 상태는 RC logIn 성공 전까지 보수적으로 Free로 유지
}
```

### 1-8-1. 서버 사이드 엔타이틀먼트 검증 (CRITICAL-2)
<!-- [CRITICAL FIX] 클라이언트 단독 Pro 판단은 스푸핑 가능 — 서버 권위 모델 필요 -->

**설계**:
- `user_profiles` 테이블에 `is_premium BOOLEAN DEFAULT FALSE` 컬럼 추가
- RevenueCat Webhook (Supabase Edge Function `revenuecat-webhook`) 연동:
  - 이벤트: `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `EXPIRATION`
  - Webhook 수신 → `user_profiles.is_premium = true/false` 업데이트

**Supabase Edge Function** `supabase/functions/revenuecat-webhook/index.ts` (설계):
```typescript
// RevenueCat Authorization header 검증 (RC_WEBHOOK_SECRET)
// event.type 별 is_premium 갱신:
//   INITIAL_PURCHASE / RENEWAL → true
//   CANCELLATION / EXPIRATION → false (grace period 고려 시 즉시 false 보류 가능)
```

**민감 기능 게이팅 원칙** (Phase 2에서 적용):
- UI 레이어: `isPremiumProvider` (RevenueCat 클라이언트) → 빠른 UX 반응
- 서버 레이어: Supabase RPC/Edge에서 `user_profiles.is_premium` 체크 (Phase 3 AI 기능 필수)
- Phase 2 범위: 클라이언트 게이팅 + webhook 스펙 준비 (실 서버 체크는 Phase 3 AI 도입 시)

**마이그레이션**: `supabase/migrations/20260518000030_add_is_premium.sql`
```sql
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS is_premium BOOLEAN NOT NULL DEFAULT FALSE;
```

### 1-9. 에러 케이스

| 상황 | 처리 |
|------|------|
| 구매 취소 | 에러 없이 이전 상태 유지 |
| 네트워크 없음 | `PurchaseFailedException('network_error')` → SnackBar |
| 중복 구매 | RevenueCat이 처리 (기존 구독 갱신) |
| 복원 없음 | SnackBar "구독 내역이 없어요" |
| Sandbox 테스트 | RevenueCat 대시보드에서 sandbox 모드 확인 |
| RC logIn 실패 | pending_rc_login 저장 → 재시도, Pro는 Free로 유지 |

---

## 2. Codex 구현 항목

### 2-1. Codex 프롬프트

`.claude/codex-prompts/task09-iap.md`:

```
Project: OwnUrTime Flutter
Context: Phase 2 Task 09 — 인앱 결제 인프라 (RevenueCat).
신규 피처: lib/features/subscription/ 생성.
<!-- [FIX] 의존성 추가 전 사용자 승인 필요 — 구현 시작 전 확인 -->
pubspec.yaml에 `purchases_flutter: ^7.x.x` 추가 (사용자 승인 후).

## 항목 1: 도메인 레이어
설계 명세 코드 그대로:
- lib/features/subscription/domain/entities/subscription_status.dart
- lib/features/subscription/domain/repositories/subscription_repository.dart
- lib/features/subscription/domain/exceptions/subscription_exceptions.dart
- lib/features/subscription/domain/usecases/get_subscription_status_usecase.dart
- lib/features/subscription/domain/usecases/purchase_subscription_usecase.dart
- lib/features/subscription/domain/usecases/restore_purchases_usecase.dart

## 항목 2: RevenueCatDataSource
파일: lib/features/subscription/data/datasources/revenuecat_datasource.dart
```dart
class RevenueCatDataSource {
  Future<SubscriptionStatus> getStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _mapToStatus(customerInfo);
    } on PlatformException catch (e) {
      throw PurchaseFailedException(e.message ?? 'unknown');
    }
  }

  Future<SubscriptionStatus> purchase(String productId) async {
    try {
      final products = await Purchases.getProducts([productId]);
      if (products.isEmpty) throw const PurchaseFailedException('product_not_found');
      final customerInfo = await Purchases.purchaseStoreProduct(products.first);
      return _mapToStatus(customerInfo);
    // [FIX] PurchasesErrorCode는 enum 값 — try/catch 대상이 아님. PlatformException으로 catch
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw const PurchaseCanceledException();
      }
      throw PurchaseFailedException(errorCode.name);
    }
  }

  Future<SubscriptionStatus> restore() async {
    final customerInfo = await Purchases.restorePurchases();
    return _mapToStatus(customerInfo);
  }

  Future<List<SubscriptionProduct>> getProducts() async {
    final products = await Purchases.getProducts([
      'com.ownurtime.app.pro.monthly',
      'com.ownurtime.app.pro.annual',
    ]);
    return products.map((p) => SubscriptionProduct(
      productId: p.identifier,
      title: p.title,
      priceString: p.priceString,
      period: p.identifier.contains('monthly') ? 'monthly' : 'annual',
    )).toList();
  }

  SubscriptionStatus _mapToStatus(CustomerInfo info) {
    final isPremium = info.entitlements.active.containsKey('premium');
    if (!isPremium) return const SubscriptionStatus(tier: PremiumTier.free);

    final entitlement = info.entitlements.active['premium']!;
    final productId = entitlement.productIdentifier;
    return SubscriptionStatus(
      tier: productId.contains('monthly') ? PremiumTier.monthly : PremiumTier.annual,
      expiresAt: entitlement.expirationDate != null
          ? DateTime.parse(entitlement.expirationDate!)
          : null,
      productId: productId,
    );
  }
}
```

## 항목 3: SubscriptionRepositoryImpl
파일: lib/features/subscription/data/repositories/subscription_repository_impl.dart
- getStatus, purchase, restore, getProducts: datasource 위임
- watchStatus: Stream.periodic(Duration(minutes: 5)) → getStatus() 폴링
  (RevenueCat SDK 자체 스트림 없으므로 폴링)

## 항목 4: SubscriptionNotifier
파일: lib/features/subscription/presentation/providers/subscription_provider.dart
설계 명세 동작 그대로 + isPremiumProvider 추가.

## 항목 5: PremiumGateWidget
파일: lib/features/subscription/presentation/widgets/premium_gate_widget.dart
설계 명세 코드 그대로.

## 항목 6: PaywallScreen
파일: lib/features/subscription/presentation/screens/paywall_screen.dart
설계 명세 1-7 레이아웃 구현.
- 기능 비교 리스트: 하드코딩 대신 l10n 키 사용
- 플랜 선택 카드: 기본 연간 선택 (state 관리)
- "시작하기" → notifier.purchase(selectedProductId)
- purchasing 상태: 버튼 로딩

## 항목 7: GoRouter /paywall 추가
파일: lib/core/router/app_router.dart

## 항목 8: PremiumLockCard 수정 (Task 05에서 생성)
파일: lib/features/reward/presentation/widgets/premium_lock_card.dart
탭 → GoRouter.push('/paywall') (Task 05에서 placeholder → 실 라우트 연결)

## 항목 9: main.dart RevenueCat 초기화
```dart
// REVENUECAT_API_KEY: dart-define 기반
const revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');
if (revenueCatApiKey.isNotEmpty) {
  await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
}
```

## 항목 10: authProvider 수정 — RevenueCat logIn 연결
파일: lib/features/auth/presentation/providers/auth_provider.dart
signInWithApple 성공 후:
```dart
const rcKey = String.fromEnvironment('REVENUECAT_API_KEY');
if (rcKey.isNotEmpty) {
  await Purchases.logIn(user.id);
}
```
signOut 후:
```dart
if (rcKey.isNotEmpty) {
  await Purchases.logOut();
}
```

## 항목 11: StatsScreen PremiumGate 적용
파일: lib/features/stats/presentation/screens/stats_screen.dart
주간 상세 리포트 섹션을 PremiumGateWidget으로 감싸기 (feature: 'weeklyReport')

## 항목 12: TaskStartScreen AI 한도 초과 시 paywall 연결
파일: lib/features/task/presentation/screens/task_start_screen.dart
DailyLimitException 발생 시:
- isPremium=false → "더 쓰고 싶다면" CTA → /paywall
- isPremium=true → 무제한 허용 (Task 01 완료 후 서버 한도 조정 필요)

## 완료 조건
- flutter analyze: 0 warnings
- flutter test: 전체 통과 (RevenueCat mock 포함)
```

### 2-2. 구현 파일 목록

| 파일 | 담당 |
|------|------|
| `lib/features/subscription/domain/entities/subscription_status.dart` | Codex |
| `lib/features/subscription/domain/repositories/subscription_repository.dart` | Codex |
| `lib/features/subscription/domain/exceptions/subscription_exceptions.dart` | Codex |
| `lib/features/subscription/domain/usecases/*.dart` (3개) | Codex |
| `lib/features/subscription/data/datasources/revenuecat_datasource.dart` | Codex |
| `lib/features/subscription/data/repositories/subscription_repository_impl.dart` | Codex |
| `lib/features/subscription/data/providers/subscription_providers.dart` | Codex |
| `lib/features/subscription/presentation/providers/subscription_provider.dart` | Codex |
| `lib/features/subscription/presentation/widgets/premium_gate_widget.dart` | Codex |
| `lib/features/subscription/presentation/screens/paywall_screen.dart` | Codex |
| `lib/features/reward/presentation/widgets/premium_lock_card.dart` | Codex (Task 05 파일 수정) |
| `lib/features/stats/presentation/screens/stats_screen.dart` | Codex (PremiumGate 적용) |
| `lib/features/task/presentation/screens/task_start_screen.dart` | Codex (paywall CTA) |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Codex (RC logIn/Out) |
| `lib/core/router/app_router.dart` | Codex (/paywall 추가) |
| `lib/main.dart` | Codex (RC 초기화) |
| `pubspec.yaml` | Codex |

---

## 3. 테스트 명세

### `test/features/subscription/domain/purchase_subscription_usecase_test.dart`

```
TC-01: 구매 성공 → SubscriptionStatus(tier: monthly) 반환
  setup: FakeRepo.purchase() → SubscriptionStatus(tier: PremiumTier.monthly)
  기대: usecase('com.ownurtime.app.pro.monthly') returns status.isPremium=true

TC-02: 구매 취소 → PurchaseCanceledException rethrow
  setup: FakeRepo.purchase() → throws PurchaseCanceledException
  기대: usecase() throws PurchaseCanceledException
```

### `test/features/subscription/presentation/subscription_notifier_test.dart`

```
TC-03: build — free → loaded(free, products)
  setup: FakeRepo.getStatus() → free, getProducts() → [monthly, annual]
  기대: SubscriptionUiState.loaded(status: free, products: [...])

TC-04: purchase 성공 → loaded(premium)
  setup: FakeRepo.purchase() → monthly status
  기대: 최종 state == loaded(status.tier: monthly)

TC-05: purchase 취소 → 이전 상태 유지 (에러 없음)
  초기: loaded(free)
  purchase → PurchaseCanceledException
  기대: loaded(free) 유지 (error 상태 아님)

TC-06: purchase 실패 → error → 3초 후 loaded
  setup: FakeRepo.purchase() → PurchaseFailedException
  기대: error 상태 → (3초 후) loaded

TC-07: restore — 성공
  setup: FakeRepo.restore() → monthly status
  기대: loaded(status.tier: monthly)
```

### `test/features/subscription/presentation/premium_gate_widget_test.dart`

```
TC-08: isPremium=true → child 표시됨
  기대: Text("child content") 존재

TC-09: isPremium=false → lock overlay 표시됨
  기대: Text("OwnUrTime Pro") 존재, child 없음
```

---

## 4. l10n 추가 (Codex)

`app_ko.arb`:
```json
"paywallTitle": "OwnUrTime Pro",
"paywallSubtitle": "ADHD를 위한 모든 도구",
"paywallMonthlyLabel": "월간",
"paywallMonthlyPrice": "{price}/월",
"@paywallMonthlyPrice": {"placeholders": {"price": {"type": "String"}}},
"paywallAnnualLabel": "연간",
"paywallAnnualPrice": "{price}/년",
"@paywallAnnualPrice": {"placeholders": {"price": {"type": "String"}}},
"paywallAnnualSaving": "{percent}% 절약",
"@paywallAnnualSaving": {"placeholders": {"percent": {"type": "int"}}},
"paywallStartButton": "시작하기",
"paywallRestoreButton": "구매 복원",
"paywallCancelButton": "취소",
"paywallFeatureFreeAiLimit": "AI 할일 분해 10회/일",
"paywallFeatureProAiUnlimited": "AI 할일 분해 무제한",
"paywallFeatureProBadges": "특별 보상 뱃지",
"paywallFeatureProReport": "주간 상세 리포트",
"paywallFeatureProInsight": "개인화 AI 인사이트 (출시 예정)",
"paywallPurchasing": "결제 중...",
"paywallErrorNetwork": "네트워크 연결을 확인해주세요.",
"paywallRestoreEmpty": "구독 내역이 없어요.",
"premiumLockLabel": "OwnUrTime Pro에서 해금",
"premiumGateButton": "Pro 시작하기"
```

---

## 5. Done When

- [ ] Sandbox 환경: 구독 화면 가격 표시됨 (RevenueCat 상품 로드)
- [ ] Sandbox 구매 → isPremium=true → 레이어 3 뱃지 해금됨
- [ ] 구매 취소 → 에러 없이 이전 화면 유지
- [ ] 구매 복원 → Sandbox 이전 구매 복원됨
- [ ] AI 한도 초과 → 비회원: paywall CTA 표시
- [ ] `flutter analyze` 0 warnings
- [ ] `flutter test` TC-01~TC-09 전체 통과

---

## 수동 설정 가이드

`docs/guides/revenuecat-setup.md` 작성 (Claude Code):
1. RevenueCat 대시보드 → 새 프로젝트: "OwnUrTime"
2. App Store Connect App 연결
3. 구독 상품 2개 등록 (monthly, annual)
4. Entitlement 생성: `premium` → 두 상품 연결
5. API Key 복사 → `--dart-define=REVENUECAT_API_KEY=<key>`
6. Sandbox 테스트 계정으로 구매 검증
