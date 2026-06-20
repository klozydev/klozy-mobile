// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddressFormPage]
class AddressFormRoute extends PageRouteInfo<AddressFormRouteArgs> {
  AddressFormRoute({
    Address? address,
    bool requirePhone = false,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AddressFormRoute.name,
         args: AddressFormRouteArgs(
           address: address,
           requirePhone: requirePhone,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'AddressFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddressFormRouteArgs>(
        orElse: () => const AddressFormRouteArgs(),
      );
      return AddressFormPage(
        address: args.address,
        requirePhone: args.requirePhone,
        key: args.key,
      );
    },
  );
}

class AddressFormRouteArgs {
  const AddressFormRouteArgs({
    this.address,
    this.requirePhone = false,
    this.key,
  });

  final Address? address;

  final bool requirePhone;

  final Key? key;

  @override
  String toString() {
    return 'AddressFormRouteArgs{address: $address, requirePhone: $requirePhone, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddressFormRouteArgs) return false;
    return address == other.address &&
        requirePhone == other.requirePhone &&
        key == other.key;
  }

  @override
  int get hashCode => address.hashCode ^ requirePhone.hashCode ^ key.hashCode;
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
/// [ChangeEmailPage]
class ChangeEmailRoute extends PageRouteInfo<void> {
  const ChangeEmailRoute({List<PageRouteInfo>? children})
    : super(ChangeEmailRoute.name, initialChildren: children);

  static const String name = 'ChangeEmailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangeEmailPage();
    },
  );
}

/// generated route for
/// [ChangePasswordPage]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordPage();
    },
  );
}

/// generated route for
/// [ChangePhonePage]
class ChangePhoneRoute extends PageRouteInfo<void> {
  const ChangePhoneRoute({List<PageRouteInfo>? children})
    : super(ChangePhoneRoute.name, initialChildren: children);

  static const String name = 'ChangePhoneRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePhonePage();
    },
  );
}

/// generated route for
/// [ChatMediaPickerPage]
class ChatMediaPickerRoute extends PageRouteInfo<ChatMediaPickerRouteArgs> {
  ChatMediaPickerRoute({
    required String tchatId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ChatMediaPickerRoute.name,
         args: ChatMediaPickerRouteArgs(tchatId: tchatId, key: key),
         rawPathParams: {'tchatId': tchatId},
         initialChildren: children,
       );

  static const String name = 'ChatMediaPickerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatMediaPickerRouteArgs>(
        orElse: () =>
            ChatMediaPickerRouteArgs(tchatId: pathParams.getString('tchatId')),
      );
      return ChatMediaPickerPage(tchatId: args.tchatId, key: args.key);
    },
  );
}

class ChatMediaPickerRouteArgs {
  const ChatMediaPickerRouteArgs({required this.tchatId, this.key});

  final String tchatId;

  final Key? key;

  @override
  String toString() {
    return 'ChatMediaPickerRouteArgs{tchatId: $tchatId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatMediaPickerRouteArgs) return false;
    return tchatId == other.tchatId && key == other.key;
  }

  @override
  int get hashCode => tchatId.hashCode ^ key.hashCode;
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
/// [ChatThreadPage]
class ChatThreadRoute extends PageRouteInfo<ChatThreadRouteArgs> {
  ChatThreadRoute({
    required String tchatId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ChatThreadRoute.name,
         args: ChatThreadRouteArgs(tchatId: tchatId, key: key),
         rawPathParams: {'tchatId': tchatId},
         initialChildren: children,
       );

  static const String name = 'ChatThreadRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatThreadRouteArgs>(
        orElse: () =>
            ChatThreadRouteArgs(tchatId: pathParams.getString('tchatId')),
      );
      return ChatThreadPage(tchatId: args.tchatId, key: args.key);
    },
  );
}

class ChatThreadRouteArgs {
  const ChatThreadRouteArgs({required this.tchatId, this.key});

  final String tchatId;

  final Key? key;

  @override
  String toString() {
    return 'ChatThreadRouteArgs{tchatId: $tchatId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatThreadRouteArgs) return false;
    return tchatId == other.tchatId && key == other.key;
  }

  @override
  int get hashCode => tchatId.hashCode ^ key.hashCode;
}

