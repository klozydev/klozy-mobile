// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Klozy';

  @override
  String get error_page_show_details => 'SHOW DETAILS';

  @override
  String get error_page_hide_details => 'HIDE DETAILS';

  @override
  String get error_page_copy_for_support => 'COPY FOR SUPPORT';

  @override
  String get error_page_need_help => 'NEED HELP?';

  @override
  String get error_page_support_email_label => 'support@klozy.app';

  @override
  String get error_page_source_label => 'SOURCE';

  @override
  String get error_page_stage_label => 'STAGE';

  @override
  String get error_page_request_label => 'REQUEST';

  @override
  String get error_page_message_label => 'MESSAGE';

  @override
  String get error_scenario_network_title => 'You appear to be offline';

  @override
  String get error_scenario_network_body =>
      'We need a connection to sync. Check your Wi-Fi or mobile data and try again.';

  @override
  String get error_scenario_network_primary => 'Retry connection';

  @override
  String get error_scenario_network_secondary => 'Work offline';

  @override
  String get error_scenario_server_title => 'Something went wrong on our side';

  @override
  String get error_scenario_server_body =>
      'The server hit an unexpected error. Our team has been notified. You can retry in a moment.';

  @override
  String get error_scenario_server_primary => 'Try again';

  @override
  String get error_scenario_server_secondary => 'Contact support';

  @override
  String get error_scenario_session_title => 'Please sign in again';

  @override
  String get error_scenario_session_body =>
      'Your session has expired for security. Sign back in to continue.';

  @override
  String get error_scenario_session_primary => 'Sign in';

  @override
  String get error_scenario_session_secondary => 'Cancel';

  @override
  String get error_scenario_permission_title => 'You don\'t have access here';

  @override
  String get error_scenario_permission_body =>
      'This resource is restricted. Ask your manager to grant access.';

  @override
  String get error_scenario_permission_primary => 'Go back';

  @override
  String get error_scenario_permission_secondary => 'Request access';

  @override
  String get error_scenario_notfound_title => 'We couldn\'t find this';

  @override
  String get error_scenario_notfound_body =>
      'It may have been deleted or moved.';

  @override
  String get error_scenario_notfound_primary => 'Go back';

  @override
  String get error_scenario_notfound_secondary => 'Refresh';

  @override
  String get error_scenario_rate_limit_title => 'Slow down a moment';

  @override
  String get error_scenario_rate_limit_body =>
      'You\'ve made too many requests in a short time. Take a short break — you can retry in 30 seconds.';

  @override
  String get error_scenario_rate_limit_primary => 'Retry in 30s';

  @override
  String get error_scenario_rate_limit_secondary => 'Cancel';

  @override
  String get error_scenario_maintenance_title => 'We\'ll be right back';

  @override
  String get error_scenario_maintenance_body =>
      'The service is undergoing scheduled maintenance. It should resume within 15 minutes.';

  @override
  String get error_scenario_maintenance_primary => 'Check status';

  @override
  String get error_scenario_maintenance_secondary => 'Notify me';

  @override
  String get error_scenario_generic_title => 'Something went wrong';

  @override
  String get error_scenario_generic_body =>
      'An unexpected error occurred. Please try again in a moment.';

  @override
  String get error_scenario_generic_primary => 'Try again';

  @override
  String get error_scenario_generic_secondary => 'Cancel';

  @override
  String get error_scenario_server_http_label => 'Internal Server Error';

  @override
  String get error_scenario_session_http_label => 'Session Expired';

  @override
  String get error_scenario_permission_http_label => 'Forbidden';

  @override
  String get error_scenario_notfound_http_label => 'Not Found';

  @override
  String get error_scenario_rate_limit_http_label => 'Too Many Requests';

  @override
  String get error_scenario_maintenance_http_label => 'Maintenance';

  @override
  String get auth_country_uae => 'UNITED ARAB EMIRATES';

  @override
  String get auth_welcome_title =>
      'Buy & sell pre-loved\nfashion you\'ll love.';

  @override
  String get auth_get_started => 'Get started';

  @override
  String get auth_already_have_account => 'I already have an account · ';

  @override
  String get auth_log_in => 'Log in';

  @override
  String get auth_create_account_title => 'Create your account';

  @override
  String get auth_welcome_back_title => 'Welcome back';

  @override
  String get auth_create_account_subtitle =>
      'Join thousands buying and selling fashion across the UAE.';

  @override
  String get auth_welcome_back_subtitle =>
      'Log in to pick up where you left off.';

  @override
  String get auth_sign_up => 'Sign up';

  @override
  String get auth_email_hint => 'Email address';

  @override
  String get auth_email_invalid => 'Enter a valid email address';

  @override
  String get auth_password_hint => 'Password';

  @override
  String get auth_forgot_password => 'Forgot password?';

  @override
  String get auth_continue_apple => 'Continue with Apple';

  @override
  String get auth_continue_google => 'Continue with Google';

  @override
  String get auth_continue_phone => 'Continue with phone';

  @override
  String get auth_terms_prefix => 'By continuing you agree to Klozy\'s ';

  @override
  String get auth_terms => 'Terms';

  @override
  String get auth_terms_and => ' & ';

  @override
  String get auth_privacy_policy => 'Privacy Policy';

  @override
  String get auth_create_account_button => 'Create account';

  @override
  String get auth_password_reset_sent =>
      'Password reset link sent. Check your email.';

  @override
  String get auth_phone_title => 'What\'s your number?';

  @override
  String get auth_phone_subtitle =>
      'We\'ll text you a 6-digit code to confirm it\'s really you.';

  @override
  String get auth_phone_number_hint => '50 123 4567';

  @override
  String get auth_phone_disclaimer =>
      'Standard message rates may apply. Your number is never shown publicly.';

  @override
  String get auth_send_code => 'Send code';

  @override
  String get auth_enter_code_title => 'Enter the code';

  @override
  String get auth_code_sent_to => 'Sent to ';

  @override
  String auth_resend_code_in(String time) {
    return 'Resend code in $time';
  }

  @override
  String get auth_resend_code => 'Resend code';

  @override
  String get auth_code_spam_hint =>
      'Didn\'t get it? Check spam. A new code can be requested after the cooldown.';

  @override
  String get auth_verify => 'Verify';

  @override
  String get auth_new_code_sent => 'A new code was sent.';

  @override
  String get onboarding_all_set => 'You\'re all set!';

  @override
  String onboarding_all_set_named(String name) {
    return 'You\'re all set, $name!';
  }

  @override
  String get onboarding_feed_ready_subtitle =>
      'Your Klozy feed is ready. Discover, sell and shop the look — all in one place.';

  @override
  String get onboarding_start_exploring => 'Start exploring';

  @override
  String get onboarding_complete_profile_title => 'Complete your profile';

  @override
  String get onboarding_complete_profile_subtitle =>
      'This is how other members will see you on Klozy.';

  @override
  String get onboarding_photo_upload_coming_soon => 'Photo upload coming soon.';

  @override
  String get onboarding_first_name_label => 'First name';

  @override
  String get onboarding_first_name_hint => 'Amira';

  @override
  String get onboarding_last_name_label => 'Last name';

  @override
  String get onboarding_last_name_hint => 'Hassan';

  @override
  String get onboarding_address_label => 'Address';

  @override
  String get onboarding_bio_label => 'Bio';

  @override
  String onboarding_bio_char_count(int count, int max) {
    return '$count/$max';
  }

  @override
  String get onboarding_bio_hint => 'Tell buyers a little about your style…';

  @override
  String get onboarding_continue => 'Continue';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_personalize_title => 'Personalize your feed';

  @override
  String get onboarding_personalize_subtitle =>
      'Pick a few things you love so we can fill your feed with the right finds. You can change these anytime.';

  @override
  String get onboarding_categories_title => 'Categories';

  @override
  String get onboarding_categories_hint => 'Choose any';

  @override
  String get onboarding_sizes_title => 'Sizes';

  @override
  String get onboarding_clothing_label => 'Clothing';

  @override
  String onboarding_shoes_label(String system) {
    return 'Shoes · $system';
  }

  @override
  String get onboarding_brands_title => 'Brands';

  @override
  String get onboarding_brands_hint => 'Follow your favourites';

  @override
  String get onboarding_brands_search_hint => 'Search brands';

  @override
  String get onboarding_no_brand_matches => 'No brand matches.';

  @override
  String get onboarding_show_feed => 'Show my feed';

  @override
  String onboarding_show_feed_count(int count) {
    return 'Show my feed · $count selected';
  }

  @override
  String get onboarding_seller_account_set_up => 'Seller account set up.';

  @override
  String get onboarding_seller_role_title => 'How will you sell?';

  @override
  String get onboarding_seller_role_subtitle =>
      'Pick the account that fits you. You can switch or upgrade anytime in Settings.';

  @override
  String get onboarding_private_seller_title => 'Private seller';

  @override
  String get onboarding_private_seller_badge => 'Most popular';

  @override
  String get onboarding_private_seller_description =>
      'Clearing out your own wardrobe. Get paid straight to your bank account via IBAN — no paperwork.';

  @override
  String get onboarding_payout_iban_label => 'Payout IBAN';

  @override
  String get onboarding_iban_shield_note =>
      'Encrypted and used only to release your sales payouts. You can change it later in Settings → Payouts.';

  @override
  String get onboarding_pro_vendor_title => 'Professional vendor';

  @override
  String get onboarding_pro_vendor_badge => 'Pro';

  @override
  String get onboarding_pro_vendor_description =>
      'Running a resale business. Bulk listings, a branded shop and analytics. Verified and paid via Stripe (KYB).';

  @override
  String get onboarding_buyer_protection_note =>
      'Every sale is covered by Klozy buyer protection. Payment is held in escrow and released to you once delivery is confirmed.';

  @override
  String get home_tab_feed => 'Feed';

  @override
  String get home_tab_wishlist => 'Wishlist';

  @override
  String get home_tab_reels => 'Reels';

  @override
  String get home_feed_empty => 'Nothing here yet.';

  @override
  String get home_category_all => 'All';

  @override
  String get home_product_badge_new => 'New';

  @override
  String get home_wishlist_empty => 'Your wishlist is empty';

  @override
  String get reels_composer_title => 'New reel';

  @override
  String get reels_pick_title => 'Create a reel';

  @override
  String get reels_pick_subtitle =>
      'Record a short video showing off your pieces, or pick one from your gallery.';

  @override
  String get reels_record_video => 'Record a video';

  @override
  String get reels_choose_from_gallery => 'Choose from gallery';

  @override
  String get reels_caption_hint => 'Say something about your look…';

  @override
  String get reels_tag_items_title => 'Tag items from your shop';

  @override
  String get reels_no_listings_to_tag =>
      'You have no active listings to tag yet.';

  @override
  String get reels_post_reel => 'Post reel';

  @override
  String get reels_posted_title => 'Reel posted!';

  @override
  String get reels_posted_subtitle =>
      'It will appear in Reels once processing finishes.';

  @override
  String get reels_done => 'Done';

  @override
  String get reels_delete_reel => 'Delete reel';

  @override
  String get reels_report_reel => 'Report reel';

  @override
  String get reels_share => 'Share';

  @override
  String reels_shop_the_look_count(int count) {
    return 'Shop the look · $count';
  }

  @override
  String get reels_no_tagged_items => 'No tagged items.';

  @override
  String get reels_shop_the_look => 'Shop the look';

  @override
  String get reels_deleted_snackbar => 'Reel deleted.';

  @override
  String get reels_report_received_snackbar => 'Thanks — report received.';

  @override
  String get reels_empty => 'No reels yet';

  @override
  String get reels_link_copied_snackbar => 'Link copied to clipboard.';

  @override
  String get search_hint => 'Search items, brands…';

  @override
  String get search_sort_popular => 'Popular';

  @override
  String get search_sort_latest => 'Latest';

  @override
  String get search_sort_price_asc => 'Price ↑';

  @override
  String get search_sort_price_desc => 'Price ↓';

  @override
  String get search_filters => 'Filters';

  @override
  String search_filters_with_count(int count) {
    return 'Filters · $count';
  }

  @override
  String get search_browse_categories => 'Browse categories';

  @override
  String get search_popular_now => 'Popular right now';

  @override
  String get search_no_results => 'No results';

  @override
  String search_result_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String search_condition_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conditions',
      one: '1 condition',
    );
    return '$_temp0';
  }

  @override
  String search_size_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sizes',
      one: '1 size',
    );
    return '$_temp0';
  }

  @override
  String get search_filter_category => 'Category';

  @override
  String get search_filter_condition => 'Condition';

  @override
  String get search_filter_size => 'Size';

  @override
  String get search_filter_reset => 'Reset';

  @override
  String get search_filter_show_results => 'Show results';

  @override
  String get product_add_to_cart => 'Add to cart';

  @override
  String get product_buy => 'Buy';

  @override
  String get product_in_cart_view_cart => 'In cart · View cart';

  @override
  String get product_edit_listing => 'Edit listing';

  @override
  String get product_status_sold => 'Sold';

  @override
  String get product_status_reserved => 'Reserved';

  @override
  String get product_mark_as_sold => 'Mark as sold';

  @override
  String get product_mark_as_available => 'Mark as available';

  @override
  String get product_delete_listing => 'Delete listing';

  @override
  String get product_report_listing => 'Report listing';

  @override
  String get product_report_this_listing => 'Report this listing';

  @override
  String get product_listing_deleted => 'Listing deleted';

  @override
  String get product_back_to_feed => 'Back to feed';

  @override
  String get product_added_to_cart => 'Added to cart.';

  @override
  String get product_edit_coming_soon => 'Editing a listing is coming soon.';

  @override
  String get product_messaging_coming_soon => 'Messaging is coming soon.';

  @override
  String get product_report_received => 'Thanks — report received.';

  @override
  String get product_link_copied => 'Link copied to clipboard.';

  @override
  String get product_stat_views => 'Views';

  @override
  String get product_stat_likes => 'Likes';

  @override
  String get product_stat_posted => 'Posted';

  @override
  String get product_stamp_sold => 'SOLD';

  @override
  String get product_stamp_reserved => 'RESERVED';

  @override
  String get product_make_offer => 'Make an offer';

  @override
  String get product_currency_dhs => 'Dhs';

  @override
  String product_price_amount(int amount) {
    return '$amount Dhs';
  }

  @override
  String get sell_sell_in_seconds => 'Sell in seconds';

  @override
  String get sell_your_photos => 'Your photos';

  @override
  String get sell_add_photos_hint =>
      'Add up to 8 photos. AI will pre-fill your listing.';

  @override
  String get sell_continue => 'Continue';

  @override
  String get sell_cover => 'Cover';

  @override
  String get sell_add_a_photo => 'Add a photo';

  @override
  String get sell_take_a_photo => 'Take a photo';

  @override
  String get sell_choose_from_gallery => 'Choose from gallery';

  @override
  String get sell_analysing_your_photos => 'Analysing your photos…';

  @override
  String get sell_identifying_the_item => 'Identifying the item…';

  @override
  String get sell_generating_title_and_price => 'Generating title and price…';

  @override
  String get sell_title => 'Title';

  @override
  String get sell_price => 'Price';

  @override
  String get sell_description => 'Description';

  @override
  String get sell_category => 'Category';

  @override
  String get sell_brand => 'Brand';

  @override
  String get sell_size => 'Size';

  @override
  String get sell_condition => 'Condition';

  @override
  String get sell_suggested_by_ai => 'Suggested by AI';

  @override
  String get sell_list_item => 'List item';

  @override
  String get sell_optional => 'Optional';

  @override
  String get sell_title_hint => 'e.g. Leather biker jacket';

  @override
  String get sell_price_hint => 'AED';

  @override
  String get sell_description_hint =>
      'Add details about condition, fit, material…';

  @override
  String get sell_search_brands => 'Search brands';

  @override
  String sell_use_quoted(String value) {
    return 'Use \"$value\"';
  }

  @override
  String get sell_title_error => 'Add a title (at least 2 characters)';

  @override
  String get sell_price_error => 'Enter a price';

  @override
  String get sell_category_error => 'Pick a category';

  @override
  String get sell_condition_error => 'Pick a condition';

  @override
  String get sell_youre_live => 'You\'re live!';

  @override
  String get sell_item_visible_to_buyers =>
      'Your item is now visible to buyers.';

  @override
  String get sell_view_listing => 'View listing';

  @override
  String get sell_back_to_home => 'Back to home';

  @override
  String get cart_title => 'Cart';

  @override
  String get cart_make_an_offer => 'Make an offer';

  @override
  String get cart_cancel_offer => 'Cancel offer';

  @override
  String get cart_check_out => 'Check out';

  @override
  String get cart_subtotal => 'Subtotal';

  @override
  String get cart_offer_pending => 'Offer pending';

  @override
  String get cart_offer_accepted => 'Offer accepted';

  @override
  String get cart_pro_badge => 'PRO';

  @override
  String get cart_empty_title => 'Your cart is empty';

  @override
  String get cart_empty_subtitle =>
      'Add items and they\'ll group by seller here.';

  @override
  String get cart_offer_send => 'Send offer';

  @override
  String get cart_offer_hint_single => 'Your offer';

  @override
  String cart_offer_hint_multi(int count) {
    return 'Your offer for all $count items';
  }

  @override
  String get cart_offer_error_below_total =>
      'Offer must be below the total price';

  @override
  String get cart_offer_chat_note =>
      'One offer covers everything from this seller. It\'s sent privately in chat — the seller accepts or declines.';

  @override
  String get cart_currency_dhs => 'Dhs';

  @override
  String cart_price_dhs(int amount) {
    return '$amount Dhs';
  }

  @override
  String cart_item_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String cart_sellers_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sellers · one offer & checkout per seller',
      one: '1 seller · one offer & checkout per seller',
    );
    return '$_temp0';
  }

  @override
  String get checkout_title => 'Checkout';

  @override
  String get checkout_delivery => 'Delivery';

  @override
  String get checkout_summary => 'Summary';

  @override
  String get checkout_subtotal => 'Subtotal';

  @override
  String get checkout_shipping_emx => 'Shipping (EMX)';

  @override
  String get checkout_buyer_protection => 'Buyer protection';

  @override
  String get checkout_vat => 'VAT';

  @override
  String get checkout_total => 'Total';

  @override
  String checkout_pay_amount(int amount) {
    return 'Pay $amount Dhs';
  }

  @override
  String checkout_amount_dhs(int amount) {
    return '$amount Dhs';
  }

  @override
  String get checkout_encrypted_escrow_note =>
      'Encrypted checkout · payment held in escrow';

  @override
  String get checkout_order_placed_title => 'Order placed!';

  @override
  String get checkout_order_placed_escrow_message =>
      'Your payment is held in escrow until you confirm delivery.';

  @override
  String get checkout_track_order => 'Track order';

  @override
  String get checkout_continue_shopping => 'Continue shopping';

  @override
  String get checkout_payment_unavailable =>
      'Payment is unavailable for this order.';

  @override
  String get checkout_payment_failed => 'Payment failed. Please try again.';

  @override
  String get checkout_quote_failed =>
      'Couldn\'t update delivery for that address. Please try again.';

  @override
  String get orders_my_orders => 'My orders';

  @override
  String get orders_buying => 'Buying';

  @override
  String get orders_selling => 'Selling';

  @override
  String get orders_in_progress => 'In progress';

  @override
  String get orders_completed => 'Completed';

  @override
  String get orders_no_orders_yet => 'No orders yet';

  @override
  String get orders_prefix_from => 'from';

  @override
  String get orders_prefix_to => 'to';

  @override
  String orders_price_dhs(int amount) {
    return '$amount Dhs';
  }

  @override
  String orders_counterpart_meta(String prefix, String name) {
    return '$prefix $name';
  }

  @override
  String get orders_order_details => 'Order details';

  @override
  String get orders_tracking => 'Tracking';

  @override
  String get orders_tracking_updates_empty =>
      'Tracking updates will appear here.';

  @override
  String get orders_emx_door_to_door => 'EMX door-to-door · UAE domestic';

  @override
  String orders_carrier_prefix(String carrier) {
    return '$carrier · ';
  }

  @override
  String get orders_mark_as_shipped => 'Mark as shipped';

  @override
  String get orders_download_emx_label => 'Download EMX label';

  @override
  String get orders_confirm_receipt => 'Confirm receipt';

  @override
  String get orders_leave_a_review => 'Leave a review';

  @override
  String get orders_view_live_tracking => 'View live tracking';

  @override
  String get orders_report_a_problem => 'Report a problem';

  @override
  String get orders_cancel_order => 'Cancel order';

  @override
  String get orders_confirm_receipt_message =>
      'Confirm you received this order? This releases the payment to the seller.';

  @override
  String get orders_cancel_order_message =>
      'Cancel this order? The payment will be refunded.';

  @override
  String get orders_dialog_cancel => 'Cancel';

  @override
  String get orders_dialog_confirm => 'Confirm';

  @override
  String get orders_submit_report => 'Submit report';

  @override
  String get orders_report_problem_hint =>
      'Describe what\'s wrong with your order';

  @override
  String get orders_submit_review => 'Submit review';

  @override
  String get orders_review_hint =>
      'Share details about your experience (optional)';

  @override
  String get orders_messaging_coming_soon => 'Messaging is coming soon.';

  @override
  String get orders_couldnt_open_link => 'Couldn\'t open the link.';

  @override
  String get orders_status_pending => 'Pending';

  @override
  String get orders_status_awaiting_shipment => 'Awaiting shipment';

  @override
  String get orders_status_in_delivery => 'In delivery';

  @override
  String get orders_status_out_for_delivery => 'Out for delivery';

  @override
  String get orders_status_completed => 'Completed';

  @override
  String get orders_status_return_requested => 'Return requested';

  @override
  String get orders_status_canceled => 'Canceled';

  @override
  String get orders_status_unknown => '—';

  @override
  String get orders_action_failed =>
      'Couldn\'t complete that action. Please try again.';

  @override
  String get offers_action_failed =>
      'Couldn\'t update the offer. Please try again.';

  @override
  String get profile_title => 'Profile';

  @override
  String get chat_title => 'Chat';

  @override
  String get ds_password_strength_weak => 'Weak';

  @override
  String get ds_password_strength_fair => 'Fair';

  @override
  String get ds_password_strength_good => 'Good';

  @override
  String get ds_password_strength_strong => 'Strong';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_read_all => 'Read all';

  @override
  String get notifications_empty => 'You\'re all caught up.';

  @override
  String get notifications_profile_coming_soon => 'Profiles are coming soon.';

  @override
  String get notifications_time_just_now => 'Just now';

  @override
  String notifications_time_minutes(int count) {
    return '${count}m ago';
  }

  @override
  String notifications_time_hours(int count) {
    return '${count}h ago';
  }

  @override
  String notifications_time_days(int count) {
    return '${count}d ago';
  }

  @override
  String get profile_edit => 'Edit profile';

  @override
  String get profile_follow => 'Follow';

  @override
  String get profile_following => 'Following';

  @override
  String get profile_report_user => 'Report user';

  @override
  String get profile_reported => 'Thanks — report received.';

  @override
  String get profile_message_coming_soon => 'Messaging is coming soon.';

  @override
  String get profile_edit_coming_soon => 'Editing your profile is coming soon.';

  @override
  String get profile_settings_coming_soon => 'Settings are coming soon.';

  @override
  String get profile_reel_coming_soon => 'Reel playback is coming soon.';

  @override
  String get profile_tab_products => 'Products';

  @override
  String get profile_tab_reels => 'Reels';

  @override
  String get profile_tab_reviews => 'Reviews';

  @override
  String get profile_stat_listings => 'Listings';

  @override
  String get profile_stat_followers => 'Followers';

  @override
  String get profile_stat_following => 'Following';

  @override
  String get profile_no_listings => 'No listings yet';

  @override
  String get profile_no_reels => 'No reels yet';

  @override
  String get profile_no_reviews => 'No reviews yet';

  @override
  String get profile_no_followers => 'No followers yet';

  @override
  String get profile_no_following => 'Not following anyone yet';

  @override
  String get profile_connections_title => 'Connections';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_cancel => 'Cancel';

  @override
  String get settings_save => 'Save';

  @override
  String get settings_saved => 'Saved.';

  @override
  String get settings_save_failed => 'Couldn\'t save. Please try again.';

  @override
  String get settings_link_failed => 'Couldn\'t open the link.';

  @override
  String get settings_section_profile => 'Profile';

  @override
  String get settings_section_seller => 'Seller';

  @override
  String get settings_section_notifications => 'Notifications';

  @override
  String get settings_section_privacy => 'Privacy & security';

  @override
  String get settings_section_legal => 'Legal & support';

  @override
  String get settings_section_account => 'Account';

  @override
  String get settings_edit_profile => 'Edit profile';

  @override
  String get settings_delivery_address => 'Delivery address';

  @override
  String get settings_payout_iban => 'Payout IBAN';

  @override
  String get settings_seller_stats => 'Seller stats';

  @override
  String get settings_push_notifications => 'Push notifications';

  @override
  String get settings_email_notifications => 'Email notifications';

  @override
  String get settings_blocked_users => 'Blocked users';

  @override
  String get settings_change_password => 'Change password';

  @override
  String get settings_terms => 'Terms of Service';

  @override
  String get settings_privacy => 'Privacy Policy';

  @override
  String get settings_support => 'Help & support';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_logout => 'Log out';

  @override
  String get settings_logout_confirm => 'Log out of your account?';

  @override
  String get settings_delete_account => 'Delete account';

  @override
  String get settings_delete_confirm =>
      'Permanently delete your account? This cannot be undone.';

  @override
  String get settings_change_password_no_email =>
      'No email is linked to this account.';

  @override
  String get settings_password_reset_sent =>
      'Password reset link sent. Check your email.';

  @override
  String get settings_support_unavailable =>
      'Support is unavailable right now.';

  @override
  String get settings_handle => 'Handle';

  @override
  String get settings_address_line1 => 'Address line';

  @override
  String get settings_address_area => 'Area';

  @override
  String get settings_address_city => 'City';

  @override
  String get settings_address_emirate => 'Emirate';

  @override
  String get settings_iban_label => 'IBAN';

  @override
  String get settings_iban_invalid => 'Enter a valid UAE IBAN (starts with AE)';

  @override
  String get settings_iban_note =>
      'Encrypted and used only to release your sales payouts.';

  @override
  String get settings_no_stats => 'No stats yet.';

  @override
  String get settings_doc_unavailable =>
      'This document is unavailable right now.';

  @override
  String get settings_no_blocked => 'You haven\'t blocked anyone.';

  @override
  String get settings_unblock => 'Unblock';

  @override
  String get onboarding_avatar_failed =>
      'Couldn\'t upload your photo. Please try again.';

  @override
  String get sell_weight => 'Weight (grams)';

  @override
  String get sell_weight_hint => 'e.g. 800';

  @override
  String get notifications_group_today => 'Today';

  @override
  String get notifications_group_earlier => 'Earlier';

  @override
  String get checkout_add_address => 'Add a delivery address';

  @override
  String get checkout_add => 'Add';

  @override
  String get checkout_change => 'Change';

  @override
  String get address_add_title => 'Add address';

  @override
  String get address_edit_title => 'Edit address';

  @override
  String get address_label => 'Label';

  @override
  String get address_recipient => 'Recipient name';

  @override
  String get address_phone => 'Phone';

  @override
  String get address_empty => 'No saved addresses yet.';

  @override
  String get address_default => 'DEFAULT';

  @override
  String get address_action_edit => 'Edit';

  @override
  String get address_action_default => 'Set as default';

  @override
  String get address_action_delete => 'Delete';

  @override
  String get settings_payouts => 'Payouts';

  @override
  String get payouts_pending => 'Pending';

  @override
  String get payouts_lifetime => 'Lifetime paid';

  @override
  String get payouts_empty => 'No payouts yet.';

  @override
  String get payouts_status_completed => 'Completed';

  @override
  String get payouts_status_reversal => 'Reversed';

  @override
  String get payouts_status_pending => 'Pending';

  @override
  String get profile_block_user => 'Block user';

  @override
  String get profile_blocked => 'User blocked.';

  @override
  String get reels_edit_reel => 'Edit reel';

  @override
  String get reels_caption_updated => 'Caption updated.';

  @override
  String get reels_comments_title => 'Comments';

  @override
  String get reels_comments_label => 'Comment';

  @override
  String get reels_no_comments => 'No comments yet — be the first.';

  @override
  String get reels_comment_hint => 'Add a comment…';

  @override
  String get reels_comment_failed => 'Couldn\'t post your comment.';

  @override
  String get offers_title => 'Offers';

  @override
  String get offers_incoming => 'Incoming';

  @override
  String get offers_outgoing => 'Outgoing';

  @override
  String get offers_empty => 'No offers here yet.';

  @override
  String get offers_accept => 'Accept';

  @override
  String get offers_decline => 'Decline';

  @override
  String get offers_status_pending => 'Pending';

  @override
  String get offers_status_accepted => 'Accepted';

  @override
  String get offers_status_declined => 'Declined';

  @override
  String get offers_status_cancelled => 'Cancelled';

  @override
  String get legal_pending_title => 'Updated terms';

  @override
  String get legal_pending_message =>
      'We\'ve updated our legal documents. Please review and accept to continue.';

  @override
  String get legal_accept_continue => 'Accept & continue';

  @override
  String get connect_title => 'Seller verification';

  @override
  String get connect_start => 'Start verification';

  @override
  String get connect_continue => 'Continue verification';

  @override
  String get connect_status_complete => 'Verified';

  @override
  String get connect_status_pending => 'Verification in progress';

  @override
  String get connect_status_not_started => 'Not verified yet';

  @override
  String get connect_explainer =>
      'Professional vendors are verified and paid via Stripe. Complete the secure Stripe form to enable charges and payouts.';

  @override
  String get connect_details_submitted => 'Details submitted';

  @override
  String get connect_charges_enabled => 'Charges enabled';

  @override
  String get connect_payouts_enabled => 'Payouts enabled';

  @override
  String get settings_preferences => 'Feed preferences';

  @override
  String get search_filter_brand => 'Brand';

  @override
  String get search_filter_price => 'Price (Dhs)';

  @override
  String get search_price_min => 'Min';

  @override
  String get search_price_max => 'Max';

  @override
  String search_brand_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brands',
      one: '1 brand',
    );
    return '$_temp0';
  }

  @override
  String search_price_chip(int min, int max) {
    return '$min–$max Dhs';
  }

  @override
  String settings_iban_current(String masked) {
    return 'Current IBAN: $masked';
  }

  @override
  String get auth_or_continue_with => 'or continue with';

  @override
  String get onboarding_address_search_hint => 'Search your address';

  @override
  String get account_gate_guest_title =>
      'Create an account or log in to continue';

  @override
  String get account_gate_guest_subtitle =>
      'Join Klozy to wishlist items, follow sellers and buy pre-loved fashion.';

  @override
  String get account_gate_create_account => 'Create an account';

  @override
  String get account_gate_log_in => 'Log in';

  @override
  String get account_gate_incomplete_title => 'Finish setting up your profile';

  @override
  String get account_gate_incomplete_subtitle =>
      'Complete your profile to unlock all Klozy features.';

  @override
  String get account_gate_finish_setup => 'Finish setup';

  @override
  String get guest_tab_title => 'Sign in to Klozy';

  @override
  String get guest_tab_subtitle =>
      'Create an account or log in to access this section.';

  @override
  String get guest_tab_cta => 'Create an account';

  @override
  String get guest_tab_log_in => 'Log in';

  @override
  String get categoryPickerTitle => 'Select category';

  @override
  String get categoryPickerBreadcrumbRoot => 'All categories';

  @override
  String get categoryPickerLoading => 'Loading...';

  @override
  String get categoryPickerRetry => 'Retry';

  @override
  String get categoryPickerAddCategories => 'Add categories';

  @override
  String get categoryPickerPreferred => 'Preferred categories';

  @override
  String get sellPhotosEmptyTitle => 'Add photos';

  @override
  String get sellPhotosEmptySubtitle => 'Take or upload photos of your item';

  @override
  String get sellPhotosCounter => 'photos';

  @override
  String get sellRecapPhotoStripEdit => 'Edit';

  @override
  String get sellRequiredHint => '* Required fields';

  @override
  String get sellSizeSystem => 'Size system';
}
