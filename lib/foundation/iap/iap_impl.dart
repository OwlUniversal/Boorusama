// Project imports:
import 'providers.dart';
import 'purchaser.dart';
import 'subscription.dart';

class DefaultSubscriptionManager implements SubscriptionManager {
  const DefaultSubscriptionManager();

  static const _kDefaultPackage = Package(
    id: 'monthly_subscription',
    product: ProductDetails(
      id: 'monthly_subscription',
      title: '1 month',
      description: 'Plus Unlocked',
      price: r'$0.00',
      rawPrice: 0.0,
      currencyCode: 'USD',
    ),
    type: PackageType.monthly,
  );

  @override
  Future<bool> hasActiveSubscription(String id) async => true; // Always Plus

  @override
  Future<String?> get managementURL async => null;

  @override
  Future<List<Package>> getActiveSubscriptions() async {
    return [_kDefaultPackage];
  }
}

class DefaultIAP implements IAP {
  DefaultIAP({
    required this.purchaser,
    required this.subscriptionManager,
    this.activeSubscription,
  });

  @override
  final Purchaser purchaser;

  @override
  final SubscriptionManager subscriptionManager;

  @override
  final Package? activeSubscription;
}

class DummyIAP implements IAP {
  DummyIAP._({
    required this.purchaser,
    required this.subscriptionManager,
  });

  factory DummyIAP.create() {
    // Pass empty list to DummyPurchaser since we don't need real packages to buy
    final iap = DummyPurchaser(packages: []);
    final subscriptionManager = const DefaultSubscriptionManager();

    return DummyIAP._(
      purchaser: iap,
      subscriptionManager: subscriptionManager,
    );
  }

  Future<void> init() async {
    final activePackages = await getActiveSubscriptionPackages(
      subscriptionManager,
    );

    if (activePackages != null && activePackages.isNotEmpty) {
      _activeSubscription = activePackages.first;
    }
  }

  Package? _activeSubscription;

  @override
  final Purchaser purchaser;

  @override
  final SubscriptionManager subscriptionManager;

  @override
  Package? get activeSubscription => _activeSubscription;
}

// FIXED DUMMY PURCHASER
class DummyPurchaser implements Purchaser {
  final List<Package> packages;
  DummyPurchaser({required this.packages});

  @override
  Future<List<Package>> getAvailablePackages() async => packages;

  @override
  Future<bool> purchasePackage(Package package) async => true;

  // Added missing method
  @override
  String? describePurchaseError(Object error) => null;

  // Fixed return type to Future<bool?>
  @override
  Future<bool?> restorePurchases() async => true;
}    if (activePackages != null && activePackages.isNotEmpty) {
      _activeSubscription = activePackages.first;
    }
  }

  Package? _activeSubscription;

  @override
  final Purchaser purchaser;

  @override
  final SubscriptionManager subscriptionManager;

  @override
  Package? get activeSubscription => _activeSubscription;
}

// FIXED DUMMY PURCHASER
class DummyPurchaser implements Purchaser {
  final List<Package> packages;
  DummyPurchaser({required this.packages});

  @override
  Future<List<Package>> getAvailablePackages() async => packages;

  @override
  Future<bool> purchasePackage(Package package) async => true;

  // Added missing method
  @override
  String? describePurchaseError(Object error) => null;

  // Fixed return type to Future<bool?>
  @override
  Future<bool?> restorePurchases() async => true;
}
