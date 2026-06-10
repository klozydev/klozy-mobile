// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddressBookPage]
class AddressBookRoute extends PageRouteInfo<void> {
  const AddressBookRoute({List<PageRouteInfo>? children})
    : super(AddressBookRoute.name, initialChildren: children);

  static const String name = 'AddressBookRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddressBookPage();
    },
  );
}

/// generated route for
/// [AddressFormPage]
class AddressFormRoute extends PageRouteInfo<AddressFormRouteArgs> {
  AddressFormRoute({Address? address, Key? key, List<PageRouteInfo>? children})
    : super(
        AddressFormRoute.name,
        args: AddressFormRouteArgs(address: address, key: key),
        initialChildren: children,
      );

  static const String name = 'AddressFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddressFormRouteArgs>(
        orElse: () => const AddressFormRouteArgs(),
      );
      return AddressFormPage(address: args.address, key: args.key);
    },
  );
}

class AddressFormRouteArgs {
  const AddressFormRouteArgs({this.address, this.key});

  final Address? address;

  final Key? key;

  @override
  String toString() {
    return 'AddressFormRouteArgs{address: $address, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddressFormRouteArgs) return false;
    return address == other.address && key == other.key;
  }

  @override
  int get hashCode => address.hashCode ^ key.hashCode;
}

/// generated route for
/// [BlockedUsersPage]
class BlockedUsersRoute extends PageRouteInfo<void> {
  const BlockedUsersRoute({List<PageRouteInfo>? children})
    : super(BlockedUsersRoute.name, initialChildren: children);

  static const String name = 'BlockedUsersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BlockedUsersPage();
    },
  );
}

/// generated route for
/// [CartPage]
class CartRoute extends PageRouteInfo<void> {
  const CartRoute({List<PageRouteInfo>? children})
    : super(CartRoute.name, initialChildren: children);

  static const String name = 'CartRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const CartPage());
    },
  );
}

/// generated route for
/// [ChatPage]
class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatPage();
    },
  );
}

/// generated route for
/// [CheckoutPage]
class CheckoutRoute extends PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    required String sellerId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         CheckoutRoute.name,
         args: CheckoutRouteArgs(sellerId: sellerId, key: key),
         initialChildren: children,
       );

  static const String name = 'CheckoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckoutRouteArgs>();
      return WrappedRoute(
        child: CheckoutPage(sellerId: args.sellerId, key: args.key),
      );
    },
  );
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({required this.sellerId, this.key});

  final String sellerId;

  final Key? key;

  @override
  String toString() {
    return 'CheckoutRouteArgs{sellerId: $sellerId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckoutRouteArgs) return false;
    return sellerId == other.sellerId && key == other.key;
  }

  @override
  int get hashCode => sellerId.hashCode ^ key.hashCode;
}

/// generated route for
/// [EditListingPage]
class EditListingRoute extends PageRouteInfo<EditListingRouteArgs> {
  EditListingRoute({
    required String productId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         EditListingRoute.name,
         args: EditListingRouteArgs(productId: productId, key: key),
         rawPathParams: {'id': productId},
         initialChildren: children,
       );

  static const String name = 'EditListingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditListingRouteArgs>(
        orElse: () =>
            EditListingRouteArgs(productId: pathParams.getString('id')),
      );
      return EditListingPage(productId: args.productId, key: args.key);
    },
  );
}

class EditListingRouteArgs {
  const EditListingRouteArgs({required this.productId, this.key});

  final String productId;

  final Key? key;

  @override
  String toString() {
    return 'EditListingRouteArgs{productId: $productId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditListingRouteArgs) return false;
    return productId == other.productId && key == other.key;
  }

  @override
  int get hashCode => productId.hashCode ^ key.hashCode;
}

/// generated route for
/// [EditProfilePage]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfilePage();
    },
  );
}

/// generated route for
/// [FollowListPage]
class FollowListRoute extends PageRouteInfo<FollowListRouteArgs> {
  FollowListRoute({
    required String userId,
    bool showFollowers = true,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         FollowListRoute.name,
         args: FollowListRouteArgs(
           userId: userId,
           showFollowers: showFollowers,
           key: key,
         ),
         rawPathParams: {'id': userId},
         initialChildren: children,
       );

  static const String name = 'FollowListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FollowListRouteArgs>(
        orElse: () => FollowListRouteArgs(userId: pathParams.getString('id')),
      );
      return WrappedRoute(
        child: FollowListPage(
          userId: args.userId,
          showFollowers: args.showFollowers,
          key: args.key,
        ),
      );
    },
  );
}