/// generated route for
/// [CheckoutPage]
class CheckoutRoute extends PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    required String sellerId,
    required CartBucket bucket,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         CheckoutRoute.name,
         args: CheckoutRouteArgs(sellerId: sellerId, bucket: bucket, key: key),
         initialChildren: children,
       );

  static const String name = 'CheckoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckoutRouteArgs>();
      return WrappedRoute(
        child: CheckoutPage(
          sellerId: args.sellerId,
          bucket: args.bucket,
          key: args.key,
        ),
      );
    },
  );
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({
    required this.sellerId,
    required this.bucket,
    this.key,
  });

  final String sellerId;

  final CartBucket bucket;

  final Key? key;

  @override
  String toString() {
    return 'CheckoutRouteArgs{sellerId: $sellerId, bucket: $bucket, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckoutRouteArgs) return false;
    return sellerId == other.sellerId &&
        bucket == other.bucket &&
        key == other.key;
  }

  @override
  int get hashCode => sellerId.hashCode ^ bucket.hashCode ^ key.hashCode;
}

/// generated route for
/// [ClothingPreferencePage]
class ClothingPreferenceRoute extends PageRouteInfo<void> {
  const ClothingPreferenceRoute({List<PageRouteInfo>? children})
    : super(ClothingPreferenceRoute.name, initialChildren: children);

  static const String name = 'ClothingPreferenceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ClothingPreferencePage();
    },
  );
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
/// [PersonalDataPage]
class PersonalDataRoute extends PageRouteInfo<void> {
  const PersonalDataRoute({List<PageRouteInfo>? children})
    : super(PersonalDataRoute.name, initialChildren: children);

  static const String name = 'PersonalDataRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PersonalDataPage();
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
/// [PreferredBrandsPage]
class PreferredBrandsRoute extends PageRouteInfo<void> {
  const PreferredBrandsRoute({List<PageRouteInfo>? children})
    : super(PreferredBrandsRoute.name, initialChildren: children);

  static const String name = 'PreferredBrandsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PreferredBrandsPage();
    },
  );
}

/// generated route for
/// [PreferredSizePage]
class PreferredSizeRoute extends PageRouteInfo<void> {
  const PreferredSizeRoute({List<PageRouteInfo>? children})
    : super(PreferredSizeRoute.name, initialChildren: children);

  static const String name = 'PreferredSizeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PreferredSizePage();
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
/// [SearchCategoryPage]
class SearchCategoryRoute extends PageRouteInfo<SearchCategoryRouteArgs> {
  SearchCategoryRoute({
    Key? key,
    required CatalogCategory root,
    List<PageRouteInfo>? children,
  }) : super(
         SearchCategoryRoute.name,
         args: SearchCategoryRouteArgs(key: key, root: root),
         initialChildren: children,
       );

  static const String name = 'SearchCategoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchCategoryRouteArgs>();
      return WrappedRoute(
        child: SearchCategoryPage(key: args.key, root: args.root),
      );
    },
  );
}

class SearchCategoryRouteArgs {
  const SearchCategoryRouteArgs({this.key, required this.root});

  final Key? key;

  final CatalogCategory root;

  @override
  String toString() {
    return 'SearchCategoryRouteArgs{key: $key, root: $root}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchCategoryRouteArgs) return false;
    return key == other.key && root == other.root;
  }

  @override
  int get hashCode => key.hashCode ^ root.hashCode;
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
/// [SecurityPage]
class SecurityRoute extends PageRouteInfo<void> {
  const SecurityRoute({List<PageRouteInfo>? children})
    : super(SecurityRoute.name, initialChildren: children);

  static const String name = 'SecurityRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SecurityPage();
    },
  );
}

/// generated route for
/// [SellCategoryPage]
class SellCategoryRoute extends PageRouteInfo<SellCategoryRouteArgs> {
  SellCategoryRoute({
    Key? key,
    CatalogCategory? parent,
    List<PageRouteInfo>? children,
  }) : super(
         SellCategoryRoute.name,
         args: SellCategoryRouteArgs(key: key, parent: parent),
         initialChildren: children,
       );

  static const String name = 'SellCategoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SellCategoryRouteArgs>(
        orElse: () => const SellCategoryRouteArgs(),
      );
      return WrappedRoute(
        child: SellCategoryPage(key: args.key, parent: args.parent),
      );
    },
  );
}

class SellCategoryRouteArgs {
  const SellCategoryRouteArgs({this.key, this.parent});

  final Key? key;

  final CatalogCategory? parent;

  @override
  String toString() {
    return 'SellCategoryRouteArgs{key: $key, parent: $parent}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SellCategoryRouteArgs) return false;
    return key == other.key && parent == other.parent;
  }

  @override
  int get hashCode => key.hashCode ^ parent.hashCode;
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
