// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:event_bus/event_bus.dart' as _i1017;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as _i447;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:klozy/src/app/bloc/account/account_bloc.dart' as _i386;
import 'package:klozy/src/app/bloc/app_bloc.dart' as _i432;
import 'package:klozy/src/app/cart/cart_cubit.dart' as _i675;
import 'package:klozy/src/app/chat/chat_unread_cubit.dart' as _i520;
import 'package:klozy/src/app/notifications/notifications_cubit.dart' as _i276;
import 'package:klozy/src/app/push/push_service.dart' as _i27;
import 'package:klozy/src/app/theme/app_config_change_notifier.dart' as _i616;
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart' as _i956;
import 'package:klozy/src/core/account/account_gate.dart' as _i634;
import 'package:klozy/src/core/network/base_url/base_url.dart' as _i402;
import 'package:klozy/src/core/network/cache/session_cache.dart' as _i560;
import 'package:klozy/src/core/network/interceptors/authentication_interceptor.dart'
    as _i211;
import 'package:klozy/src/core/network/interceptors/cache_interceptor.dart'
    as _i889;
import 'package:klozy/src/core/network/interceptors/default_interceptor.dart'
    as _i793;
import 'package:klozy/src/core/network/interceptors/logging_interceptor.dart'
    as _i32;
import 'package:klozy/src/core/observability/app_logger.dart' as _i370;
import 'package:klozy/src/core/observability/observability_module.dart'
    as _i520;
import 'package:klozy/src/core/prefs/prefs.dart' as _i906;
import 'package:klozy/src/data/auth/firebase_auth_repository.dart' as _i751;
import 'package:klozy/src/data/cart/cart_repository_impl.dart' as _i358;
import 'package:klozy/src/data/catalog/catalog_repository_impl.dart' as _i379;
import 'package:klozy/src/data/checkout/checkout_repository_impl.dart' as _i406;
import 'package:klozy/src/data/config/public_config_repository_impl.dart'
    as _i441;
import 'package:klozy/src/data/me/me_repository_impl.dart' as _i470;
import 'package:klozy/src/data/notifications/notifications_repository_impl.dart'
    as _i175;
import 'package:klozy/src/data/offers/offers_repository_impl.dart' as _i538;
import 'package:klozy/src/data/orders/orders_repository_impl.dart' as _i339;
import 'package:klozy/src/data/places/datasource/places_remote_datasource.dart'
    as _i541;
import 'package:klozy/src/data/places/mapper/places_mapper.dart' as _i915;
import 'package:klozy/src/data/places/places_repository_impl.dart' as _i902;
import 'package:klozy/src/data/product/products_repository_impl.dart' as _i251;
import 'package:klozy/src/data/sell/sell_repository_impl.dart' as _i607;
import 'package:klozy/src/data/social/social_repository_impl.dart' as _i590;
import 'package:klozy/src/data/uploads/uploads_repository_impl.dart' as _i369;
import 'package:klozy/src/data/wishlist/wishlist_repository_impl.dart' as _i759;
import 'package:klozy/src/di/app_module.dart' as _i816;
import 'package:klozy/src/di/firebase_module.dart' as _i910;
import 'package:klozy/src/di/network_module.dart' as _i1011;
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart'
    as _i865;
import 'package:klozy/src/domain/account/usecase/require_valid_account_usecase.dart'
    as _i631;
import 'package:klozy/src/domain/auth/auth_repository.dart' as _i176;
import 'package:klozy/src/domain/cart/cart_repository.dart' as _i444;
import 'package:klozy/src/domain/catalog/catalog_repository.dart' as _i204;
import 'package:klozy/src/domain/checkout/checkout_repository.dart' as _i328;
import 'package:klozy/src/domain/config/public_config_repository.dart' as _i264;
import 'package:klozy/src/domain/me/me_repository.dart' as _i1010;
import 'package:klozy/src/domain/notifications/notifications_repository.dart'
    as _i755;
import 'package:klozy/src/domain/offers/offers_repository.dart' as _i486;
import 'package:klozy/src/domain/orders/orders_repository.dart' as _i242;
import 'package:klozy/src/domain/places/places_repository.dart' as _i904;
import 'package:klozy/src/domain/product/products_repository.dart' as _i786;
import 'package:klozy/src/domain/sell/sell_repository.dart' as _i320;
import 'package:klozy/src/domain/sell/usecase/check_sell_prerequisite_usecase.dart'
    as _i549;