class FollowListRouteArgs {
  const FollowListRouteArgs({
    required this.userId,
    this.showFollowers = true,
    this.key,
  });

  final String userId;

  final bool showFollowers;

  final Key? key;

  @override
  String toString() {
    return 'FollowListRouteArgs{userId: $userId, showFollowers: $showFollowers, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FollowListRouteArgs) return false;
    return userId == other.userId &&
        showFollowers == other.showFollowers &&
        key == other.key;
  }

  @override
  int get hashCode => userId.hashCode ^ showFollowers.hashCode ^ key.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const HomePage());
    },
  );
}

/// generated route for
/// [LegalDocPage]
class LegalDocRoute extends PageRouteInfo<LegalDocRouteArgs> {
  LegalDocRoute({
    required String docKey,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         LegalDocRoute.name,
         args: LegalDocRouteArgs(docKey: docKey, key: key),
         rawPathParams: {'key': docKey},
         initialChildren: children,
       );

  static const String name = 'LegalDocRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<LegalDocRouteArgs>(
        orElse: () => LegalDocRouteArgs(docKey: pathParams.getString('key')),
      );
      return LegalDocPage(docKey: args.docKey, key: args.key);
    },
  );
}

class LegalDocRouteArgs {
  const LegalDocRouteArgs({required this.docKey, this.key});

  final String docKey;

  final Key? key;

  @override
  String toString() {
    return 'LegalDocRouteArgs{docKey: $docKey, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LegalDocRouteArgs) return false;
    return docKey == other.docKey && key == other.key;
  }

  @override
  int get hashCode => docKey.hashCode ^ key.hashCode;
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({Key? key, bool isSignUp = true, List<PageRouteInfo>? children})
    : super(
        LoginRoute.name,
        args: LoginRouteArgs(key: key, isSignUp: isSignUp),
        initialChildren: children,
      );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return WrappedRoute(
        child: LoginPage(key: args.key, isSignUp: args.isSignUp),
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.isSignUp = true});

  final Key? key;

  final bool isSignUp;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, isSignUp: $isSignUp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key && isSignUp == other.isSignUp;
  }

  @override
  int get hashCode => key.hashCode ^ isSignUp.hashCode;
}

/// generated route for
/// [NotificationsPage]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const NotificationsPage());
    },
  );
}

/// generated route for
/// [OffersPage]
class OffersRoute extends PageRouteInfo<void> {
  const OffersRoute({List<PageRouteInfo>? children})
    : super(OffersRoute.name, initialChildren: children);

  static const String name = 'OffersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OffersPage();
    },
  );
}

/// generated route for
/// [OrderDetailPage]
class OrderDetailRoute extends PageRouteInfo<OrderDetailRouteArgs> {
  OrderDetailRoute({
    required String id,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         OrderDetailRoute.name,
         args: OrderDetailRouteArgs(id: id, key: key),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'OrderDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrderDetailRouteArgs>(
        orElse: () => OrderDetailRouteArgs(id: pathParams.getString('id')),
      );
      return WrappedRoute(
        child: OrderDetailPage(id: args.id, key: args.key),
      );
    },
  );
}

class OrderDetailRouteArgs {
  const OrderDetailRouteArgs({required this.id, this.key});

  final String id;

  final Key? key;

  @override
  String toString() {
    return 'OrderDetailRouteArgs{id: $id, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrderDetailRouteArgs) return false;
    return id == other.id && key == other.key;
  }

  @override
  int get hashCode => id.hashCode ^ key.hashCode;
}

/// generated route for
/// [OrdersPage]
class OrdersRoute extends PageRouteInfo<void> {
  const OrdersRoute({List<PageRouteInfo>? children})
    : super(OrdersRoute.name, initialChildren: children);

  static const String name = 'OrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const OrdersPage());
    },
  );
}

/// generated route for
/// [OtpPage]
class OtpRoute extends PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    Key? key,
    required String verificationId,
    required String destination,
    bool isEmail = false,
    List<PageRouteInfo>? children,
  }) : super(
         OtpRoute.name,
         args: OtpRouteArgs(
           key: key,
           verificationId: verificationId,
           destination: destination,
           isEmail: isEmail,
         ),
         initialChildren: children,
       );

  static const String name = 'OtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpRouteArgs>();
      return WrappedRoute(
        child: OtpPage(
          key: args.key,
          verificationId: args.verificationId,
          destination: args.destination,
          isEmail: args.isEmail,
        ),
      );
    },
  );
}

