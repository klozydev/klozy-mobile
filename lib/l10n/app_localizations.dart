import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fil'),
    Locale('fr'),
    Locale('hi'),
    Locale('kk'),
    Locale('ml'),
    Locale('pt'),
    Locale('ru'),
    Locale('ur'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Klozy'**
  String get app_name;

  /// No description provided for @ds_set_composition_header.
  ///
  /// In en, this message translates to:
  /// **'This set includes'**
  String get ds_set_composition_header;

  /// No description provided for @ds_set_composition_owner_note.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of each piece to reassure buyers and sell faster.'**
  String get ds_set_composition_owner_note;

  /// No description provided for @ds_set_composition_buyer_note.
  ///
  /// In en, this message translates to:
  /// **'Some pieces aren\'t photographed. Contact the seller for details.'**
  String get ds_set_composition_buyer_note;

  /// No description provided for @ds_set_composition_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get ds_set_composition_photo;

  /// No description provided for @ds_set_composition_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get ds_set_composition_add;

  /// No description provided for @ds_set_composition_no_photo.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get ds_set_composition_no_photo;

  /// No description provided for @ds_search_bar_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for an item or member'**
  String get ds_search_bar_hint;

  /// No description provided for @error_page_show_details.
  ///
  /// In en, this message translates to:
  /// **'SHOW DETAILS'**
  String get error_page_show_details;

  /// No description provided for @error_page_hide_details.
  ///
  /// In en, this message translates to:
  /// **'HIDE DETAILS'**
  String get error_page_hide_details;

  /// No description provided for @error_page_copy_for_support.
  ///
  /// In en, this message translates to:
  /// **'COPY FOR SUPPORT'**
  String get error_page_copy_for_support;

  /// No description provided for @error_page_need_help.
  ///
  /// In en, this message translates to:
  /// **'NEED HELP?'**
  String get error_page_need_help;

  /// No description provided for @error_page_support_email_label.
  ///
  /// In en, this message translates to:
  /// **'support@klozy.app'**
  String get error_page_support_email_label;

  /// No description provided for @error_page_source_label.
  ///
  /// In en, this message translates to:
  /// **'SOURCE'**
  String get error_page_source_label;

  /// No description provided for @error_page_stage_label.
  ///
  /// In en, this message translates to:
  /// **'STAGE'**
  String get error_page_stage_label;

  /// No description provided for @error_page_request_label.
  ///
  /// In en, this message translates to:
  /// **'REQUEST'**
  String get error_page_request_label;

  /// No description provided for @error_page_message_label.
  ///
  /// In en, this message translates to:
  /// **'MESSAGE'**
  String get error_page_message_label;

  /// No description provided for @error_scenario_network_title.
  ///
  /// In en, this message translates to:
  /// **'You appear to be offline'**
  String get error_scenario_network_title;

  /// No description provided for @error_scenario_network_body.
  ///
  /// In en, this message translates to:
  /// **'We need a connection to sync. Check your Wi-Fi or mobile data and try again.'**
  String get error_scenario_network_body;

  /// No description provided for @error_scenario_network_primary.
  ///
  /// In en, this message translates to:
  /// **'Retry connection'**
  String get error_scenario_network_primary;

  /// No description provided for @error_scenario_network_secondary.
  ///
  /// In en, this message translates to:
  /// **'Work offline'**
  String get error_scenario_network_secondary;

  /// No description provided for @error_scenario_server_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side'**
  String get error_scenario_server_title;

  /// No description provided for @error_scenario_server_body.
  ///
  /// In en, this message translates to:
  /// **'The server hit an unexpected error. Our team has been notified. You can retry in a moment.'**
  String get error_scenario_server_body;

  /// No description provided for @error_scenario_server_primary.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get error_scenario_server_primary;

  /// No description provided for @error_scenario_server_secondary.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get error_scenario_server_secondary;

  /// No description provided for @error_scenario_session_title.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get error_scenario_session_title;

  /// No description provided for @error_scenario_session_body.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired for security. Sign back in to continue.'**
  String get error_scenario_session_body;

  /// No description provided for @error_scenario_session_primary.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get error_scenario_session_primary;

  /// No description provided for @error_scenario_session_secondary.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get error_scenario_session_secondary;

  /// No description provided for @error_scenario_permission_title.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access here'**
  String get error_scenario_permission_title;

  /// No description provided for @error_scenario_permission_body.
  ///
  /// In en, this message translates to:
  /// **'This resource is restricted. Ask your manager to grant access.'**
  String get error_scenario_permission_body;

  /// No description provided for @error_scenario_permission_primary.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get error_scenario_permission_primary;

  /// No description provided for @error_scenario_permission_secondary.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get error_scenario_permission_secondary;

  /// No description provided for @error_scenario_notfound_title.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this'**
  String get error_scenario_notfound_title;

  /// No description provided for @error_scenario_notfound_body.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted or moved.'**
  String get error_scenario_notfound_body;

  /// No description provided for @error_scenario_notfound_primary.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get error_scenario_notfound_primary;

  /// No description provided for @error_scenario_notfound_secondary.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get error_scenario_notfound_secondary;

  /// No description provided for @error_scenario_rate_limit_title.
  ///
  /// In en, this message translates to:
  /// **'Slow down a moment'**
  String get error_scenario_rate_limit_title;

  /// No description provided for @error_scenario_rate_limit_body.
  ///
  /// In en, this message translates to:
  /// **'You\'ve made too many requests in a short time. Take a short break — you can retry in 30 seconds.'**
  String get error_scenario_rate_limit_body;

  /// No description provided for @error_scenario_rate_limit_primary.
  ///
  /// In en, this message translates to:
  /// **'Retry in 30s'**
  String get error_scenario_rate_limit_primary;

  /// No description provided for @error_scenario_rate_limit_secondary.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get error_scenario_rate_limit_secondary;

  /// No description provided for @error_scenario_maintenance_title.
  ///
  /// In en, this message translates to:
  /// **'We\'ll be right back'**
  String get error_scenario_maintenance_title;

  /// No description provided for @error_scenario_maintenance_body.
  ///
  /// In en, this message translates to:
  /// **'The service is undergoing scheduled maintenance. It should resume within 15 minutes.'**
  String get error_scenario_maintenance_body;

  /// No description provided for @error_scenario_maintenance_primary.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get error_scenario_maintenance_primary;

  /// No description provided for @error_scenario_maintenance_secondary.
  ///
  /// In en, this message translates to:
  /// **'Notify me'**
  String get error_scenario_maintenance_secondary;

  /// No description provided for @error_scenario_generic_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_scenario_generic_title;

  /// No description provided for @error_scenario_generic_body.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again in a moment.'**
  String get error_scenario_generic_body;

  /// No description provided for @error_scenario_generic_primary.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get error_scenario_generic_primary;

  /// No description provided for @error_scenario_generic_secondary.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get error_scenario_generic_secondary;

  /// No description provided for @error_scenario_server_http_label.
  ///
  /// In en, this message translates to:
  /// **'Internal Server Error'**
  String get error_scenario_server_http_label;

  /// No description provided for @error_scenario_session_http_label.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get error_scenario_session_http_label;

  /// No description provided for @error_scenario_permission_http_label.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get error_scenario_permission_http_label;

  /// No description provided for @error_scenario_notfound_http_label.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get error_scenario_notfound_http_label;

  /// No description provided for @error_scenario_rate_limit_http_label.
  ///
  /// In en, this message translates to:
  /// **'Too Many Requests'**
  String get error_scenario_rate_limit_http_label;

  /// No description provided for @error_scenario_maintenance_http_label.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get error_scenario_maintenance_http_label;

  /// No description provided for @auth_country_uae.
  ///
  /// In en, this message translates to:
  /// **'UNITED ARAB EMIRATES'**
  String get auth_country_uae;

  /// No description provided for @auth_hero_placeholder.
  ///
  /// In en, this message translates to:
  /// **'HERO  ·  EDITORIAL  FASHION  SHOT'**
  String get auth_hero_placeholder;

  /// No description provided for @auth_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Buy & sell pre-loved\nfashion you\'ll love.'**
  String get auth_welcome_title;

  /// No description provided for @auth_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get auth_get_started;

  /// No description provided for @auth_already_have_account.
  ///
  /// In en, this message translates to:
  /// **'I already have an account · '**
  String get auth_already_have_account;

  /// No description provided for @auth_log_in.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get auth_log_in;

  /// No description provided for @auth_create_account_title.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get auth_create_account_title;

  /// No description provided for @auth_welcome_back_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get auth_welcome_back_title;

  /// No description provided for @auth_create_account_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join thousands buying and selling fashion across the UAE.'**
  String get auth_create_account_subtitle;

  /// No description provided for @auth_welcome_back_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to pick up where you left off.'**
  String get auth_welcome_back_subtitle;

  /// No description provided for @auth_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get auth_sign_up;

  /// No description provided for @auth_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get auth_email_hint;

  /// No description provided for @auth_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get auth_email_invalid;

  /// No description provided for @auth_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password_hint;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_continue_apple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get auth_continue_apple;

  /// No description provided for @auth_continue_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_continue_google;

  /// No description provided for @auth_continue_phone.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get auth_continue_phone;

  /// No description provided for @auth_terms_prefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to Klozy\'s '**
  String get auth_terms_prefix;

  /// No description provided for @auth_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get auth_terms;

  /// No description provided for @auth_terms_and.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get auth_terms_and;

  /// No description provided for @auth_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get auth_privacy_policy;

  /// No description provided for @auth_create_account_button.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get auth_create_account_button;

  /// No description provided for @auth_password_reset_sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent. Check your email.'**
  String get auth_password_reset_sent;

  /// No description provided for @auth_phone_title.
  ///
  /// In en, this message translates to:
  /// **'What\'s your number?'**
  String get auth_phone_title;

  /// No description provided for @auth_phone_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll text you a 6-digit code to confirm it\'s really you.'**
  String get auth_phone_subtitle;

  /// No description provided for @auth_phone_number_hint.
  ///
  /// In en, this message translates to:
  /// **'50 123 4567'**
  String get auth_phone_number_hint;

  /// No description provided for @auth_phone_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Standard message rates may apply. Your number is never shown publicly.'**
  String get auth_phone_disclaimer;

  /// No description provided for @auth_send_code.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get auth_send_code;

  /// No description provided for @auth_enter_code_title.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get auth_enter_code_title;

  /// No description provided for @auth_code_sent_to.
  ///
  /// In en, this message translates to:
  /// **'Sent to '**
  String get auth_code_sent_to;

  /// No description provided for @auth_resend_code_in.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String auth_resend_code_in(String time);

  /// No description provided for @auth_resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get auth_resend_code;

  /// No description provided for @auth_code_spam_hint.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? Check spam. A new code can be requested after the cooldown.'**
  String get auth_code_spam_hint;

  /// No description provided for @auth_verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get auth_verify;

  /// No description provided for @auth_new_code_sent.
  ///
  /// In en, this message translates to:
  /// **'A new code was sent.'**
  String get auth_new_code_sent;

  /// No description provided for @onboarding_all_set.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get onboarding_all_set;

  /// No description provided for @onboarding_all_set_named.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set, {name}!'**
  String onboarding_all_set_named(String name);

  /// No description provided for @onboarding_feed_ready_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Klozy feed is ready. Discover, sell and shop the look — all in one place.'**
  String get onboarding_feed_ready_subtitle;

  /// No description provided for @onboarding_start_exploring.
  ///
  /// In en, this message translates to:
  /// **'Start exploring'**
  String get onboarding_start_exploring;

  /// No description provided for @onboarding_complete_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get onboarding_complete_profile_title;

  /// No description provided for @onboarding_complete_profile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how other members will see you on Klozy.'**
  String get onboarding_complete_profile_subtitle;

  /// No description provided for @onboarding_photo_upload_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Photo upload coming soon.'**
  String get onboarding_photo_upload_coming_soon;

  /// No description provided for @onboarding_first_name_label.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get onboarding_first_name_label;

  /// No description provided for @onboarding_first_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Amira'**
  String get onboarding_first_name_hint;

  /// No description provided for @onboarding_last_name_label.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get onboarding_last_name_label;

  /// No description provided for @onboarding_last_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Hassan'**
  String get onboarding_last_name_hint;

  /// No description provided for @onboarding_address_label.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get onboarding_address_label;

  /// No description provided for @onboarding_bio_label.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get onboarding_bio_label;

  /// No description provided for @onboarding_bio_char_count.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String onboarding_bio_char_count(int count, int max);

  /// No description provided for @onboarding_bio_hint.
  ///
  /// In en, this message translates to:
  /// **'Tell buyers a little about your style…'**
  String get onboarding_bio_hint;

  /// No description provided for @onboarding_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboarding_continue;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_personalize_title.
  ///
  /// In en, this message translates to:
  /// **'Personalize your feed'**
  String get onboarding_personalize_title;

  /// No description provided for @onboarding_personalize_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a few things you love so we can fill your feed with the right finds. You can change these anytime.'**
  String get onboarding_personalize_subtitle;

  /// No description provided for @onboarding_categories_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get onboarding_categories_title;

  /// No description provided for @onboarding_categories_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose any'**
  String get onboarding_categories_hint;

  /// No description provided for @onboarding_sizes_title.
  ///
  /// In en, this message translates to:
  /// **'Sizes'**
  String get onboarding_sizes_title;

  /// No description provided for @onboarding_clothing_label.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get onboarding_clothing_label;

  /// No description provided for @onboarding_shoes_label.
  ///
  /// In en, this message translates to:
  /// **'Shoes · {system}'**
  String onboarding_shoes_label(String system);

  /// No description provided for @onboarding_brands_title.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get onboarding_brands_title;

  /// No description provided for @onboarding_brands_hint.
  ///
  /// In en, this message translates to:
  /// **'Follow your favourites'**
  String get onboarding_brands_hint;

  /// No description provided for @onboarding_brands_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search brands'**
  String get onboarding_brands_search_hint;

  /// No description provided for @onboarding_no_brand_matches.
  ///
  /// In en, this message translates to:
  /// **'No brand matches.'**
  String get onboarding_no_brand_matches;

  /// No description provided for @onboarding_show_feed.
  ///
  /// In en, this message translates to:
  /// **'Show my feed'**
  String get onboarding_show_feed;

  /// No description provided for @onboarding_show_feed_count.
  ///
  /// In en, this message translates to:
  /// **'Show my feed · {count} selected'**
  String onboarding_show_feed_count(int count);

  /// No description provided for @onboarding_seller_account_set_up.
  ///
  /// In en, this message translates to:
  /// **'Seller account set up.'**
  String get onboarding_seller_account_set_up;

  /// No description provided for @onboarding_seller_role_title.
  ///
  /// In en, this message translates to:
  /// **'How will you sell?'**
  String get onboarding_seller_role_title;

  /// No description provided for @onboarding_seller_role_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the account that fits you. You can switch or upgrade anytime in Settings.'**
  String get onboarding_seller_role_subtitle;

  /// No description provided for @onboarding_private_seller_title.
  ///
  /// In en, this message translates to:
  /// **'Private seller'**
  String get onboarding_private_seller_title;

  /// No description provided for @onboarding_private_seller_badge.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get onboarding_private_seller_badge;

  /// No description provided for @onboarding_private_seller_description.
  ///
  /// In en, this message translates to:
  /// **'Clearing out your own wardrobe. Get paid straight to your bank account via IBAN — no paperwork.'**
  String get onboarding_private_seller_description;

  /// No description provided for @onboarding_payout_iban_label.
  ///
  /// In en, this message translates to:
  /// **'Payout IBAN'**
  String get onboarding_payout_iban_label;

  /// No description provided for @onboarding_iban_shield_note.
  ///
  /// In en, this message translates to:
  /// **'Encrypted and used only to release your sales payouts. You can change it later in Settings → Payouts.'**
  String get onboarding_iban_shield_note;

  /// No description provided for @onboarding_pro_vendor_title.
  ///
  /// In en, this message translates to:
  /// **'Professional vendor'**
  String get onboarding_pro_vendor_title;

  /// No description provided for @onboarding_pro_vendor_badge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get onboarding_pro_vendor_badge;

  /// No description provided for @onboarding_pro_vendor_description.
  ///
  /// In en, this message translates to:
  /// **'Running a resale business. Bulk listings, a branded shop and analytics. Verified and paid via Stripe (KYB).'**
  String get onboarding_pro_vendor_description;

  /// No description provided for @onboarding_buyer_protection_note.
  ///
  /// In en, this message translates to:
  /// **'Every sale is covered by Klozy buyer protection. Payment is held in escrow and released to you once delivery is confirmed.'**
  String get onboarding_buyer_protection_note;

  /// No description provided for @home_tab_feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get home_tab_feed;

  /// No description provided for @home_tab_wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get home_tab_wishlist;

  /// No description provided for @home_tab_reels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get home_tab_reels;

  /// No description provided for @home_feed_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get home_feed_empty;

  /// No description provided for @home_category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get home_category_all;

  /// No description provided for @home_picked_for_you.
  ///
  /// In en, this message translates to:
  /// **'Picked for you · {categories}'**
  String home_picked_for_you(String categories);

  /// No description provided for @home_product_badge_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get home_product_badge_new;

  /// No description provided for @home_wishlist_empty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get home_wishlist_empty;

  /// No description provided for @home_wishlist_empty_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any item to save it here.'**
  String get home_wishlist_empty_hint;

  /// No description provided for @home_wishlist_saved_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved item} other{{count} saved items}}'**
  String home_wishlist_saved_count(int count);

  /// No description provided for @reels_processing_video.
  ///
  /// In en, this message translates to:
  /// **'Processing video…'**
  String get reels_processing_video;

  /// No description provided for @reels_composer_title.
  ///
  /// In en, this message translates to:
  /// **'New reel'**
  String get reels_composer_title;

  /// No description provided for @reels_compose_details_title.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get reels_compose_details_title;

  /// No description provided for @reels_pick_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Record a short video showing off your pieces, or pick one from your gallery.'**
  String get reels_pick_subtitle;

  /// No description provided for @reels_record_video.
  ///
  /// In en, this message translates to:
  /// **'Record a video'**
  String get reels_record_video;

  /// No description provided for @reels_record_hint.
  ///
  /// In en, this message translates to:
  /// **'Up to 60s · vertical'**
  String get reels_record_hint;

  /// No description provided for @reels_choose_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get reels_choose_from_gallery;

  /// No description provided for @reels_caption_label.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get reels_caption_label;

  /// No description provided for @reels_caption_hint.
  ///
  /// In en, this message translates to:
  /// **'Say something about your look…'**
  String get reels_caption_hint;

  /// No description provided for @reels_tag_items_title.
  ///
  /// In en, this message translates to:
  /// **'Tag items from your shop'**
  String get reels_tag_items_title;

  /// No description provided for @reels_no_listings_to_tag.
  ///
  /// In en, this message translates to:
  /// **'List an item first to tag it in your reels.'**
  String get reels_no_listings_to_tag;

  /// No description provided for @reels_post_reel.
  ///
  /// In en, this message translates to:
  /// **'Post reel'**
  String get reels_post_reel;

  /// No description provided for @reels_post_reel_tagged.
  ///
  /// In en, this message translates to:
  /// **'Post reel · {count} tagged'**
  String reels_post_reel_tagged(int count);

  /// No description provided for @reels_publishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing your reel…'**
  String get reels_publishing;

  /// No description provided for @reels_posted_title.
  ///
  /// In en, this message translates to:
  /// **'Reel posted!'**
  String get reels_posted_title;

  /// No description provided for @reels_posted_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your reel is live in the feed.'**
  String get reels_posted_subtitle;

  /// No description provided for @reels_posted_subtitle_tagged.
  ///
  /// In en, this message translates to:
  /// **'Your reel is live in the feed with {count} tagged {count, plural, one{item} other{items}}.'**
  String reels_posted_subtitle_tagged(int count);

  /// No description provided for @reels_view_in_reels.
  ///
  /// In en, this message translates to:
  /// **'View in Reels'**
  String get reels_view_in_reels;

  /// No description provided for @reels_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reels_done;

  /// No description provided for @reels_delete_reel.
  ///
  /// In en, this message translates to:
  /// **'Delete reel'**
  String get reels_delete_reel;

  /// No description provided for @reels_report_reel.
  ///
  /// In en, this message translates to:
  /// **'Report reel'**
  String get reels_report_reel;

  /// No description provided for @reels_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get reels_share;

  /// No description provided for @reels_shop_the_look_count.
  ///
  /// In en, this message translates to:
  /// **'Shop the look · {count}'**
  String reels_shop_the_look_count(int count);

  /// No description provided for @reels_no_tagged_items.
  ///
  /// In en, this message translates to:
  /// **'No tagged items.'**
  String get reels_no_tagged_items;

  /// No description provided for @reels_shop_the_look.
  ///
  /// In en, this message translates to:
  /// **'Shop the look'**
  String get reels_shop_the_look;

  /// No description provided for @reels_deleted_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Reel deleted.'**
  String get reels_deleted_snackbar;

  /// No description provided for @reels_report_received_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Thanks — report received.'**
  String get reels_report_received_snackbar;

  /// No description provided for @reels_empty.
  ///
  /// In en, this message translates to:
  /// **'No reels yet'**
  String get reels_empty;

  /// No description provided for @reels_link_copied_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard.'**
  String get reels_link_copied_snackbar;

  /// No description provided for @entry_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get entry_sheet_title;

  /// No description provided for @entry_create_reel.
  ///
  /// In en, this message translates to:
  /// **'Create a reel'**
  String get entry_create_reel;

  /// No description provided for @entry_create_reel_sub.
  ///
  /// In en, this message translates to:
  /// **'Share a video of your pieces'**
  String get entry_create_reel_sub;

  /// No description provided for @entry_create_reel_needs_product.
  ///
  /// In en, this message translates to:
  /// **'Add a product first'**
  String get entry_create_reel_needs_product;

  /// No description provided for @entry_list_item.
  ///
  /// In en, this message translates to:
  /// **'List an item for sale'**
  String get entry_list_item;

  /// No description provided for @entry_list_item_sub.
  ///
  /// In en, this message translates to:
  /// **'Photo-first · AI pre-fills your listing'**
  String get entry_list_item_sub;

  /// No description provided for @entry_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get entry_cancel;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search items, brands…'**
  String get search_hint;

  /// No description provided for @search_sort_popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get search_sort_popular;

  /// No description provided for @search_sort_latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get search_sort_latest;

  /// No description provided for @search_sort_price_asc.
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get search_sort_price_asc;

  /// No description provided for @search_sort_price_desc.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get search_sort_price_desc;

  /// No description provided for @search_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get search_filters;

  /// No description provided for @search_filters_with_count.
  ///
  /// In en, this message translates to:
  /// **'Filters · {count}'**
  String search_filters_with_count(int count);

  /// No description provided for @search_browse_categories.
  ///
  /// In en, this message translates to:
  /// **'Browse categories'**
  String get search_browse_categories;

  /// No description provided for @search_popular_now.
  ///
  /// In en, this message translates to:
  /// **'Popular right now'**
  String get search_popular_now;

  /// No description provided for @search_no_results.
  ///
  /// In en, this message translates to:
  /// **'No items match your search.'**
  String get search_no_results;

  /// No description provided for @category_items_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String category_items_count(int count);

  /// No description provided for @category_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get category_empty;

  /// No description provided for @search_result_for_query.
  ///
  /// In en, this message translates to:
  /// **' for “{query}”'**
  String search_result_for_query(String query);

  /// No description provided for @search_result_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String search_result_count(int count);

  /// No description provided for @search_condition_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 condition} other{{count} conditions}}'**
  String search_condition_count(int count);

  /// No description provided for @search_size_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 size} other{{count} sizes}}'**
  String search_size_count(int count);

  /// No description provided for @search_filter_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get search_filter_category;

  /// No description provided for @search_filter_condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get search_filter_condition;

  /// No description provided for @search_filter_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get search_filter_size;

  /// No description provided for @search_filter_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get search_filter_reset;

  /// No description provided for @search_filter_show_results.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get search_filter_show_results;

  /// No description provided for @search_filter_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get search_filter_clear;

  /// No description provided for @search_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get search_filter_all;

  /// No description provided for @product_your_listing.
  ///
  /// In en, this message translates to:
  /// **'Your listing'**
  String get product_your_listing;

  /// No description provided for @product_add_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get product_add_to_cart;

  /// No description provided for @product_buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get product_buy;

  /// No description provided for @product_in_cart_view_cart.
  ///
  /// In en, this message translates to:
  /// **'In cart · View cart'**
  String get product_in_cart_view_cart;

  /// No description provided for @product_edit_listing.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get product_edit_listing;

  /// No description provided for @product_status_sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get product_status_sold;

  /// No description provided for @product_status_reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get product_status_reserved;

  /// No description provided for @product_mark_as_sold.
  ///
  /// In en, this message translates to:
  /// **'Mark as sold'**
  String get product_mark_as_sold;

  /// No description provided for @product_mark_as_available.
  ///
  /// In en, this message translates to:
  /// **'Mark as available'**
  String get product_mark_as_available;

  /// No description provided for @product_delete_listing.
  ///
  /// In en, this message translates to:
  /// **'Delete listing'**
  String get product_delete_listing;

  /// No description provided for @product_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this listing? This can\'t be undone.'**
  String get product_delete_confirm;

  /// No description provided for @product_report_listing.
  ///
  /// In en, this message translates to:
  /// **'Report listing'**
  String get product_report_listing;

  /// No description provided for @product_report_this_listing.
  ///
  /// In en, this message translates to:
  /// **'Report this listing'**
  String get product_report_this_listing;

  /// No description provided for @product_listing_deleted.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted'**
  String get product_listing_deleted;

  /// No description provided for @product_listing_deleted_subtitle.
  ///
  /// In en, this message translates to:
  /// **'This item and its photos have been removed.'**
  String get product_listing_deleted_subtitle;

  /// No description provided for @product_back_to_feed.
  ///
  /// In en, this message translates to:
  /// **'Back to feed'**
  String get product_back_to_feed;

  /// No description provided for @product_added_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart.'**
  String get product_added_to_cart;

  /// No description provided for @product_edit_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Editing a listing is coming soon.'**
  String get product_edit_coming_soon;

  /// No description provided for @product_messaging_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Messaging is coming soon.'**
  String get product_messaging_coming_soon;

  /// No description provided for @product_report_received.
  ///
  /// In en, this message translates to:
  /// **'Thanks — report received.'**
  String get product_report_received;

  /// No description provided for @product_link_copied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard.'**
  String get product_link_copied;

  /// No description provided for @product_stat_views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get product_stat_views;

  /// No description provided for @product_stat_likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get product_stat_likes;

  /// No description provided for @product_stat_posted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get product_stat_posted;

  /// No description provided for @product_stamp_sold.
  ///
  /// In en, this message translates to:
  /// **'SOLD'**
  String get product_stamp_sold;

  /// No description provided for @product_stamp_reserved.
  ///
  /// In en, this message translates to:
  /// **'RESERVED'**
  String get product_stamp_reserved;

  /// No description provided for @product_make_offer.
  ///
  /// In en, this message translates to:
  /// **'Make an offer'**
  String get product_make_offer;

  /// No description provided for @product_currency_dhs.
  ///
  /// In en, this message translates to:
  /// **'Dhs'**
  String get product_currency_dhs;

  /// No description provided for @product_price_amount.
  ///
  /// In en, this message translates to:
  /// **'{amount} Dhs'**
  String product_price_amount(int amount);

  /// No description provided for @sell_sell_in_seconds.
  ///
  /// In en, this message translates to:
  /// **'Sell in seconds'**
  String get sell_sell_in_seconds;

  /// No description provided for @sell_your_photos.
  ///
  /// In en, this message translates to:
  /// **'Your photos'**
  String get sell_your_photos;

  /// No description provided for @sell_add_photos_hint.
  ///
  /// In en, this message translates to:
  /// **'Add up to 8 photos. AI will pre-fill your listing.'**
  String get sell_add_photos_hint;

  /// No description provided for @sell_reorder_hint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. The 1st photo is the cover.'**
  String get sell_reorder_hint;

  /// No description provided for @sell_add_at_least_one_photo.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 photo to continue'**
  String get sell_add_at_least_one_photo;

  /// No description provided for @sell_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sell_continue;

  /// No description provided for @sell_cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get sell_cover;

  /// No description provided for @sell_add_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get sell_add_a_photo;

  /// No description provided for @sell_take_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get sell_take_a_photo;

  /// No description provided for @sell_choose_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get sell_choose_from_gallery;

  /// No description provided for @sell_analysing_your_photos.
  ///
  /// In en, this message translates to:
  /// **'Analysing your photos…'**
  String get sell_analysing_your_photos;

  /// No description provided for @sell_identifying_the_item.
  ///
  /// In en, this message translates to:
  /// **'Identifying the item…'**
  String get sell_identifying_the_item;

  /// No description provided for @sell_generating_title_and_price.
  ///
  /// In en, this message translates to:
  /// **'Generating title and price…'**
  String get sell_generating_title_and_price;

  /// No description provided for @sell_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sell_title;

  /// No description provided for @sell_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sell_price;

  /// No description provided for @sell_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get sell_description;

  /// No description provided for @sell_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get sell_category;

  /// No description provided for @sell_product_details.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get sell_product_details;

  /// No description provided for @sell_subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get sell_subcategory;

  /// No description provided for @sell_choose_subcategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a subcategory'**
  String get sell_choose_subcategory;

  /// No description provided for @sell_brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get sell_brand;

  /// No description provided for @sell_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sell_size;

  /// No description provided for @sell_condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get sell_condition;

  /// No description provided for @sell_suggested_by_ai.
  ///
  /// In en, this message translates to:
  /// **'Suggested by AI'**
  String get sell_suggested_by_ai;

  /// No description provided for @sell_prefilled_by_ai.
  ///
  /// In en, this message translates to:
  /// **'Pre-filled by AI — review and adjust.'**
  String get sell_prefilled_by_ai;

  /// No description provided for @sell_photo_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sell_photo_edit;

  /// No description provided for @sell_list_item.
  ///
  /// In en, this message translates to:
  /// **'List item'**
  String get sell_list_item;

  /// No description provided for @sell_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get sell_optional;

  /// No description provided for @sell_title_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Leather biker jacket'**
  String get sell_title_hint;

  /// No description provided for @sell_price_hint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get sell_price_hint;

  /// No description provided for @sell_price_suffix.
  ///
  /// In en, this message translates to:
  /// **'Dhs'**
  String get sell_price_suffix;

  /// No description provided for @sell_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Add details about condition, fit, material…'**
  String get sell_description_hint;

  /// No description provided for @sell_description_error.
  ///
  /// In en, this message translates to:
  /// **'Add a description so buyers know what they\'re getting'**
  String get sell_description_error;

  /// No description provided for @sell_size_one_size.
  ///
  /// In en, this message translates to:
  /// **'One size'**
  String get sell_size_one_size;

  /// No description provided for @sell_search_brands.
  ///
  /// In en, this message translates to:
  /// **'Search brands'**
  String get sell_search_brands;

  /// No description provided for @sell_use_quoted.
  ///
  /// In en, this message translates to:
  /// **'Use \"{value}\"'**
  String sell_use_quoted(String value);

  /// No description provided for @sell_title_error.
  ///
  /// In en, this message translates to:
  /// **'Add a title (at least 2 characters)'**
  String get sell_title_error;

  /// No description provided for @sell_price_error.
  ///
  /// In en, this message translates to:
  /// **'Enter a price'**
  String get sell_price_error;

  /// No description provided for @sell_category_error.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get sell_category_error;

  /// No description provided for @sell_condition_error.
  ///
  /// In en, this message translates to:
  /// **'Pick a condition'**
  String get sell_condition_error;

  /// No description provided for @sell_youre_live.
  ///
  /// In en, this message translates to:
  /// **'You\'re live!'**
  String get sell_youre_live;

  /// No description provided for @sell_item_visible_to_buyers.
  ///
  /// In en, this message translates to:
  /// **'Your item is now visible to buyers.'**
  String get sell_item_visible_to_buyers;

  /// No description provided for @sell_view_listing.
  ///
  /// In en, this message translates to:
  /// **'View listing'**
  String get sell_view_listing;

  /// No description provided for @sell_back_to_home.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get sell_back_to_home;

  /// No description provided for @sell_create_reel.
  ///
  /// In en, this message translates to:
  /// **'Create a reel'**
  String get sell_create_reel;

  /// No description provided for @cart_title.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart_title;

  /// No description provided for @cart_make_an_offer.
  ///
  /// In en, this message translates to:
  /// **'Make an offer'**
  String get cart_make_an_offer;

  /// No description provided for @cart_offer_sent.
  ///
  /// In en, this message translates to:
  /// **'Offer sent — the seller will get back to you'**
  String get cart_offer_sent;

  /// No description provided for @cart_cancel_offer.
  ///
  /// In en, this message translates to:
  /// **'Cancel offer'**
  String get cart_cancel_offer;

  /// No description provided for @cart_check_out.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get cart_check_out;

  /// No description provided for @cart_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cart_subtotal;

  /// No description provided for @cart_offer_pending.
  ///
  /// In en, this message translates to:
  /// **'Offer pending'**
  String get cart_offer_pending;

  /// No description provided for @cart_offer_accepted.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted'**
  String get cart_offer_accepted;

  /// No description provided for @cart_pro_badge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get cart_pro_badge;

  /// No description provided for @cart_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cart_cancel;

  /// No description provided for @cart_in_bundle.
  ///
  /// In en, this message translates to:
  /// **'In bundle offer'**
  String get cart_in_bundle;

  /// No description provided for @cart_in_accepted_bundle.
  ///
  /// In en, this message translates to:
  /// **'In accepted bundle'**
  String get cart_in_accepted_bundle;

  /// No description provided for @cart_added_after_bundle.
  ///
  /// In en, this message translates to:
  /// **'Added after your bundle offer — not included'**
  String get cart_added_after_bundle;

  /// No description provided for @cart_bundle_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending response'**
  String get cart_bundle_pending;

  /// No description provided for @cart_bundle_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get cart_bundle_accepted;

  /// No description provided for @cart_offer_sent_amount.
  ///
  /// In en, this message translates to:
  /// **'Offer sent · {amount} Dhs'**
  String cart_offer_sent_amount(int amount);

  /// No description provided for @cart_offer_accepted_save.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted · save {amount} Dhs'**
  String cart_offer_accepted_save(int amount);

  /// No description provided for @cart_bundle_was.
  ///
  /// In en, this message translates to:
  /// **'was {amount} Dhs'**
  String cart_bundle_was(int amount);

  /// No description provided for @cart_checkout_amount.
  ///
  /// In en, this message translates to:
  /// **'Check out · {amount} Dhs'**
  String cart_checkout_amount(int amount);

  /// No description provided for @cart_offer_for_all.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Offer for this item} other{Offer for all {count} items}}'**
  String cart_offer_for_all(int count);

  /// No description provided for @cart_bundle_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Bundle offer · 1 item} other{Bundle offer · {count} items}}'**
  String cart_bundle_title(int count);

  /// No description provided for @cart_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cart_empty_title;

  /// No description provided for @cart_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items and they\'ll group by seller here.'**
  String get cart_empty_subtitle;

  /// No description provided for @cart_offer_send.
  ///
  /// In en, this message translates to:
  /// **'Send offer'**
  String get cart_offer_send;

  /// No description provided for @cart_offer_hint_single.
  ///
  /// In en, this message translates to:
  /// **'Your offer'**
  String get cart_offer_hint_single;

  /// No description provided for @cart_offer_hint_multi.
  ///
  /// In en, this message translates to:
  /// **'Your offer for all {count} items'**
  String cart_offer_hint_multi(int count);

  /// No description provided for @cart_offer_error_below_total.
  ///
  /// In en, this message translates to:
  /// **'Offer must be below the total price'**
  String get cart_offer_error_below_total;

  /// No description provided for @cart_offer_chat_note.
  ///
  /// In en, this message translates to:
  /// **'One offer covers everything from this seller. It\'s sent privately in chat — the seller accepts or declines.'**
  String get cart_offer_chat_note;

  /// No description provided for @cart_offer_escrow_note.
  ///
  /// In en, this message translates to:
  /// **'Your payment is held in escrow until you confirm delivery.'**
  String get cart_offer_escrow_note;

  /// No description provided for @cart_currency_dhs.
  ///
  /// In en, this message translates to:
  /// **'Dhs'**
  String get cart_currency_dhs;

  /// No description provided for @cart_price_dhs.
  ///
  /// In en, this message translates to:
  /// **'{amount} Dhs'**
  String cart_price_dhs(int amount);

  /// No description provided for @cart_item_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String cart_item_count(int count);

  /// No description provided for @checkout_buy_more_from.
  ///
  /// In en, this message translates to:
  /// **'Buy more from {name}'**
  String checkout_buy_more_from(String name);

  /// No description provided for @cart_offer_seller_meta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}} · listed at {price} Dhs'**
  String cart_offer_seller_meta(int count, num price);

  /// No description provided for @cart_sellers_summary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 seller · one offer & checkout per seller} other{{count} sellers · one offer & checkout per seller}}'**
  String cart_sellers_summary(int count);

  /// No description provided for @checkout_title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout_title;

  /// No description provided for @checkout_delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get checkout_delivery;

  /// No description provided for @checkout_summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get checkout_summary;

  /// No description provided for @checkout_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get checkout_subtotal;

  /// No description provided for @checkout_shipping_emx.
  ///
  /// In en, this message translates to:
  /// **'Shipping (EMX)'**
  String get checkout_shipping_emx;

  /// No description provided for @checkout_buyer_protection.
  ///
  /// In en, this message translates to:
  /// **'Buyer protection'**
  String get checkout_buyer_protection;

  /// No description provided for @checkout_vat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get checkout_vat;

  /// No description provided for @checkout_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get checkout_total;

  /// No description provided for @checkout_pay_amount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} Dhs'**
  String checkout_pay_amount(int amount);

  /// No description provided for @checkout_amount_dhs.
  ///
  /// In en, this message translates to:
  /// **'{amount} Dhs'**
  String checkout_amount_dhs(int amount);

  /// No description provided for @checkout_encrypted_escrow_note.
  ///
  /// In en, this message translates to:
  /// **'Encrypted checkout · payment held in escrow'**
  String get checkout_encrypted_escrow_note;

  /// No description provided for @checkout_order_placed_title.
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get checkout_order_placed_title;

  /// No description provided for @checkout_order_placed_escrow_message.
  ///
  /// In en, this message translates to:
  /// **'Your payment is held in escrow until you confirm delivery.'**
  String get checkout_order_placed_escrow_message;

  /// No description provided for @checkout_track_order.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get checkout_track_order;

  /// No description provided for @checkout_continue_shopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get checkout_continue_shopping;

  /// No description provided for @checkout_payment_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Payment is unavailable for this order.'**
  String get checkout_payment_unavailable;

  /// No description provided for @checkout_payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get checkout_payment_failed;

  /// No description provided for @orders_my_orders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get orders_my_orders;

  /// No description provided for @orders_buying.
  ///
  /// In en, this message translates to:
  /// **'Buying'**
  String get orders_buying;

  /// No description provided for @orders_selling.
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get orders_selling;

  /// No description provided for @orders_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get orders_in_progress;

  /// No description provided for @orders_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orders_completed;

  /// No description provided for @orders_no_orders_yet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orders_no_orders_yet;

  /// No description provided for @orders_prefix_from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get orders_prefix_from;

  /// No description provided for @orders_prefix_to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get orders_prefix_to;

  /// No description provided for @orders_negotiated.
  ///
  /// In en, this message translates to:
  /// **'Negotiated'**
  String get orders_negotiated;

  /// No description provided for @orders_price_dhs.
  ///
  /// In en, this message translates to:
  /// **'{amount} Dhs'**
  String orders_price_dhs(int amount);

  /// No description provided for @orders_counterpart_meta.
  ///
  /// In en, this message translates to:
  /// **'{prefix} {name}'**
  String orders_counterpart_meta(String prefix, String name);

  /// No description provided for @orders_order_details.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orders_order_details;

  /// No description provided for @orders_tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get orders_tracking;

  /// No description provided for @orders_tracking_updates_empty.
  ///
  /// In en, this message translates to:
  /// **'Tracking updates will appear here.'**
  String get orders_tracking_updates_empty;

  /// No description provided for @orders_emx_door_to_door.
  ///
  /// In en, this message translates to:
  /// **'EMX door-to-door · UAE domestic'**
  String get orders_emx_door_to_door;

  /// No description provided for @orders_emx_tracking.
  ///
  /// In en, this message translates to:
  /// **'EMX tracking'**
  String get orders_emx_tracking;

  /// No description provided for @orders_track_confirmed_label.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get orders_track_confirmed_label;

  /// No description provided for @orders_track_confirmed_sub.
  ///
  /// In en, this message translates to:
  /// **'Seller is preparing your item'**
  String get orders_track_confirmed_sub;

  /// No description provided for @orders_track_shipped_label.
  ///
  /// In en, this message translates to:
  /// **'Shipped with EMX'**
  String get orders_track_shipped_label;

  /// No description provided for @orders_track_shipped_sub.
  ///
  /// In en, this message translates to:
  /// **'Picked up · in transit'**
  String get orders_track_shipped_sub;

  /// No description provided for @orders_track_out_label.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get orders_track_out_label;

  /// No description provided for @orders_track_out_sub.
  ///
  /// In en, this message translates to:
  /// **'Arriving today'**
  String get orders_track_out_sub;

  /// No description provided for @orders_track_delivered_label.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orders_track_delivered_label;

  /// No description provided for @orders_track_delivered_sub.
  ///
  /// In en, this message translates to:
  /// **'Confirm to release payment'**
  String get orders_track_delivered_sub;

  /// No description provided for @orders_carrier_prefix.
  ///
  /// In en, this message translates to:
  /// **'{carrier} · '**
  String orders_carrier_prefix(String carrier);

  /// No description provided for @orders_mark_as_shipped.
  ///
  /// In en, this message translates to:
  /// **'Mark as shipped'**
  String get orders_mark_as_shipped;

  /// No description provided for @orders_download_emx_label.
  ///
  /// In en, this message translates to:
  /// **'Download EMX label'**
  String get orders_download_emx_label;

  /// No description provided for @orders_confirm_receipt.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt'**
  String get orders_confirm_receipt;

  /// No description provided for @orders_leave_a_review.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get orders_leave_a_review;

  /// No description provided for @orders_view_live_tracking.
  ///
  /// In en, this message translates to:
  /// **'View live tracking'**
  String get orders_view_live_tracking;

  /// No description provided for @orders_report_a_problem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get orders_report_a_problem;

  /// No description provided for @orders_cancel_order.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orders_cancel_order;

  /// No description provided for @orders_confirm_receipt_message.
  ///
  /// In en, this message translates to:
  /// **'Confirm you received this order? This releases the payment to the seller.'**
  String get orders_confirm_receipt_message;

  /// No description provided for @orders_cancel_order_message.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order? The payment will be refunded.'**
  String get orders_cancel_order_message;

  /// No description provided for @orders_dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get orders_dialog_cancel;

  /// No description provided for @orders_dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get orders_dialog_confirm;

  /// No description provided for @orders_submit_report.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get orders_submit_report;

  /// No description provided for @orders_report_problem_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe what\'s wrong with your order'**
  String get orders_report_problem_hint;

  /// No description provided for @orders_submit_review.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get orders_submit_review;

  /// No description provided for @orders_review_hint.
  ///
  /// In en, this message translates to:
  /// **'Share details about your experience (optional)'**
  String get orders_review_hint;

  /// No description provided for @orders_messaging_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Messaging is coming soon.'**
  String get orders_messaging_coming_soon;

  /// No description provided for @orders_couldnt_open_link.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link.'**
  String get orders_couldnt_open_link;

  /// No description provided for @orders_accept_return.
  ///
  /// In en, this message translates to:
  /// **'Accept return'**
  String get orders_accept_return;

  /// No description provided for @orders_refuse_return.
  ///
  /// In en, this message translates to:
  /// **'Refuse return'**
  String get orders_refuse_return;

  /// No description provided for @orders_accept_return_message.
  ///
  /// In en, this message translates to:
  /// **'Accept this return? The buyer will be refunded once you receive the item back.'**
  String get orders_accept_return_message;

  /// No description provided for @orders_download_return_label.
  ///
  /// In en, this message translates to:
  /// **'Download return label'**
  String get orders_download_return_label;

  /// No description provided for @orders_refuse_return_title.
  ///
  /// In en, this message translates to:
  /// **'Refuse return'**
  String get orders_refuse_return_title;

  /// No description provided for @orders_refuse_return_hint.
  ///
  /// In en, this message translates to:
  /// **'Explain why you\'re refusing this return'**
  String get orders_refuse_return_hint;

  /// No description provided for @orders_refuse_return_error.
  ///
  /// In en, this message translates to:
  /// **'Add a reason before confirming'**
  String get orders_refuse_return_error;

  /// No description provided for @orders_return_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Return reason'**
  String get orders_return_reason_label;

  /// No description provided for @orders_refuse_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Refuse reason'**
  String get orders_refuse_reason_label;

  /// No description provided for @orders_return_tracking_label.
  ///
  /// In en, this message translates to:
  /// **'Return tracking'**
  String get orders_return_tracking_label;

  /// No description provided for @orders_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orders_status_pending;

  /// No description provided for @orders_status_awaiting_shipment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting shipment'**
  String get orders_status_awaiting_shipment;

  /// No description provided for @orders_status_in_delivery.
  ///
  /// In en, this message translates to:
  /// **'In delivery'**
  String get orders_status_in_delivery;

  /// No description provided for @orders_status_out_for_delivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get orders_status_out_for_delivery;

  /// No description provided for @orders_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orders_status_completed;

  /// No description provided for @orders_status_return_requested.
  ///
  /// In en, this message translates to:
  /// **'Return requested'**
  String get orders_status_return_requested;

  /// No description provided for @orders_status_return_accepted.
  ///
  /// In en, this message translates to:
  /// **'Return accepted'**
  String get orders_status_return_accepted;

  /// No description provided for @orders_status_return_refused.
  ///
  /// In en, this message translates to:
  /// **'Return refused'**
  String get orders_status_return_refused;

  /// No description provided for @orders_status_return_completed.
  ///
  /// In en, this message translates to:
  /// **'Return completed'**
  String get orders_status_return_completed;

  /// No description provided for @orders_status_canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get orders_status_canceled;

  /// No description provided for @orders_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get orders_status_unknown;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @chat_title.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chat_title;

  /// No description provided for @ds_password_strength_weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get ds_password_strength_weak;

  /// No description provided for @ds_password_strength_fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ds_password_strength_fair;

  /// No description provided for @ds_password_strength_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ds_password_strength_good;

  /// No description provided for @ds_password_strength_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get ds_password_strength_strong;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_read_all.
  ///
  /// In en, this message translates to:
  /// **'Read all'**
  String get notifications_read_all;

  /// No description provided for @notifications_empty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get notifications_empty;

  /// No description provided for @notifications_profile_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Profiles are coming soon.'**
  String get notifications_profile_coming_soon;

  /// No description provided for @notifications_time_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notifications_time_just_now;

  /// No description provided for @notifications_time_minutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notifications_time_minutes(int count);

  /// No description provided for @notifications_time_hours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notifications_time_hours(int count);

  /// No description provided for @notifications_time_days.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notifications_time_days(int count);

  /// No description provided for @profile_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profile_edit;

  /// No description provided for @profile_follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get profile_follow;

  /// No description provided for @profile_following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profile_following;

  /// No description provided for @profile_report_user.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get profile_report_user;

  /// No description provided for @profile_reported.
  ///
  /// In en, this message translates to:
  /// **'Thanks — report received.'**
  String get profile_reported;

  /// No description provided for @profile_message_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Messaging is coming soon.'**
  String get profile_message_coming_soon;

  /// No description provided for @profile_edit_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Editing your profile is coming soon.'**
  String get profile_edit_coming_soon;

  /// No description provided for @profile_settings_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Settings are coming soon.'**
  String get profile_settings_coming_soon;

  /// No description provided for @profile_reel_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Reel playback is coming soon.'**
  String get profile_reel_coming_soon;

  /// No description provided for @profile_tab_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get profile_tab_products;

  /// No description provided for @profile_tab_reels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get profile_tab_reels;

  /// No description provided for @profile_tab_reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profile_tab_reviews;

  /// No description provided for @profile_stat_listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get profile_stat_listings;

  /// No description provided for @profile_stat_followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profile_stat_followers;

  /// No description provided for @profile_stat_following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profile_stat_following;

  /// No description provided for @profile_no_listings.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get profile_no_listings;

  /// No description provided for @profile_no_reels.
  ///
  /// In en, this message translates to:
  /// **'No reels yet'**
  String get profile_no_reels;

  /// No description provided for @profile_no_reviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get profile_no_reviews;

  /// No description provided for @profile_reviews_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String profile_reviews_count(int count);

  /// No description provided for @profile_no_followers.
  ///
  /// In en, this message translates to:
  /// **'No followers yet'**
  String get profile_no_followers;

  /// No description provided for @profile_no_following.
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet'**
  String get profile_no_following;

  /// No description provided for @profile_connections_title.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get profile_connections_title;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settings_cancel;

  /// No description provided for @settings_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settings_save;

  /// No description provided for @settings_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get settings_saved;

  /// No description provided for @settings_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get settings_save_failed;

  /// No description provided for @settings_link_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link.'**
  String get settings_link_failed;

  /// No description provided for @settings_section_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settings_section_profile;

  /// No description provided for @settings_section_seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get settings_section_seller;

  /// No description provided for @settings_section_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_section_notifications;

  /// No description provided for @settings_section_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get settings_section_privacy;

  /// No description provided for @settings_section_legal.
  ///
  /// In en, this message translates to:
  /// **'Legal & support'**
  String get settings_section_legal;

  /// No description provided for @settings_section_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_section_account;

  /// No description provided for @settings_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settings_edit_profile;

  /// No description provided for @edit_profile_discard_title.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get edit_profile_discard_title;

  /// No description provided for @edit_profile_discard_body.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave without saving?'**
  String get edit_profile_discard_body;

  /// No description provided for @edit_profile_discard_confirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get edit_profile_discard_confirm;

  /// No description provided for @edit_profile_keep_editing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get edit_profile_keep_editing;

  /// No description provided for @settings_delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get settings_delivery_address;

  /// No description provided for @settings_payout_iban.
  ///
  /// In en, this message translates to:
  /// **'Payout IBAN'**
  String get settings_payout_iban;

  /// No description provided for @settings_seller_stats.
  ///
  /// In en, this message translates to:
  /// **'Seller stats'**
  String get settings_seller_stats;

  /// No description provided for @settings_push_notifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settings_push_notifications;

  /// No description provided for @settings_email_notifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get settings_email_notifications;

  /// No description provided for @settings_blocked_users.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get settings_blocked_users;

  /// No description provided for @settings_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settings_change_password;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_terms;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_support.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get settings_support;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settings_logout;

  /// No description provided for @settings_logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Log out of your account?'**
  String get settings_logout_confirm;

  /// No description provided for @settings_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settings_delete_account;

  /// No description provided for @settings_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account? This cannot be undone.'**
  String get settings_delete_confirm;

  /// No description provided for @settings_change_password_no_email.
  ///
  /// In en, this message translates to:
  /// **'No email is linked to this account.'**
  String get settings_change_password_no_email;

  /// No description provided for @settings_password_reset_sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent. Check your email.'**
  String get settings_password_reset_sent;

  /// No description provided for @settings_new_password.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get settings_new_password;

  /// No description provided for @settings_new_password_hint.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get settings_new_password_hint;

  /// No description provided for @settings_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get settings_confirm_password;

  /// No description provided for @settings_confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get settings_confirm_password_hint;

  /// No description provided for @settings_passwords_no_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get settings_passwords_no_match;

  /// No description provided for @settings_password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get settings_password_too_short;

  /// No description provided for @settings_password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get settings_password_updated;

  /// No description provided for @settings_support_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Support is unavailable right now.'**
  String get settings_support_unavailable;

  /// No description provided for @settings_address_line1.
  ///
  /// In en, this message translates to:
  /// **'Address line'**
  String get settings_address_line1;

  /// No description provided for @settings_address_area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get settings_address_area;

  /// No description provided for @settings_address_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get settings_address_city;

  /// No description provided for @settings_address_emirate.
  ///
  /// In en, this message translates to:
  /// **'Emirate'**
  String get settings_address_emirate;

  /// No description provided for @settings_iban_label.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get settings_iban_label;

  /// No description provided for @settings_iban_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid UAE IBAN (starts with AE)'**
  String get settings_iban_invalid;

  /// No description provided for @settings_iban_note.
  ///
  /// In en, this message translates to:
  /// **'Encrypted and used only to release your sales payouts.'**
  String get settings_iban_note;

  /// No description provided for @settings_no_stats.
  ///
  /// In en, this message translates to:
  /// **'No stats yet.'**
  String get settings_no_stats;

  /// No description provided for @settings_doc_unavailable.
  ///
  /// In en, this message translates to:
  /// **'This document is unavailable right now.'**
  String get settings_doc_unavailable;

  /// No description provided for @settings_no_blocked.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get settings_no_blocked;

  /// No description provided for @settings_unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get settings_unblock;

  /// No description provided for @settings_group_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_group_account;

  /// No description provided for @settings_group_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_group_notifications;

  /// No description provided for @settings_group_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get settings_group_other;

  /// No description provided for @settings_group_links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get settings_group_links;

  /// No description provided for @settings_group_social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get settings_group_social;

  /// No description provided for @settings_group_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settings_group_preferences;

  /// No description provided for @settings_personal_data.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get settings_personal_data;

  /// No description provided for @settings_personal_data_sub.
  ///
  /// In en, this message translates to:
  /// **'Profile, preferences, blocked users'**
  String get settings_personal_data_sub;

  /// No description provided for @settings_personal_information.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get settings_personal_information;

  /// No description provided for @settings_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settings_security;

  /// No description provided for @settings_security_sub.
  ///
  /// In en, this message translates to:
  /// **'Email, password, phone'**
  String get settings_security_sub;

  /// No description provided for @settings_payouts_sub.
  ///
  /// In en, this message translates to:
  /// **'Bank details (IBAN)'**
  String get settings_payouts_sub;

  /// No description provided for @settings_share_app.
  ///
  /// In en, this message translates to:
  /// **'Share the app'**
  String get settings_share_app;

  /// No description provided for @settings_legal_notices.
  ///
  /// In en, this message translates to:
  /// **'Legal notices'**
  String get settings_legal_notices;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get settings_instagram;

  /// No description provided for @settings_instagram_handle.
  ///
  /// In en, this message translates to:
  /// **'@klozy_uae'**
  String get settings_instagram_handle;

  /// No description provided for @settings_clothing_preference.
  ///
  /// In en, this message translates to:
  /// **'Clothing preference'**
  String get settings_clothing_preference;

  /// No description provided for @settings_preferred_size.
  ///
  /// In en, this message translates to:
  /// **'Preferred size'**
  String get settings_preferred_size;

  /// No description provided for @settings_preferred_brands.
  ///
  /// In en, this message translates to:
  /// **'Preferred brands'**
  String get settings_preferred_brands;

  /// No description provided for @settings_change_email.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get settings_change_email;

  /// No description provided for @settings_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get settings_phone_number;

  /// No description provided for @settings_current_email.
  ///
  /// In en, this message translates to:
  /// **'Current email'**
  String get settings_current_email;

  /// No description provided for @settings_new_email.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get settings_new_email;

  /// No description provided for @settings_new_email_hint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get settings_new_email_hint;

  /// No description provided for @settings_change_email_note.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a confirmation link to your new address. The change applies once confirmed.'**
  String get settings_change_email_note;

  /// No description provided for @settings_email_link_sent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation link sent. Check your new inbox to finish.'**
  String get settings_email_link_sent;

  /// No description provided for @settings_current_number.
  ///
  /// In en, this message translates to:
  /// **'Current number'**
  String get settings_current_number;

  /// No description provided for @settings_new_number.
  ///
  /// In en, this message translates to:
  /// **'New number'**
  String get settings_new_number;

  /// No description provided for @settings_new_number_hint.
  ///
  /// In en, this message translates to:
  /// **'50 123 4567'**
  String get settings_new_number_hint;

  /// No description provided for @settings_phone_note.
  ///
  /// In en, this message translates to:
  /// **'We\'ll text a 6-digit code to confirm your new number.'**
  String get settings_phone_note;

  /// No description provided for @settings_phone_updated.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated.'**
  String get settings_phone_updated;

  /// No description provided for @settings_enter_code_for.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {number}'**
  String settings_enter_code_for(String number);

  /// No description provided for @settings_share_message.
  ///
  /// In en, this message translates to:
  /// **'Check out Klozy — buy & sell pre-loved fashion across the UAE. https://klozy.app'**
  String get settings_share_message;

  /// No description provided for @settings_share_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open share. Please try again.'**
  String get settings_share_failed;

  /// No description provided for @onboarding_avatar_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload your photo. Please try again.'**
  String get onboarding_avatar_failed;

  /// No description provided for @sell_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (grams)'**
  String get sell_weight;

  /// No description provided for @sell_weight_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 800'**
  String get sell_weight_hint;

  /// No description provided for @notifications_group_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notifications_group_today;

  /// No description provided for @notifications_group_earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notifications_group_earlier;

  /// No description provided for @checkout_add_address.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery address'**
  String get checkout_add_address;

  /// No description provided for @checkout_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get checkout_add;

  /// No description provided for @checkout_change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get checkout_change;

  /// No description provided for @address_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get address_add_title;

  /// No description provided for @address_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get address_edit_title;

  /// No description provided for @address_label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get address_label;

  /// No description provided for @address_recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient name'**
  String get address_recipient;

  /// No description provided for @address_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get address_phone;

  /// No description provided for @address_empty.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet.'**
  String get address_empty;

  /// No description provided for @address_default.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get address_default;

  /// No description provided for @address_action_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get address_action_edit;

  /// No description provided for @address_action_default.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get address_action_default;

  /// No description provided for @address_action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get address_action_delete;

  /// No description provided for @settings_payouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get settings_payouts;

  /// No description provided for @payouts_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get payouts_pending;

  /// No description provided for @payouts_lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime paid'**
  String get payouts_lifetime;

  /// No description provided for @payouts_empty.
  ///
  /// In en, this message translates to:
  /// **'No payouts yet.'**
  String get payouts_empty;

  /// No description provided for @payouts_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get payouts_status_completed;

  /// No description provided for @payouts_status_reversal.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get payouts_status_reversal;

  /// No description provided for @payouts_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get payouts_status_pending;

  /// No description provided for @profile_block_user.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get profile_block_user;

  /// No description provided for @profile_blocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get profile_blocked;

  /// No description provided for @reels_edit_reel.
  ///
  /// In en, this message translates to:
  /// **'Edit reel'**
  String get reels_edit_reel;

  /// No description provided for @reels_caption_updated.
  ///
  /// In en, this message translates to:
  /// **'Caption updated.'**
  String get reels_caption_updated;

  /// No description provided for @reels_comments_title.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get reels_comments_title;

  /// No description provided for @reels_comments_label.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get reels_comments_label;

  /// No description provided for @reels_no_comments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet — be the first.'**
  String get reels_no_comments;

  /// No description provided for @reels_comment_hint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get reels_comment_hint;

  /// No description provided for @reels_comment_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post your comment.'**
  String get reels_comment_failed;

  /// No description provided for @offers_title.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers_title;

  /// No description provided for @offers_incoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get offers_incoming;

  /// No description provided for @offers_outgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get offers_outgoing;

  /// No description provided for @offers_empty.
  ///
  /// In en, this message translates to:
  /// **'No offers here yet.'**
  String get offers_empty;

  /// No description provided for @offers_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get offers_accept;

  /// No description provided for @offers_decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get offers_decline;

  /// No description provided for @offers_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get offers_status_pending;

  /// No description provided for @offers_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get offers_status_accepted;

  /// No description provided for @offers_status_declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get offers_status_declined;

  /// No description provided for @offers_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get offers_status_cancelled;

  /// No description provided for @legal_pending_title.
  ///
  /// In en, this message translates to:
  /// **'Updated terms'**
  String get legal_pending_title;

  /// No description provided for @legal_pending_message.
  ///
  /// In en, this message translates to:
  /// **'We\'ve updated our legal documents. Please review and accept to continue.'**
  String get legal_pending_message;

  /// No description provided for @legal_accept_continue.
  ///
  /// In en, this message translates to:
  /// **'Accept & continue'**
  String get legal_accept_continue;

  /// No description provided for @connect_title.
  ///
  /// In en, this message translates to:
  /// **'Seller verification'**
  String get connect_title;

  /// No description provided for @connect_start.
  ///
  /// In en, this message translates to:
  /// **'Start verification'**
  String get connect_start;

  /// No description provided for @connect_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue verification'**
  String get connect_continue;

  /// No description provided for @connect_status_complete.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get connect_status_complete;

  /// No description provided for @connect_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Verification in progress'**
  String get connect_status_pending;

  /// No description provided for @connect_status_not_started.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet'**
  String get connect_status_not_started;

  /// No description provided for @connect_explainer.
  ///
  /// In en, this message translates to:
  /// **'Professional vendors are verified and paid via Stripe. Complete the secure Stripe form to enable charges and payouts.'**
  String get connect_explainer;

  /// No description provided for @connect_details_submitted.
  ///
  /// In en, this message translates to:
  /// **'Details submitted'**
  String get connect_details_submitted;

  /// No description provided for @connect_charges_enabled.
  ///
  /// In en, this message translates to:
  /// **'Charges enabled'**
  String get connect_charges_enabled;

  /// No description provided for @connect_payouts_enabled.
  ///
  /// In en, this message translates to:
  /// **'Payouts enabled'**
  String get connect_payouts_enabled;

  /// No description provided for @settings_preferences.
  ///
  /// In en, this message translates to:
  /// **'Feed preferences'**
  String get settings_preferences;

  /// No description provided for @search_filter_brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get search_filter_brand;

  /// No description provided for @search_filter_price.
  ///
  /// In en, this message translates to:
  /// **'Price (Dhs)'**
  String get search_filter_price;

  /// No description provided for @search_price_min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get search_price_min;

  /// No description provided for @search_price_max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get search_price_max;

  /// No description provided for @search_brand_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 brand} other{{count} brands}}'**
  String search_brand_count(int count);

  /// No description provided for @search_price_chip.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} Dhs'**
  String search_price_chip(int min, int max);

  /// No description provided for @settings_iban_current.
  ///
  /// In en, this message translates to:
  /// **'Current IBAN: {masked}'**
  String settings_iban_current(String masked);

  /// No description provided for @auth_or_continue_with.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get auth_or_continue_with;

  /// No description provided for @onboarding_address_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search your address'**
  String get onboarding_address_search_hint;

  /// No description provided for @account_gate_guest_title.
  ///
  /// In en, this message translates to:
  /// **'Create an account or log in to continue'**
  String get account_gate_guest_title;

  /// No description provided for @account_gate_guest_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Klozy to wishlist items, follow sellers and buy pre-loved fashion.'**
  String get account_gate_guest_subtitle;

  /// No description provided for @account_gate_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get account_gate_create_account;

  /// No description provided for @account_gate_log_in.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get account_gate_log_in;

  /// No description provided for @account_gate_incomplete_title.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your profile'**
  String get account_gate_incomplete_title;

  /// No description provided for @account_gate_incomplete_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to unlock all Klozy features.'**
  String get account_gate_incomplete_subtitle;

  /// No description provided for @account_gate_finish_setup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get account_gate_finish_setup;

  /// No description provided for @guest_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Klozy'**
  String get guest_tab_title;

  /// No description provided for @guest_tab_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account or log in to access this section.'**
  String get guest_tab_subtitle;

  /// No description provided for @guest_tab_cta.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get guest_tab_cta;

  /// No description provided for @guest_tab_log_in.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get guest_tab_log_in;

  /// No description provided for @categoryPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get categoryPickerTitle;

  /// No description provided for @categoryPickerBreadcrumbRoot.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get categoryPickerBreadcrumbRoot;

  /// No description provided for @categoryPickerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get categoryPickerLoading;

  /// No description provided for @categoryPickerRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get categoryPickerRetry;

  /// No description provided for @categoryPickerDeepestHint.
  ///
  /// In en, this message translates to:
  /// **'Deepest level — filter by size below.'**
  String get categoryPickerDeepestHint;

  /// No description provided for @categoryPickerAddCategories.
  ///
  /// In en, this message translates to:
  /// **'Add categories'**
  String get categoryPickerAddCategories;

  /// No description provided for @categoryPickerPreferred.
  ///
  /// In en, this message translates to:
  /// **'Preferred categories'**
  String get categoryPickerPreferred;

  /// No description provided for @sellPhotosEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your photos'**
  String get sellPhotosEmptyTitle;

  /// No description provided for @sellPhotosEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with one photo —\nAI writes the title, description and price.'**
  String get sellPhotosEmptySubtitle;

  /// No description provided for @sellPhotosCounter.
  ///
  /// In en, this message translates to:
  /// **'photos'**
  String get sellPhotosCounter;

  /// No description provided for @sellRecapPhotoStripEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sellRecapPhotoStripEdit;

  /// No description provided for @sellRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'* Required fields'**
  String get sellRequiredHint;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @offer_send_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your offer. Please try again.'**
  String get offer_send_failed;

  /// No description provided for @product_see_offer.
  ///
  /// In en, this message translates to:
  /// **'See offer'**
  String get product_see_offer;

  /// No description provided for @chat_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chat_empty_title;

  /// No description provided for @chat_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Message a seller from any product to start chatting.'**
  String get chat_empty_subtitle;

  /// No description provided for @chat_composer_hint.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get chat_composer_hint;

  /// No description provided for @chat_recording.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get chat_recording;

  /// No description provided for @chat_attach_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo & Video'**
  String get chat_attach_photo;

  /// No description provided for @chat_attach_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get chat_attach_camera;

  /// No description provided for @chat_incomplete_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your profile'**
  String get chat_incomplete_profile_title;

  /// No description provided for @chat_incomplete_profile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to start chatting with buyers and sellers.'**
  String get chat_incomplete_profile_subtitle;

  /// No description provided for @chat_incomplete_profile_cta.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get chat_incomplete_profile_cta;

  /// No description provided for @chat_menu_report.
  ///
  /// In en, this message translates to:
  /// **'Report & block'**
  String get chat_menu_report;

  /// No description provided for @chat_menu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get chat_menu_delete;

  /// No description provided for @chat_reply_self.
  ///
  /// In en, this message translates to:
  /// **'Replying to yourself'**
  String get chat_reply_self;

  /// No description provided for @chat_reply_other.
  ///
  /// In en, this message translates to:
  /// **'Replying'**
  String get chat_reply_other;

  /// No description provided for @chat_media_placeholder.
  ///
  /// In en, this message translates to:
  /// **'[media]'**
  String get chat_media_placeholder;

  /// No description provided for @chat_offer_yours.
  ///
  /// In en, this message translates to:
  /// **'Your offer'**
  String get chat_offer_yours;

  /// No description provided for @chat_offer_incoming.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get chat_offer_incoming;

  /// No description provided for @chat_offer_refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get chat_offer_refuse;

  /// No description provided for @chat_offer_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get chat_offer_accept;

  /// No description provided for @chat_offer_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending response…'**
  String get chat_offer_pending;

  /// No description provided for @chat_offer_accepted.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted'**
  String get chat_offer_accepted;

  /// No description provided for @chat_offer_declined.
  ///
  /// In en, this message translates to:
  /// **'Offer declined'**
  String get chat_offer_declined;

  /// No description provided for @chat_message_deleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get chat_message_deleted;

  /// No description provided for @chat_currency.
  ///
  /// In en, this message translates to:
  /// **'Dhs'**
  String get chat_currency;

  /// No description provided for @chat_purchase_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Purchase confirmed'**
  String get chat_purchase_confirmed;

  /// No description provided for @chat_purchase_for.
  ///
  /// In en, this message translates to:
  /// **'for'**
  String get chat_purchase_for;

  /// No description provided for @chat_no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chat_no_messages;

  /// No description provided for @chat_preview_photo.
  ///
  /// In en, this message translates to:
  /// **'📷 Photo'**
  String get chat_preview_photo;

  /// No description provided for @chat_preview_voice.
  ///
  /// In en, this message translates to:
  /// **'🎤 Voice message'**
  String get chat_preview_voice;

  /// No description provided for @chat_preview_offer_sent.
  ///
  /// In en, this message translates to:
  /// **'You sent an offer'**
  String get chat_preview_offer_sent;

  /// No description provided for @chat_preview_offer_new.
  ///
  /// In en, this message translates to:
  /// **'New offer'**
  String get chat_preview_offer_new;

  /// No description provided for @chat_preview_you_prefix.
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get chat_preview_you_prefix;

  /// No description provided for @common_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_try_again;

  /// No description provided for @common_time_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get common_time_just_now;

  /// No description provided for @common_time_minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String common_time_minutes_ago(int count);

  /// No description provided for @common_time_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String common_time_hours_ago(int count);

  /// No description provided for @common_time_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String common_time_days_ago(int count);

  /// No description provided for @error_type_network_title.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get error_type_network_title;

  /// No description provided for @error_type_network_message.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get error_type_network_message;

  /// No description provided for @error_type_timeout_title.
  ///
  /// In en, this message translates to:
  /// **'Took too long'**
  String get error_type_timeout_title;

  /// No description provided for @error_type_timeout_message.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get error_type_timeout_message;

  /// No description provided for @error_type_unauthorized_title.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get error_type_unauthorized_title;

  /// No description provided for @error_type_unauthorized_message.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get error_type_unauthorized_message;

  /// No description provided for @error_type_not_found_title.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get error_type_not_found_title;

  /// No description provided for @error_type_not_found_message.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get error_type_not_found_message;

  /// No description provided for @error_type_server_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_type_server_title;

  /// No description provided for @error_type_server_message.
  ///
  /// In en, this message translates to:
  /// **'Our servers had a hiccup. Please try again.'**
  String get error_type_server_message;

  /// No description provided for @error_type_unknown_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_type_unknown_title;

  /// No description provided for @error_type_unknown_message.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get error_type_unknown_message;

  /// No description provided for @reels_composer_post_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post your reel. Please try again.'**
  String get reels_composer_post_failed;

  /// No description provided for @sell_publish_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t publish your listing. Please try again.'**
  String get sell_publish_failed;

  /// No description provided for @auth_error_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'That email address looks invalid.'**
  String get auth_error_invalid_email;

  /// No description provided for @auth_error_user_disabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get auth_error_user_disabled;

  /// No description provided for @auth_error_wrong_credentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get auth_error_wrong_credentials;

  /// No description provided for @auth_error_email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email.'**
  String get auth_error_email_already_in_use;

  /// No description provided for @auth_error_weak_password.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password (at least 8 characters).'**
  String get auth_error_weak_password;

  /// No description provided for @auth_error_operation_not_allowed.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not enabled.'**
  String get auth_error_operation_not_allowed;

  /// No description provided for @auth_error_requires_recent_login.
  ///
  /// In en, this message translates to:
  /// **'For your security, please log out and sign in again before changing this.'**
  String get auth_error_requires_recent_login;

  /// No description provided for @auth_error_too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get auth_error_too_many_requests;

  /// No description provided for @auth_error_network_request_failed.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get auth_error_network_request_failed;

  /// No description provided for @auth_error_invalid_phone_number.
  ///
  /// In en, this message translates to:
  /// **'That phone number looks invalid.'**
  String get auth_error_invalid_phone_number;

  /// No description provided for @auth_error_invalid_verification_code.
  ///
  /// In en, this message translates to:
  /// **'That code is incorrect.'**
  String get auth_error_invalid_verification_code;

  /// No description provided for @auth_error_session_expired.
  ///
  /// In en, this message translates to:
  /// **'The code expired. Request a new one.'**
  String get auth_error_session_expired;

  /// No description provided for @auth_error_phone_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'That number is already linked to another account.'**
  String get auth_error_phone_already_in_use;

  /// No description provided for @auth_error_phone_verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Phone verification failed. Please try again.'**
  String get auth_error_phone_verification_failed;

  /// No description provided for @auth_error_google_sign_in_failed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get auth_error_google_sign_in_failed;

  /// No description provided for @auth_error_sign_in_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in cancelled.'**
  String get auth_error_sign_in_cancelled;

  /// No description provided for @auth_error_apple_sign_in_failed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed. Please try again.'**
  String get auth_error_apple_sign_in_failed;

  /// No description provided for @auth_error_reauth_required_email.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to change your email.'**
  String get auth_error_reauth_required_email;

  /// No description provided for @auth_error_reauth_required_password.
  ///
  /// In en, this message translates to:
  /// **'For your security, please sign in again before changing your password.'**
  String get auth_error_reauth_required_password;

  /// No description provided for @auth_error_password_too_weak.
  ///
  /// In en, this message translates to:
  /// **'Please choose a stronger password.'**
  String get auth_error_password_too_weak;

  /// No description provided for @auth_error_password_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update your password.'**
  String get auth_error_password_update_failed;

  /// No description provided for @auth_error_reauth_required_phone.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to change your number.'**
  String get auth_error_reauth_required_phone;

  /// No description provided for @auth_error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get auth_error_generic;

  /// No description provided for @address_form_label_hint.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get address_form_label_hint;

  /// No description provided for @sell_size_system_eu.
  ///
  /// In en, this message translates to:
  /// **'EU'**
  String get sell_size_system_eu;

  /// No description provided for @sell_size_system_us.
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get sell_size_system_us;

  /// No description provided for @payout_iban_hint.
  ///
  /// In en, this message translates to:
  /// **'AE07 0331 2345 6789 0123 456'**
  String get payout_iban_hint;

  /// No description provided for @onboarding_seller_role_iban_hint.
  ///
  /// In en, this message translates to:
  /// **'AE00 0000 0000 0000 0000'**
  String get onboarding_seller_role_iban_hint;

  /// No description provided for @chat_media_voice_message.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get chat_media_voice_message;

  /// No description provided for @chat_media_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chat_media_photo;

  /// No description provided for @chat_media_attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get chat_media_attachment;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fa',
    'fil',
    'fr',
    'hi',
    'kk',
    'ml',
    'pt',
    'ru',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fil':
      return AppLocalizationsFil();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'kk':
      return AppLocalizationsKk();
    case 'ml':
      return AppLocalizationsMl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
