// Project imports:
import 'providers.dart';
import 'purchaser.dart';
import 'subscription.dart';
// Note: If the build fails saying StoreProduct not found, change it back to ProductDetails
// But major upgrades usually require StoreProduct.

class DefaultSubscriptionManager implements SubscriptionManager {
  const DefaultSubscriptionManager();

  static const _kDefaultPackage = Package(
    id: 'monthly_subscription',
    // Newer RevenueCat versions use storeProduct instead of product
    // If this fails, rename 'storeProduct' back to 'product' and 'StoreProduct' to 'ProductDetails'
    storeProduct: StoreProduct(
      identifier: 'monthly_subscription',
      title: '1 month',
      description: 'Plus Unlocked',
      price: 0.0,
      priceString: '\$0.00',
      currencyCode: 'USD',
    ),
    packageType: PackageType.monthly,
    identifier: 'monthly_subscription', // specific to some RC versions
  );

  @override
  Future<bool> hasActiveSubscription(String id) async => true;

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

    // --- SYNTAX FIX WAS HERE ---
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

class DummyPurchaser implements Purchaser {
  final List<Package> packages;
  DummyPurchaser({required this.packages});

  @override
  Future<List<Package>> getAvailablePackages() async => packages;

  @override
  Future<bool> purchasePackage(Package package) async => true;

  @override
  String? describePurchaseError(Object error) => null;

  @override
  Future<bool?> restorePurchases() async => true;
}
