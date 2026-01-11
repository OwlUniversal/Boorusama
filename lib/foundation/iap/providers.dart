// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'iap_impl.dart';
import 'purchaser.dart';
import 'subscription.dart';

final iapFuncProvider = Provider<Future<IAP> Function()?>((ref) => null);

final iapProvider = FutureProvider<IAP>((ref) async {
  final iapFunc = ref.watch(iapFuncProvider);
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

Future<IAP> initDummyIap() async {
  const activePackage = Package(
    id: 'monthly_subscription',
    product: ProductDetails(
      id: 'monthly_subscription', // FIX: ensure this is 'id'
      title: 'Plus Unlocked',
      description: 'Enjoy your features',
      price: r'$0.00',
      rawPrice: 0.0,
      currencyCode: 'USD',
    ),
    type: PackageType.monthly,
  );

  return DefaultIAP(
    purchaser: DummyPurchaser(packages: [activePackage]),
    subscriptionManager: const DefaultSubscriptionManager(),
    activeSubscription: activePackage,
  );
}

final subscriptionPackagesProvider = FutureProvider.autoDispose<List<Package>>((
  ref,
) async {
  final iap = await ref.watch(iapProvider.future);
  final availablePackages = await iap.purchaser.getAvailablePackages();

  final packages = availablePackages.toList()
    ..sort((a, b) {
      if (a.type == PackageType.annual) {
        return -1;
      }
      return 1;
    });

  return packages;
});