import 'package:klozy/src/domain/social/social_repository.dart' as _i931;
import 'package:klozy/src/domain/uploads/uploads_repository.dart' as _i827;
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart' as _i264;
import 'package:klozy/src/feature/auth/presentation/bloc/auth_bloc.dart'
    as _i692;
import 'package:klozy/src/feature/cart/presentation/bloc/cart_bloc.dart'
    as _i773;
import 'package:klozy/src/feature/chat/data/chat_repository_impl.dart' as _i259;
import 'package:klozy/src/feature/chat/data/datasource/chat_remote_data_source.dart'
    as _i511;
import 'package:klozy/src/feature/chat/domain/chat_repository.dart' as _i668;
import 'package:klozy/src/feature/chat/domain/usecase/delete_conversation.dart'
    as _i735;
import 'package:klozy/src/feature/chat/domain/usecase/mark_thread_seen.dart'
    as _i850;
import 'package:klozy/src/feature/chat/domain/usecase/open_or_create_thread.dart'
    as _i1011;
import 'package:klozy/src/feature/chat/domain/usecase/report_and_block.dart'
    as _i316;
import 'package:klozy/src/feature/chat/domain/usecase/respond_to_offer.dart'
    as _i795;
import 'package:klozy/src/feature/chat/domain/usecase/send_audio_message.dart'
    as _i48;
import 'package:klozy/src/feature/chat/domain/usecase/send_media_message.dart'
    as _i41;
import 'package:klozy/src/feature/chat/domain/usecase/send_text_message.dart'
    as _i560;
import 'package:klozy/src/feature/chat/domain/usecase/watch_messages.dart'
    as _i113;
import 'package:klozy/src/feature/chat/domain/usecase/watch_thread.dart'
    as _i25;
import 'package:klozy/src/feature/chat/domain/usecase/watch_threads.dart'
    as _i1046;
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_bloc.dart'
    as _i637;
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_bloc.dart'
    as _i919;
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_bloc.dart'
    as _i351;
import 'package:klozy/src/feature/home/presentation/bloc/feed_bloc.dart'
    as _i266;
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_cubit.dart'
    as _i809;
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_bloc.dart'
    as _i817;
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_bloc.dart'
    as _i1037;
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_bloc.dart'
    as _i498;
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_bloc.dart'
    as _i918;
import 'package:klozy/src/feature/orders/presentation/bloc/order_detail_bloc.dart'
    as _i483;
import 'package:klozy/src/feature/orders/presentation/bloc/orders_bloc.dart'
    as _i1007;
import 'package:klozy/src/feature/product/presentation/bloc/product_bloc.dart'
    as _i212;
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_bloc.dart'
    as _i496;
import 'package:klozy/src/feature/profile/presentation/bloc/profile_bloc.dart'
    as _i1029;
import 'package:klozy/src/feature/reels/data/datasource/remote_reels_data_source.dart'
    as _i465;
import 'package:klozy/src/feature/reels/data/reels_repository_impl.dart'
    as _i203;
import 'package:klozy/src/feature/reels/domain/reels_repository.dart' as _i651;
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_bloc.dart'
    as _i728;
import 'package:klozy/src/feature/reels/presentation/bloc/reels_bloc.dart'
    as _i194;
import 'package:klozy/src/feature/reels/presentation/playback/reel_playback_coordinator.dart'
    as _i619;
import 'package:klozy/src/feature/search/presentation/bloc/search_bloc.dart'
    as _i345;
import 'package:klozy/src/feature/sell/presentation/bloc/sell_bloc.dart'
    as _i402;
import 'package:klozy/src/feature/settings/presentation/bloc/settings_bloc.dart'
    as _i762;