class OtpRouteArgs {
  const OtpRouteArgs({
    this.key,
    required this.verificationId,
    required this.destination,
    this.isEmail = false,
  });

  final Key? key;

  final String verificationId;

  final String destination;

  final bool isEmail;

  @override
  String toString() {
    return 'OtpRouteArgs{key: $key, verificationId: $verificationId, destination: $destination, isEmail: $isEmail}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpRouteArgs) return false;
    return key == other.key &&
        verificationId == other.verificationId &&
        destination == other.destination &&
        isEmail == other.isEmail;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      verificationId.hashCode ^
      destination.hashCode ^
      isEmail.hashCode;
}

/// generated route for
/// [PayoutPage]
class PayoutRoute extends PageRouteInfo<void> {
  const PayoutRoute({List<PageRouteInfo>? children})
    : super(PayoutRoute.name, initialChildren: children);

  static const String name = 'PayoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PayoutPage();
    },
  );
}

/// generated route for
/// [PayoutsPage]
class PayoutsRoute extends PageRouteInfo<void> {
  const PayoutsRoute({List<PageRouteInfo>? children})
    : super(PayoutsRoute.name, initialChildren: children);

  static const String name = 'PayoutsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PayoutsPage();
    },
  );
}

/// generated route for
/// [PersonalizePage]
class PersonalizeRoute extends PageRouteInfo<void> {
  const PersonalizeRoute({List<PageRouteInfo>? children})
    : super(PersonalizeRoute.name, initialChildren: children);

  static const String name = 'PersonalizeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const PersonalizePage());
    },
  );
}

/// generated route for
/// [PhonePage]
class PhoneRoute extends PageRouteInfo<void> {
  const PhoneRoute({List<PageRouteInfo>? children})
    : super(PhoneRoute.name, initialChildren: children);

  static const String name = 'PhoneRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const PhonePage());
    },
  );
}

/// generated route for
/// [PreferencesPage]
class PreferencesRoute extends PageRouteInfo<void> {
  const PreferencesRoute({List<PageRouteInfo>? children})
    : super(PreferencesRoute.name, initialChildren: children);

  static const String name = 'PreferencesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PreferencesPage();
    },
  );
}

/// generated route for
/// [ProductPage]
class ProductRoute extends PageRouteInfo<ProductRouteArgs> {
  ProductRoute({required String id, Key? key, List<PageRouteInfo>? children})
    : super(
        ProductRoute.name,
        args: ProductRouteArgs(id: id, key: key),
        rawPathParams: {'id': id},
        initialChildren: children,
      );

  static const String name = 'ProductRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ProductRouteArgs>(
        orElse: () => ProductRouteArgs(id: pathParams.getString('id')),
      );
      return WrappedRoute(
        child: ProductPage(id: args.id, key: args.key),
      );
    },
  );
}

class ProductRouteArgs {
  const ProductRouteArgs({required this.id, this.key});

  final String id;

  final Key? key;

  @override
  String toString() {
    return 'ProductRouteArgs{id: $id, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProductRouteArgs) return false;
    return id == other.id && key == other.key;
  }

  @override
  int get hashCode => id.hashCode ^ key.hashCode;
}

/// generated route for
/// [ProfileCompletionPage]
class ProfileCompletionRoute extends PageRouteInfo<void> {
  const ProfileCompletionRoute({List<PageRouteInfo>? children})
    : super(ProfileCompletionRoute.name, initialChildren: children);

  static const String name = 'ProfileCompletionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const ProfileCompletionPage());
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [ReelComposerPage]
class ReelComposerRoute extends PageRouteInfo<void> {
  const ReelComposerRoute({List<PageRouteInfo>? children})
    : super(ReelComposerRoute.name, initialChildren: children);

  static const String name = 'ReelComposerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const ReelComposerPage());
    },
  );
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const SearchPage());
    },
  );
}

/// generated route for
/// [SellPage]
class SellRoute extends PageRouteInfo<void> {
  const SellRoute({List<PageRouteInfo>? children})
    : super(SellRoute.name, initialChildren: children);

  static const String name = 'SellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const SellPage());
    },
  );
}

