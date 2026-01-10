// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'iap_impl.dart';
import 'purchaser.dart';
import 'subscription.dart';

final iapFuncProvider = Provider<Future<IAP> Function()?>((ref) => null);

final iapProvider = FutureProvider<IAP>((ref) async {
  final iapFunc = ref.watch(iapFuncProvider);
  // This will now use our Unlocked Dummy IAP
  final iap = iapFunc != null ? await iapFunc() : await initDummyIap();

  return iap;
});

final subscriptionManagerProvider = FutureProvider<SubscriptionManager>((
  ref,
) async {
  final iap = await ref.watch(iapProvider.future);

  return iap.subscriptionManager;
});

Future<List<Package>?> getActiveSubscriptionPackages(
  SubscriptionManager manager,
) async {
  final packages = await manager.getActiveSubscriptions();

  return packages;
}

/// MODIFIED: This now returns an IAP instance that is already "Plus"
Future<IAP> initDummyIap() async {
  const activePackage = Package(
    id: 'monthly_subscription',
    product: ProductDetails(
      id: 'monthly_subscription',
      title: 'Plus Unlocked',
      description: 'Enjoy your features',
      price: r'$0.00',
      rawPrice: 0.0,
      currencyCode: 'USD',
    ),
    type: PackageType.monthly,
  );

  // We use DefaultIAP from your iap_impl.dart and force the activeSubscription
  return DefaultIAP(
    purchaser: DummyPurchaser(packages: [activePackage]),
    subscriptionManager: const DefaultSubscriptionManager(),
    activeSubscription: activePackage, // This tells the UI we are Plus
  );
}

final subscriptionPackagesProvider = FutureProvider.autoDispose<List<Package>>((
  ref,
) async {
  final iap = await ref.watch(iapProvider.future);
  final availablePackages = await iap.purchaser.getAvailablePackages();

  // sort annual packages first
  final packages = availablePackages.toList()
    ..sort((a, b) {
      if (a.type == PackageType.annual) {
        return -1;
      }
      return 1;
    });

  return packages;
});
