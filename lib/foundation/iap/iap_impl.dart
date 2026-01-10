// Project imports:
// import 'dummy.dart'; // REMOVED to prevent errors
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
  Future<bool> hasActiveSubscription(String id) async => true; // FORCE UNLOCK

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
    final iap = DummyPurchaser(
      packages: _kPackages,
    );

    // Use our unlocked manager instead of the missing DummySubscriptionManager
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

  static const _kPackages = <Package>[
    Package(
      id: 'annual_subscription',
      product: ProductDetails(
        id: 'annual_subscription',
        title: '1 year',
        description: '',
        price: r'$29.99',
        rawPrice: 29.99,
        currencyCode: 'USD',
      ),
      type: PackageType.annual,
    ),
    Package(
      id: 'monthly_subscription',
      product: ProductDetails(
        id: 'monthly_subscription',
        title: '1 month',
        description: '',
        price: r'$3.99',
        rawPrice: 3.99,
        currencyCode: 'USD',
      ),
      type: PackageType.monthly,
    ),
  ];
}

// DEFINED HERE TO FIX "NOT FOUND" ERRORS
class DummyPurchaser implements Purchaser {
  final List<Package> packages;
  DummyPurchaser({required this.packages});

  @override
  Future<List<Package>> getAvailablePackages() async => packages;

  @override
  Future<bool> purchasePackage(Package package) async => true;

  @override
  Future<void> restorePurchases() async {}
}