/// generated route for
/// [SellerRolePage]
class SellerRoleRoute extends PageRouteInfo<void> {
  const SellerRoleRoute({List<PageRouteInfo>? children})
    : super(SellerRoleRoute.name, initialChildren: children);

  static const String name = 'SellerRoleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const SellerRolePage());
    },
  );
}

/// generated route for
/// [SellerStatsPage]
class SellerStatsRoute extends PageRouteInfo<void> {
  const SellerStatsRoute({List<PageRouteInfo>? children})
    : super(SellerStatsRoute.name, initialChildren: children);

  static const String name = 'SellerStatsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SellerStatsPage();
    },
  );
}

/// generated route for
/// [SellerVerificationPage]
class SellerVerificationRoute extends PageRouteInfo<void> {
  const SellerVerificationRoute({List<PageRouteInfo>? children})
    : super(SellerVerificationRoute.name, initialChildren: children);

  static const String name = 'SellerVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SellerVerificationPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const SettingsPage());
    },
  );
}

/// generated route for
/// [ShellPage]
class ShellRoute extends PageRouteInfo<void> {
  const ShellRoute({List<PageRouteInfo>? children})
    : super(ShellRoute.name, initialChildren: children);

  static const String name = 'ShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ShellPage();
    },
  );
}

/// generated route for
/// [SingleReelPage]
class SingleReelRoute extends PageRouteInfo<SingleReelRouteArgs> {
  SingleReelRoute({
    required String reelId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         SingleReelRoute.name,
         args: SingleReelRouteArgs(reelId: reelId, key: key),
         rawPathParams: {'id': reelId},
         initialChildren: children,
       );

  static const String name = 'SingleReelRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SingleReelRouteArgs>(
        orElse: () => SingleReelRouteArgs(reelId: pathParams.getString('id')),
      );
      return SingleReelPage(reelId: args.reelId, key: args.key);
    },
  );
}

class SingleReelRouteArgs {
  const SingleReelRouteArgs({required this.reelId, this.key});

  final String reelId;

  final Key? key;

  @override
  String toString() {
    return 'SingleReelRouteArgs{reelId: $reelId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SingleReelRouteArgs) return false;
    return reelId == other.reelId && key == other.key;
  }

  @override
  int get hashCode => reelId.hashCode ^ key.hashCode;
}

/// generated route for
/// [SuccessPage]
class SuccessRoute extends PageRouteInfo<SuccessRouteArgs> {
  SuccessRoute({Key? key, String? firstName, List<PageRouteInfo>? children})
    : super(
        SuccessRoute.name,
        args: SuccessRouteArgs(key: key, firstName: firstName),
        initialChildren: children,
      );

  static const String name = 'SuccessRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SuccessRouteArgs>(
        orElse: () => const SuccessRouteArgs(),
      );
      return SuccessPage(key: args.key, firstName: args.firstName);
    },
  );
}

class SuccessRouteArgs {
  const SuccessRouteArgs({this.key, this.firstName});

  final Key? key;

  final String? firstName;

  @override
  String toString() {
    return 'SuccessRouteArgs{key: $key, firstName: $firstName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SuccessRouteArgs) return false;
    return key == other.key && firstName == other.firstName;
  }

  @override
  int get hashCode => key.hashCode ^ firstName.hashCode;
}

/// generated route for
/// [UserProfilePage]
class UserProfileRoute extends PageRouteInfo<UserProfileRouteArgs> {
  UserProfileRoute({
    required String userId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         UserProfileRoute.name,
         args: UserProfileRouteArgs(userId: userId, key: key),
         rawPathParams: {'id': userId},
         initialChildren: children,
       );

  static const String name = 'UserProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<UserProfileRouteArgs>(
        orElse: () => UserProfileRouteArgs(userId: pathParams.getString('id')),
      );
      return UserProfilePage(userId: args.userId, key: args.key);
    },
  );
}

class UserProfileRouteArgs {
  const UserProfileRouteArgs({required this.userId, this.key});

  final String userId;

  final Key? key;

  @override
  String toString() {
    return 'UserProfileRouteArgs{userId: $userId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserProfileRouteArgs) return false;
    return userId == other.userId && key == other.key;
  }

  @override
  int get hashCode => userId.hashCode ^ key.hashCode;
}

/// generated route for
/// [WelcomePage]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomePage();
    },
  );
}