import 'package:klozy/src/router/account_guard.dart' as _i672;
import 'package:klozy/src/router/app_router.dart' as _i774;
import 'package:klozy/src/router/auth_guard.dart' as _i480;
import 'package:klozy/src/router/onboarding_guard.dart' as _i281;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    final networkModule = _$NetworkModule();
    final firebaseModule = _$FirebaseModule();
    final observabilityModule = _$ObservabilityModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.getSharedPreferences(),
      preResolve: true,
    );
    gh.factory<_i402.BaseUrl>(() => networkModule.getBaseUrl());
    gh.factory<_i793.DefaultInterceptor>(
      () => const _i793.DefaultInterceptor(),
    );
    gh.factory<_i432.AppBloc>(() => _i432.AppBloc());
    gh.factory<_i915.PlacesMapper>(() => const _i915.PlacesMapper());
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => firebaseModule.firebaseMessaging,
    );
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFirestore,
    );
    gh.lazySingleton<_i457.FirebaseStorage>(
      () => firebaseModule.firebaseStorage,
    );
    gh.lazySingleton<_i1017.EventBus>(() => appModule.getEventBus());
    gh.lazySingleton<_i447.CacheManager>(
      () => appModule.getImageCacheManager(),
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => appModule.getFlutterSecureStorage(),
    );
    gh.lazySingleton<_i560.SessionCache>(() => _i560.SessionCache());
    gh.lazySingleton<_i370.AppLogger>(() => observabilityModule.getAppLogger());
    gh.lazySingleton<_i619.ReelPlaybackCoordinator>(
      () => _i619.ReelPlaybackCoordinator(),
    );
    gh.factory<_i511.ChatRemoteDataSource>(
      () => _i511.ChatRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.factory<_i889.CacheInterceptor>(
      () => _i889.CacheInterceptor(gh<_i560.SessionCache>()),
    );
    gh.factory<_i906.Prefs>(() => _i906.Prefs(gh<_i460.SharedPreferences>()));
    gh.factory<_i480.AuthGuard>(() => _i480.AuthGuard(gh<_i59.FirebaseAuth>()));
    gh.factory<_i32.LoggingInterceptor>(
      () => _i32.LoggingInterceptor(gh<_i370.AppLogger>()),
    );
    gh.factory<_i211.AuthenticationInterceptor>(
      () => _i211.AuthenticationInterceptor(
        gh<_i59.FirebaseAuth>(),
        gh<_i402.BaseUrl>(),
      ),
    );
    gh.factory<_i361.Dio>(
      () => networkModule.getDio(
        gh<_i211.AuthenticationInterceptor>(),
        gh<_i793.DefaultInterceptor>(),
        gh<_i32.LoggingInterceptor>(),
        gh<_i889.CacheInterceptor>(),
        gh<_i402.BaseUrl>(),
      ),
    );
    gh.lazySingleton<_i755.NotificationsRepository>(
      () => _i175.NotificationsRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i465.RemoteReelsDataSource>(
      () => _i465.RemoteReelsDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i541.PlacesRemoteDatasource>(
      () => _i541.PlacesRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i904.PlacesRepository>(
      () => _i902.PlacesRepositoryImpl(
        gh<_i541.PlacesRemoteDatasource>(),
        gh<_i915.PlacesMapper>(),
      ),
    );
    gh.lazySingleton<_i204.CatalogRepository>(
      () => _i379.CatalogRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i616.AppConfigChangeNotifier>(
      () => _i616.AppConfigChangeNotifier(gh<_i906.Prefs>()),
    );
    gh.lazySingleton<_i320.SellRepository>(
      () => _i607.SellRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1010.MeRepository>(
      () => _i470.MeRepositoryImpl(gh<_i361.Dio>(), gh<_i560.SessionCache>()),
    );
    gh.factory<_i1037.PersonalizeBloc>(
      () => _i1037.PersonalizeBloc(
        gh<_i204.CatalogRepository>(),
        gh<_i1010.MeRepository>(),
      ),
    );
    gh.lazySingleton<_i276.NotificationsCubit>(
      () => _i276.NotificationsCubit(gh<_i755.NotificationsRepository>()),
    );
    gh.factory<_i918.SellerRoleBloc>(
      () => _i918.SellerRoleBloc(gh<_i1010.MeRepository>()),
    );
    gh.factory<_i549.CheckSellPrerequisiteUseCase>(
      () => _i549.CheckSellPrerequisiteUseCase(gh<_i1010.MeRepository>()),
    );
    gh.lazySingleton<_i328.CheckoutRepository>(
      () => _i406.CheckoutRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i486.OffersRepository>(
      () => _i538.OffersRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i827.UploadsRepository>(
      () => _i369.UploadsRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i242.OrdersRepository>(
      () => _i339.OrdersRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i668.ChatRepository>(
      () => _i259.ChatRepositoryImpl(
        gh<_i511.ChatRemoteDataSource>(),
        gh<_i59.FirebaseAuth>(),
        gh<_i1010.MeRepository>(),
        gh<_i486.OffersRepository>(),
      ),
    );
    gh.lazySingleton<_i444.CartRepository>(
      () => _i358.CartRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i316.ReportAndBlock>(
      () => _i316.ReportAndBlock(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i41.SendMediaMessage>(
      () => _i41.SendMediaMessage(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i25.WatchThread>(
      () => _i25.WatchThread(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i113.WatchMessages>(
      () => _i113.WatchMessages(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i560.SendTextMessage>(
      () => _i560.SendTextMessage(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i795.RespondToOffer>(
      () => _i795.RespondToOffer(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i48.SendAudioMessage>(
      () => _i48.SendAudioMessage(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i1046.WatchThreads>(
      () => _i1046.WatchThreads(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i735.DeleteConversation>(
      () => _i735.DeleteConversation(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i1011.OpenOrCreateThread>(
      () => _i1011.OpenOrCreateThread(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i850.MarkThreadSeen>(
      () => _i850.MarkThreadSeen(gh<_i668.ChatRepository>()),
    );
    gh.factory<_i919.ChatThreadBloc>(
      () => _i919.ChatThreadBloc(
        gh<_i113.WatchMessages>(),
        gh<_i25.WatchThread>(),
        gh<_i560.SendTextMessage>(),
        gh<_i41.SendMediaMessage>(),
        gh<_i48.SendAudioMessage>(),
        gh<_i850.MarkThreadSeen>(),
        gh<_i735.DeleteConversation>(),
        gh<_i316.ReportAndBlock>(),
        gh<_i795.RespondToOffer>(),
      ),
    );
    gh.lazySingleton<_i264.PublicConfigRepository>(
      () => _i441.PublicConfigRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i651.ReelsRepository>(
      () => _i203.ReelsRepositoryImpl(
        gh<_i465.RemoteReelsDataSource>(),
        gh<_i1010.MeRepository>(),
        gh<_i1017.EventBus>(),
        gh<_i560.SessionCache>(),
      ),
    );
    gh.lazySingleton<_i264.WishlistRepository>(
      () => _i759.WishlistRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i786.ProductsRepository>(
      () => _i251.ProductsRepositoryImpl(
        gh<_i361.Dio>(),
        gh<_i1017.EventBus>(),
        gh<_i560.SessionCache>(),
      ),
    );
    gh.factory<_i817.NotificationsBloc>(
      () => _i817.NotificationsBloc(
        gh<_i755.NotificationsRepository>(),
        gh<_i276.NotificationsCubit>(),
      ),
    );
    gh.lazySingleton<_i176.AuthRepository>(
      () => _i751.FirebaseAuthRepository(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
        gh<_i1010.MeRepository>(),
        gh<_i560.SessionCache>(),
      ),
    );
    gh.lazySingleton<_i931.SocialRepository>(
      () => _i590.SocialRepositoryImpl(
        gh<_i361.Dio>(),
        gh<_i1010.MeRepository>(),
        gh<_i560.SessionCache>(),
      ),
    );
    gh.factory<_i402.SellBloc>(
      () => _i402.SellBloc(
        gh<_i827.UploadsRepository>(),
        gh<_i320.SellRepository>(),
        gh<_i786.ProductsRepository>(),
        gh<_i204.CatalogRepository>(),
      ),
    );
    gh.factory<_i809.WishlistFeedCubit>(
      () => _i809.WishlistFeedCubit(
        gh<_i264.WishlistRepository>(),
        gh<_i1017.EventBus>(),
      ),
    );
    gh.factory<_i1029.ProfileBloc>(
      () => _i1029.ProfileBloc(
        gh<_i931.SocialRepository>(),
        gh<_i1010.MeRepository>(),
        gh<_i1017.EventBus>(),
      ),
    );
    gh.factory<_i194.ReelsBloc>(
      () => _i194.ReelsBloc(gh<_i651.ReelsRepository>(), gh<_i1017.EventBus>()),
    );
    gh.factory<_i637.ChatListBloc>(
      () =>
          _i637.ChatListBloc(gh<_i1046.WatchThreads>(), gh<_i1017.EventBus>()),
    );
    gh.factory<_i266.FeedBloc>(
      () => _i266.FeedBloc(
        gh<_i786.ProductsRepository>(),
        gh<_i204.CatalogRepository>(),
        gh<_i1017.EventBus>(),
      ),
    );
    gh.lazySingleton<_i520.ChatUnreadCubit>(
      () => _i520.ChatUnreadCubit(
        gh<_i1046.WatchThreads>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.factory<_i1007.OrdersBloc>(
      () => _i1007.OrdersBloc(gh<_i242.OrdersRepository>()),
    );
    gh.factory<_i483.OrderDetailBloc>(
      () => _i483.OrderDetailBloc(gh<_i242.OrdersRepository>()),
    );
    gh.factory<_i498.ProfileCompletionBloc>(
      () => _i498.ProfileCompletionBloc(
        gh<_i1010.MeRepository>(),
        gh<_i904.PlacesRepository>(),
      ),
    );
    gh.factory<_i692.AuthBloc>(
      () =>
          _i692.AuthBloc(gh<_i176.AuthRepository>(), gh<_i1010.MeRepository>()),
    );
    gh.factory<_i865.GetAccountStatusUseCase>(
      () => _i865.GetAccountStatusUseCase(
        gh<_i176.AuthRepository>(),
        gh<_i1010.MeRepository>(),
      ),
    );
    gh.factory<_i728.ReelComposerBloc>(
      () => _i728.ReelComposerBloc(gh<_i651.ReelsRepository>()),
    );
    gh.lazySingleton<_i675.CartCubit>(
      () => _i675.CartCubit(gh<_i444.CartRepository>()),
    );
    gh.factory<_i386.AccountBloc>(
      () => _i386.AccountBloc(
        gh<_i865.GetAccountStatusUseCase>(),
        gh<_i176.AuthRepository>(),
        gh<_i1017.EventBus>(),
      ),
    );
    gh.factory<_i345.SearchBloc>(
      () => _i345.SearchBloc(
        gh<_i786.ProductsRepository>(),
        gh<_i204.CatalogRepository>(),
      ),
    );
    gh.factory<_i631.RequireValidAccountUseCase>(
      () =>
          _i631.RequireValidAccountUseCase(gh<_i865.GetAccountStatusUseCase>()),
    );
    gh.lazySingleton<_i956.WishlistCubit>(
      () => _i956.WishlistCubit(
        gh<_i264.WishlistRepository>(),
        gh<_i1017.EventBus>(),
      ),
    );
    gh.factory<_i351.CheckoutBloc>(
      () => _i351.CheckoutBloc(
        gh<_i328.CheckoutRepository>(),
        gh<_i1010.MeRepository>(),
        gh<_i675.CartCubit>(),
      ),
    );
    gh.factory<_i496.FollowListBloc>(
      () => _i496.FollowListBloc(gh<_i931.SocialRepository>()),
    );
    gh.factory<_i212.ProductBloc>(
      () => _i212.ProductBloc(
        gh<_i786.ProductsRepository>(),
        gh<_i444.CartRepository>(),
        gh<_i1010.MeRepository>(),
        gh<_i675.CartCubit>(),
      ),
    );
    gh.factory<_i634.AccountGate>(
      () => _i634.AccountGate(gh<_i631.RequireValidAccountUseCase>()),
    );
    gh.factory<_i281.OnboardingGuard>(
      () => _i281.OnboardingGuard(
        gh<_i865.GetAccountStatusUseCase>(),
        gh<_i176.AuthRepository>(),
      ),
    );
    gh.factory<_i672.AccountGuard>(
      () => _i672.AccountGuard(
        gh<_i865.GetAccountStatusUseCase>(),
        gh<_i176.AuthRepository>(),
      ),
    );
    gh.factory<_i773.CartBloc>(
      () => _i773.CartBloc(
        gh<_i444.CartRepository>(),
        gh<_i486.OffersRepository>(),
        gh<_i675.CartCubit>(),
      ),
    );
    gh.lazySingleton<_i774.AppRouter>(
      () => _i774.AppRouter(
        gh<_i672.AccountGuard>(),
        gh<_i281.OnboardingGuard>(),
      ),
    );
    gh.lazySingleton<_i27.PushService>(
      () => _i27.PushService(
        gh<_i892.FirebaseMessaging>(),
        gh<_i755.NotificationsRepository>(),
        gh<_i276.NotificationsCubit>(),
        gh<_i774.AppRouter>(),
      ),
    );
    gh.factory<_i762.SettingsBloc>(
      () => _i762.SettingsBloc(
        gh<_i1010.MeRepository>(),
        gh<_i176.AuthRepository>(),
        gh<_i264.PublicConfigRepository>(),
        gh<_i27.PushService>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i816.AppModule {}

class _$NetworkModule extends _i1011.NetworkModule {}

class _$FirebaseModule extends _i910.FirebaseModule {}

class _$ObservabilityModule extends _i520.ObservabilityModule {}
