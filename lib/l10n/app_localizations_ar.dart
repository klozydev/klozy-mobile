// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_name => 'Klozy';

  @override
  String get ds_set_composition_header => 'يشمل هذه المجموعة';

  @override
  String get ds_set_composition_owner_note =>
      'أضف صورة لكل قطعة لطمأنة المشترين والبيع بشكل أسرع.';

  @override
  String get ds_set_composition_buyer_note =>
      'بعض القطع غير مصوّرة. تواصل مع البائع لمزيد من التفاصيل.';

  @override
  String get ds_set_composition_photo => 'صورة';

  @override
  String get ds_set_composition_add => 'إضافة';

  @override
  String get ds_set_composition_no_photo => 'لا توجد صورة';

  @override
  String get ds_search_bar_hint => 'ابحث عن قطعة أو عضو';

  @override
  String get error_page_show_details => 'عرض التفاصيل';

  @override
  String get error_page_hide_details => 'إخفاء التفاصيل';

  @override
  String get error_page_copy_for_support => 'نسخ للدعم';

  @override
  String get error_page_need_help => 'تحتاج مساعدة؟';

  @override
  String get error_page_support_email_label => 'support@klozy.app';

  @override
  String get error_page_source_label => 'المصدر';

  @override
  String get error_page_stage_label => 'المرحلة';

  @override
  String get error_page_request_label => 'الطلب';

  @override
  String get error_page_message_label => 'الرسالة';

  @override
  String get error_scenario_network_title => 'يبدو أنك غير متصل بالإنترنت';

  @override
  String get error_scenario_network_body =>
      'نحتاج إلى اتصال للمزامنة. تحقق من شبكة Wi-Fi أو بيانات الهاتف وحاول مرة أخرى.';

  @override
  String get error_scenario_network_primary => 'إعادة الاتصال';

  @override
  String get error_scenario_network_secondary => 'العمل دون اتصال';

  @override
  String get error_scenario_server_title => 'حدث خطأ من جانبنا';

  @override
  String get error_scenario_server_body =>
      'واجه الخادم خطأً غير متوقع. تم إبلاغ فريقنا. يمكنك المحاولة مجددًا بعد لحظات.';

  @override
  String get error_scenario_server_primary => 'حاول مرة أخرى';

  @override
  String get error_scenario_server_secondary => 'تواصل مع الدعم';

  @override
  String get error_scenario_session_title => 'يرجى تسجيل الدخول مجددًا';

  @override
  String get error_scenario_session_body =>
      'انتهت صلاحية جلستك لأسباب أمنية. سجّل الدخول مرة أخرى للمتابعة.';

  @override
  String get error_scenario_session_primary => 'تسجيل الدخول';

  @override
  String get error_scenario_session_secondary => 'إلغاء';

  @override
  String get error_scenario_permission_title => 'ليس لديك صلاحية الوصول هنا';

  @override
  String get error_scenario_permission_body =>
      'هذا المورد مقيّد. اطلب من مديرك منحك الصلاحية.';

  @override
  String get error_scenario_permission_primary => 'العودة';

  @override
  String get error_scenario_permission_secondary => 'طلب الوصول';

  @override
  String get error_scenario_notfound_title => 'لم نتمكن من العثور على هذا';

  @override
  String get error_scenario_notfound_body => 'ربما تم حذفه أو نقله.';

  @override
  String get error_scenario_notfound_primary => 'العودة';

  @override
  String get error_scenario_notfound_secondary => 'تحديث';

  @override
  String get error_scenario_rate_limit_title => 'تمهّل قليلًا';

  @override
  String get error_scenario_rate_limit_body =>
      'لقد أرسلت طلبات كثيرة في وقت قصير. خذ استراحة قصيرة — يمكنك المحاولة مجددًا خلال 30 ثانية.';

  @override
  String get error_scenario_rate_limit_primary =>
      'إعادة المحاولة خلال 30 ثانية';

  @override
  String get error_scenario_rate_limit_secondary => 'إلغاء';

  @override
  String get error_scenario_maintenance_title => 'سنعود قريبًا';

  @override
  String get error_scenario_maintenance_body =>
      'الخدمة تخضع لصيانة مجدولة. من المفترض أن تُستأنف خلال 15 دقيقة.';

  @override
  String get error_scenario_maintenance_primary => 'التحقق من الحالة';

  @override
  String get error_scenario_maintenance_secondary => 'أبلغني';

  @override
  String get error_scenario_generic_title => 'حدث خطأ ما';

  @override
  String get error_scenario_generic_body =>
      'حدث خطأ غير متوقع. يرجى المحاولة مجددًا بعد لحظات.';

  @override
  String get error_scenario_generic_primary => 'حاول مرة أخرى';

  @override
  String get error_scenario_generic_secondary => 'إلغاء';

  @override
  String get error_scenario_server_http_label => 'خطأ داخلي في الخادم';

  @override
  String get error_scenario_session_http_label => 'انتهت صلاحية الجلسة';

  @override
  String get error_scenario_permission_http_label => 'غير مسموح';

  @override
  String get error_scenario_notfound_http_label => 'غير موجود';

  @override
  String get error_scenario_rate_limit_http_label => 'طلبات كثيرة جدًا';

  @override
  String get error_scenario_maintenance_http_label => 'صيانة';

  @override
  String get auth_country_uae => 'الإمارات العربية المتحدة';

  @override
  String get auth_hero_placeholder => 'HERO  ·  EDITORIAL  FASHION  SHOT';

  @override
  String get auth_welcome_title => 'اشترِ وبِع أزياءً مستعملة\nستحبّها.';

  @override
  String get auth_get_started => 'ابدأ الآن';

  @override
  String get auth_already_have_account => 'لديّ حساب بالفعل · ';

  @override
  String get auth_log_in => 'تسجيل الدخول';

  @override
  String get auth_create_account_title => 'أنشئ حسابك';

  @override
  String get auth_welcome_back_title => 'مرحبًا بعودتك';

  @override
  String get auth_create_account_subtitle =>
      'انضم إلى آلاف المستخدمين الذين يشترون ويبيعون الأزياء في جميع أنحاء الإمارات.';

  @override
  String get auth_welcome_back_subtitle => 'سجّل الدخول لتكمل من حيث توقفت.';

  @override
  String get auth_sign_up => 'إنشاء حساب';

  @override
  String get auth_email_hint => 'البريد الإلكتروني';

  @override
  String get auth_email_invalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get auth_password_hint => 'كلمة المرور';

  @override
  String get auth_forgot_password => 'نسيت كلمة المرور؟';

  @override
  String get auth_continue_apple => 'المتابعة باستخدام Apple';

  @override
  String get auth_continue_google => 'المتابعة باستخدام Google';

  @override
  String get auth_continue_phone => 'المتابعة باستخدام رقم الهاتف';

  @override
  String get auth_terms_prefix => 'بالمتابعة، فإنك توافق على ';

  @override
  String get auth_terms => 'الشروط';

  @override
  String get auth_terms_and => ' و ';

  @override
  String get auth_privacy_policy => 'سياسة الخصوصية';

  @override
  String get auth_create_account_button => 'إنشاء حساب';

  @override
  String get auth_password_reset_sent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور. تحقق من بريدك الإلكتروني.';

  @override
  String get auth_phone_title => 'ما هو رقمك؟';

  @override
  String get auth_phone_subtitle =>
      'سنرسل لك رمزًا من 6 أرقام للتأكد من أنك أنت حقًا.';

  @override
  String get auth_phone_number_hint => '50 123 4567';

  @override
  String get auth_phone_disclaimer =>
      'قد تُطبّق رسوم الرسائل القياسية. لن يظهر رقمك علنًا أبدًا.';

  @override
  String get auth_send_code => 'إرسال الرمز';

  @override
  String get auth_enter_code_title => 'أدخل الرمز';

  @override
  String get auth_code_sent_to => 'أُرسل إلى ';

  @override
  String auth_resend_code_in(String time) {
    return 'إعادة إرسال الرمز خلال $time';
  }

  @override
  String get auth_resend_code => 'إعادة إرسال الرمز';

  @override
  String get auth_code_spam_hint =>
      'لم يصلك؟ تحقق من البريد العشوائي. يمكنك طلب رمز جديد بعد انتهاء المهلة.';

  @override
  String get auth_verify => 'تحقق';

  @override
  String get auth_new_code_sent => 'تم إرسال رمز جديد.';

  @override
  String get onboarding_all_set => 'كل شيء جاهز!';

  @override
  String onboarding_all_set_named(String name) {
    return 'كل شيء جاهز يا $name!';
  }

  @override
  String get onboarding_feed_ready_subtitle =>
      'موجز Klozy الخاص بك جاهز. اكتشف وبِع وتسوّق الإطلالة — كل ذلك في مكان واحد.';

  @override
  String get onboarding_start_exploring => 'ابدأ الاستكشاف';

  @override
  String get onboarding_complete_profile_title => 'أكمل ملفك الشخصي';

  @override
  String get onboarding_complete_profile_subtitle =>
      'هكذا سيراك الأعضاء الآخرون على Klozy.';

  @override
  String get onboarding_photo_upload_coming_soon => 'رفع الصور قريبًا.';

  @override
  String get onboarding_first_name_label => 'الاسم الأول';

  @override
  String get onboarding_first_name_hint => 'أميرة';

  @override
  String get onboarding_last_name_label => 'اسم العائلة';

  @override
  String get onboarding_last_name_hint => 'حسن';

  @override
  String get onboarding_address_label => 'العنوان';

  @override
  String get onboarding_bio_label => 'نبذة تعريفية';

  @override
  String onboarding_bio_char_count(int count, int max) {
    return '$count/$max';
  }

  @override
  String get onboarding_bio_hint => 'أخبر المشترين قليلًا عن أسلوبك…';

  @override
  String get onboarding_continue => 'متابعة';

  @override
  String get onboarding_skip => 'تخطّي';

  @override
  String get onboarding_personalize_title => 'خصّص موجزك';

  @override
  String get onboarding_personalize_subtitle =>
      'اختر بعض الأشياء التي تحبها لنملأ موجزك بالاكتشافات المناسبة. يمكنك تغيير ذلك في أي وقت.';

  @override
  String get onboarding_categories_title => 'الفئات';

  @override
  String get onboarding_categories_hint => 'اختر ما تشاء';

  @override
  String get onboarding_sizes_title => 'المقاسات';

  @override
  String get onboarding_clothing_label => 'الملابس';

  @override
  String onboarding_shoes_label(String system) {
    return 'الأحذية · $system';
  }

  @override
  String get onboarding_brands_title => 'الماركات';

  @override
  String get onboarding_brands_hint => 'تابع ماركاتك المفضلة';

  @override
  String get onboarding_brands_search_hint => 'ابحث عن ماركات';

  @override
  String get onboarding_no_brand_matches => 'لا توجد ماركة مطابقة.';

  @override
  String get onboarding_show_feed => 'اعرض موجزي';

  @override
  String onboarding_show_feed_count(int count) {
    return 'اعرض موجزي · $count محدّد';
  }

  @override
  String get onboarding_seller_account_set_up => 'تم إعداد حساب البائع.';

  @override
  String get onboarding_seller_role_title => 'كيف ستبيع؟';

  @override
  String get onboarding_seller_role_subtitle =>
      'اختر الحساب الذي يناسبك. يمكنك التبديل أو الترقية في أي وقت من الإعدادات.';

  @override
  String get onboarding_private_seller_title => 'بائع خاص';

  @override
  String get onboarding_private_seller_badge => 'الأكثر شيوعًا';

  @override
  String get onboarding_private_seller_description =>
      'تبيع من خزانة ملابسك الخاصة. احصل على أموالك مباشرة في حسابك البنكي عبر IBAN — دون أي أوراق.';

  @override
  String get onboarding_payout_iban_label => 'IBAN للتحويلات';

  @override
  String get onboarding_iban_shield_note =>
      'مشفّر ويُستخدم فقط لتحويل أرباح مبيعاتك. يمكنك تغييره لاحقًا من الإعدادات ← التحويلات.';

  @override
  String get onboarding_pro_vendor_title => 'بائع محترف';

  @override
  String get onboarding_pro_vendor_badge => 'PRO';

  @override
  String get onboarding_pro_vendor_description =>
      'تدير عملًا في إعادة البيع. قوائم بالجملة، متجر بعلامتك التجارية وتحليلات. موثّق ويُدفع عبر Stripe (KYB).';

  @override
  String get onboarding_buyer_protection_note =>
      'كل عملية بيع مشمولة بحماية المشتري من Klozy. يُحتجز الدفع في الضمان ويُحوّل إليك بمجرد تأكيد التسليم.';

  @override
  String get home_tab_feed => 'الموجز';

  @override
  String get home_tab_wishlist => 'المفضلة';

  @override
  String get home_tab_reels => 'المقاطع';

  @override
  String get home_feed_empty => 'لا يوجد شيء هنا بعد.';

  @override
  String get home_category_all => 'الكل';

  @override
  String home_picked_for_you(String categories) {
    return 'مختار لك · $categories';
  }

  @override
  String get home_product_badge_new => 'جديد';

  @override
  String get home_wishlist_empty => 'قائمة مفضلتك فارغة';

  @override
  String get home_wishlist_empty_hint =>
      'اضغط على القلب على أي قطعة لحفظها هنا.';

  @override
  String home_wishlist_saved_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر محفوظ',
      many: '$count عنصرًا محفوظًا',
      few: '$count عناصر محفوظة',
      two: 'عنصران محفوظان',
      one: 'عنصر محفوظ واحد',
      zero: 'لا عناصر محفوظة',
    );
    return '$_temp0';
  }

  @override
  String get reels_processing_video => 'جارٍ معالجة الفيديو…';

  @override
  String get reels_composer_title => 'مقطع جديد';

  @override
  String get reels_compose_details_title => 'إضافة تفاصيل';

  @override
  String get reels_pick_subtitle =>
      'سجّل فيديو قصيرًا تعرض فيه قطعك، أو اختر واحدًا من معرض الصور.';

  @override
  String get reels_record_video => 'تسجيل فيديو';

  @override
  String get reels_record_hint => 'حتى 60 ثانية · رأسي';

  @override
  String get reels_choose_from_gallery => 'اختيار من المعرض';

  @override
  String get reels_caption_label => 'وصف';

  @override
  String get reels_caption_hint => 'قل شيئًا عن إطلالتك…';

  @override
  String get reels_tag_items_title => 'أضف قطعًا من متجرك';

  @override
  String get reels_no_listings_to_tag => 'ليس لديك قوائم نشطة لإضافتها بعد.';

  @override
  String get reels_post_reel => 'نشر المقطع';

  @override
  String reels_post_reel_tagged(int count) {
    return 'نشر المقطع · $count مميّز';
  }

  @override
  String get reels_publishing => 'جارٍ نشر مقطعك…';

  @override
  String get reels_posted_title => 'تم نشر المقطع!';

  @override
  String get reels_posted_subtitle => 'سيظهر في المقاطع بمجرد انتهاء المعالجة.';

  @override
  String reels_posted_subtitle_tagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطعة مميّزة',
      many: '$count قطعةً مميّزةً',
      few: '$count قطع مميّزة',
      two: 'قطعتان مميّزتان',
      one: 'قطعة مميّزة واحدة',
      zero: 'لا قطع مميّزة',
    );
    return 'مقطعك الآن مباشر في الموجز مع $_temp0.';
  }

  @override
  String get reels_view_in_reels => 'عرض في المقاطع';

  @override
  String get reels_done => 'تم';

  @override
  String get reels_delete_reel => 'حذف المقطع';

  @override
  String get reels_report_reel => 'الإبلاغ عن المقطع';

  @override
  String get reels_share => 'مشاركة';

  @override
  String reels_shop_the_look_count(int count) {
    return 'تسوّق الإطلالة · $count';
  }

  @override
  String get reels_no_tagged_items => 'لا توجد قطع مضافة.';

  @override
  String get reels_shop_the_look => 'تسوّق الإطلالة';

  @override
  String get reels_deleted_snackbar => 'تم حذف المقطع.';

  @override
  String get reels_report_received_snackbar => 'شكرًا — تم استلام البلاغ.';

  @override
  String get reels_empty => 'لا توجد مقاطع بعد';

  @override
  String get reels_link_copied_snackbar => 'تم نسخ الرابط إلى الحافظة.';

  @override
  String get entry_sheet_title => 'ماذا تريد أن تفعل؟';

  @override
  String get entry_create_reel => 'إنشاء مقطع';

  @override
  String get entry_create_reel_sub => 'شارك فيديو لقطعك';

  @override
  String get entry_create_reel_needs_product => 'أضف منتجًا أولًا';

  @override
  String get entry_list_item => 'إدراج قطعة للبيع';

  @override
  String get entry_list_item_sub => 'صورة أولًا · الذكاء الاصطناعي يملأ قائمتك';

  @override
  String get entry_cancel => 'إلغاء';

  @override
  String get search_hint => 'ابحث عن قطع وماركات…';

  @override
  String get search_sort_popular => 'الأكثر رواجًا';

  @override
  String get search_sort_latest => 'الأحدث';

  @override
  String get search_sort_price_asc => 'السعر ↑';

  @override
  String get search_sort_price_desc => 'السعر ↓';

  @override
  String get search_filters => 'الفلاتر';

  @override
  String search_filters_with_count(int count) {
    return 'الفلاتر · $count';
  }

  @override
  String get search_browse_categories => 'تصفّح الفئات';

  @override
  String get search_popular_now => 'الأكثر رواجًا الآن';

  @override
  String get search_no_results => 'لا توجد نتائج';

  @override
  String category_items_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطعة',
      many: '$count قطعةً',
      few: '$count قطع',
      two: 'قطعتان',
      one: 'قطعة واحدة',
      zero: 'لا قطع',
    );
    return '$_temp0';
  }

  @override
  String get category_empty => 'لا يوجد شيء هنا بعد.';

  @override
  String search_result_for_query(String query) {
    return ' لـ \"$query\"';
  }

  @override
  String search_result_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String search_condition_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حالة',
      many: '$count حالة',
      few: '$count حالات',
      two: 'حالتان',
      one: 'حالة واحدة',
      zero: 'لا حالات',
    );
    return '$_temp0';
  }

  @override
  String search_size_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقاس',
      many: '$count مقاسًا',
      few: '$count مقاسات',
      two: 'مقاسان',
      one: 'مقاس واحد',
      zero: 'لا مقاسات',
    );
    return '$_temp0';
  }

  @override
  String get search_filter_category => 'الفئة';

  @override
  String get search_filter_condition => 'الحالة';

  @override
  String get search_filter_size => 'المقاس';

  @override
  String get search_filter_reset => 'إعادة تعيين';

  @override
  String get search_filter_show_results => 'عرض النتائج';

  @override
  String get search_filter_clear => 'مسح';

  @override
  String get search_filter_all => 'الكل';

  @override
  String get product_your_listing => 'قائمتك';

  @override
  String get product_add_to_cart => 'أضف إلى السلة';

  @override
  String get product_buy => 'شراء';

  @override
  String get product_in_cart_view_cart => 'في السلة · عرض السلة';

  @override
  String get product_edit_listing => 'تعديل القائمة';

  @override
  String get product_status_sold => 'مُباع';

  @override
  String get product_status_reserved => 'محجوز';

  @override
  String get product_mark_as_sold => 'وضع علامة كمُباع';

  @override
  String get product_mark_as_available => 'وضع علامة كمتوفر';

  @override
  String get product_delete_listing => 'حذف القائمة';

  @override
  String get product_delete_confirm =>
      'حذف هذه القائمة؟ لا يمكن التراجع عن هذا.';

  @override
  String get product_report_listing => 'الإبلاغ عن القائمة';

  @override
  String get product_report_this_listing => 'الإبلاغ عن هذه القائمة';

  @override
  String get product_listing_deleted => 'تم حذف القائمة';

  @override
  String get product_listing_deleted_subtitle => 'تمت إزالة هذه القطعة وصورها.';

  @override
  String get product_back_to_feed => 'العودة إلى الموجز';

  @override
  String get product_added_to_cart => 'تمت الإضافة إلى السلة.';

  @override
  String get product_edit_coming_soon => 'تعديل القائمة قريبًا.';

  @override
  String get product_messaging_coming_soon => 'المراسلة قريبًا.';

  @override
  String get product_report_received => 'شكرًا — تم استلام البلاغ.';

  @override
  String get product_link_copied => 'تم نسخ الرابط إلى الحافظة.';

  @override
  String get product_stat_views => 'المشاهدات';

  @override
  String get product_stat_likes => 'الإعجابات';

  @override
  String get product_stat_posted => 'تاريخ النشر';

  @override
  String get product_stamp_sold => 'مُباع';

  @override
  String get product_stamp_reserved => 'محجوز';

  @override
  String get product_make_offer => 'تقديم عرض';

  @override
  String get product_currency_dhs => 'Dhs';

  @override
  String product_price_amount(int amount) {
    return '$amount ';
  }

  @override
  String get sell_sell_in_seconds => 'بِع في ثوانٍ';

  @override
  String get sell_your_photos => 'صورك';

  @override
  String get sell_add_photos_hint =>
      'أضف حتى 8 صور. سيملأ الذكاء الاصطناعي قائمتك تلقائيًا.';

  @override
  String get sell_reorder_hint =>
      'اسحب لإعادة الترتيب. الصورة الأولى هي الغلاف.';

  @override
  String get sell_add_at_least_one_photo => 'أضف صورة واحدة على الأقل للمتابعة';

  @override
  String get sell_continue => 'متابعة';

  @override
  String get sell_cover => 'الغلاف';

  @override
  String get sell_add_a_photo => 'أضف صورة';

  @override
  String get sell_take_a_photo => 'التقط صورة';

  @override
  String get sell_choose_from_gallery => 'اختيار من المعرض';

  @override
  String get sell_analysing_your_photos => 'جارٍ تحليل صورك…';

  @override
  String get sell_identifying_the_item => 'جارٍ التعرّف على القطعة…';

  @override
  String get sell_generating_title_and_price => 'جارٍ إنشاء العنوان والسعر…';

  @override
  String get sell_title => 'العنوان';

  @override
  String get sell_price => 'السعر';

  @override
  String get sell_description => 'الوصف';

  @override
  String get sell_category => 'الفئة';

  @override
  String get sell_product_details => 'تفاصيل المنتج';

  @override
  String get sell_subcategory => 'الفئة الفرعية';

  @override
  String get sell_choose_subcategory => 'اختر فئة فرعية';

  @override
  String get sell_brand => 'الماركة';

  @override
  String get sell_size => 'المقاس';

  @override
  String get sell_condition => 'الحالة';

  @override
  String get sell_suggested_by_ai => 'مقترح بواسطة الذكاء الاصطناعي';

  @override
  String get sell_prefilled_by_ai =>
      'تم ملؤه بواسطة الذكاء الاصطناعي — راجع وعدّل.';

  @override
  String get sell_photo_edit => 'تعديل';

  @override
  String get sell_list_item => 'إدراج القطعة';

  @override
  String get sell_optional => 'اختياري';

  @override
  String get sell_title_hint => 'مثال: جاكيت جلدي للدراجات';

  @override
  String get sell_price_hint => 'AED';

  @override
  String get sell_price_suffix => 'Dhs';

  @override
  String get sell_description_hint => 'أضف تفاصيل عن الحالة والمقاس والخامة…';

  @override
  String get sell_description_error =>
      'أضف وصفًا حتى يعرف المشترون ما يحصلون عليه';

  @override
  String get sell_size_one_size => 'مقاس موحّد';

  @override
  String get sell_search_brands => 'ابحث عن ماركات';

  @override
  String sell_use_quoted(String value) {
    return 'استخدم \"$value\"';
  }

  @override
  String get sell_title_error => 'أضف عنوانًا (حرفان على الأقل)';

  @override
  String get sell_price_error => 'أدخل سعرًا';

  @override
  String get sell_category_error => 'اختر فئة';

  @override
  String get sell_condition_error => 'اختر حالة';

  @override
  String get sell_youre_live => 'أصبحت قائمتك مباشرة!';

  @override
  String get sell_item_visible_to_buyers => 'أصبحت قطعتك ظاهرة الآن للمشترين.';

  @override
  String get sell_view_listing => 'عرض القائمة';

  @override
  String get sell_back_to_home => 'العودة إلى الرئيسية';

  @override
  String get sell_create_reel => 'إنشاء مقطع';

  @override
  String get cart_title => 'السلة';

  @override
  String get cart_make_an_offer => 'قدّم عرضًا';

  @override
  String get cart_offer_sent => 'تم إرسال العرض — سيرد عليك البائع';

  @override
  String get cart_cancel_offer => 'إلغاء العرض';

  @override
  String get cart_check_out => 'إتمام الشراء';

  @override
  String get cart_subtotal => 'المجموع الفرعي';

  @override
  String get cart_offer_pending => 'العرض قيد الانتظار';

  @override
  String get cart_offer_accepted => 'تم قبول العرض';

  @override
  String get cart_pro_badge => 'PRO';

  @override
  String get cart_cancel => 'إلغاء';

  @override
  String get cart_in_bundle => 'في عرض الحزمة';

  @override
  String get cart_in_accepted_bundle => 'في الحزمة المقبولة';

  @override
  String get cart_added_after_bundle => 'أضيف بعد عرض حزمتك — غير مشمول';

  @override
  String get cart_bundle_pending => 'بانتظار الرد';

  @override
  String get cart_bundle_accepted => 'مقبول';

  @override
  String cart_offer_sent_amount(int amount) {
    return 'تم إرسال العرض · $amount Dhs';
  }

  @override
  String cart_offer_accepted_save(int amount) {
    return 'تم قبول العرض · وفّر $amount Dhs';
  }

  @override
  String cart_bundle_was(int amount) {
    return 'كان $amount Dhs';
  }

  @override
  String cart_checkout_amount(int amount) {
    return 'إتمام الشراء · $amount Dhs';
  }

  @override
  String cart_offer_for_all(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض لجميع $count قطعة',
      many: 'عرض لجميع $count قطعةً',
      few: 'عرض لجميع $count قطع',
      two: 'عرض لهاتين القطعتين',
      one: 'عرض لهذه القطعة',
      zero: 'عرض للقطع',
    );
    return '$_temp0';
  }

  @override
  String cart_bundle_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض حزمة · $count قطعة',
      many: 'عرض حزمة · $count قطعةً',
      few: 'عرض حزمة · $count قطع',
      two: 'عرض حزمة · قطعتان',
      one: 'عرض حزمة · قطعة واحدة',
      zero: 'عرض حزمة · لا قطع',
    );
    return '$_temp0';
  }

  @override
  String get cart_empty_title => 'سلتك فارغة';

  @override
  String get cart_empty_subtitle => 'أضف قطعًا وسيتم تجميعها حسب البائع هنا.';

  @override
  String get cart_offer_send => 'إرسال العرض';

  @override
  String get cart_offer_hint_single => 'عرضك';

  @override
  String cart_offer_hint_multi(int count) {
    return 'عرضك لجميع القطع البالغ عددها $count';
  }

  @override
  String get cart_offer_error_below_total =>
      'يجب أن يكون العرض أقل من السعر الإجمالي';

  @override
  String get cart_offer_chat_note =>
      'عرض واحد يشمل كل شيء من هذا البائع. يُرسَل بشكل خاص في الدردشة — يقبله البائع أو يرفضه.';

  @override
  String get cart_offer_escrow_note =>
      'يُحتجز دفعك في الضمان حتى تؤكد التسليم.';

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
      other: '$count قطعة',
      many: '$count قطعةً',
      few: '$count قطع',
      two: 'قطعتان',
      one: 'قطعة واحدة',
      zero: 'لا قطع',
    );
    return '$_temp0';
  }

  @override
  String checkout_buy_more_from(String name) {
    return 'شراء المزيد من $name';
  }

  @override
  String cart_offer_seller_meta(int count, num price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطعة',
      many: '$count قطعةً',
      few: '$count قطع',
      two: 'قطعتان',
      one: 'قطعة واحدة',
      zero: 'لا قطع',
    );
    return '$_temp0 · السعر المعلن $priceString Dhs';
  }

  @override
  String cart_sellers_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بائع · عرض وإتمام شراء واحد لكل بائع',
      many: '$count بائعًا · عرض وإتمام شراء واحد لكل بائع',
      few: '$count بائعين · عرض وإتمام شراء واحد لكل بائع',
      two: 'بائعان · عرض وإتمام شراء واحد لكل بائع',
      one: 'بائع واحد · عرض وإتمام شراء واحد لكل بائع',
      zero: 'لا بائعين',
    );
    return '$_temp0';
  }

  @override
  String get checkout_title => 'إتمام الشراء';

  @override
  String get checkout_delivery => 'التوصيل';

  @override
  String get checkout_summary => 'الملخّص';

  @override
  String get checkout_subtotal => 'المجموع الفرعي';

  @override
  String get checkout_shipping_emx => 'الشحن (EMX)';

  @override
  String get checkout_buyer_protection => 'حماية المشتري';

  @override
  String get checkout_vat => 'VAT';

  @override
  String get checkout_total => 'الإجمالي';

  @override
  String checkout_pay_amount(int amount) {
    return 'ادفع $amount Dhs';
  }

  @override
  String checkout_amount_dhs(int amount) {
    return '$amount Dhs';
  }

  @override
  String get checkout_encrypted_escrow_note =>
      'إتمام شراء مشفّر · الدفع محتجز في الضمان';

  @override
  String get checkout_order_placed_title => 'تم تقديم الطلب!';

  @override
  String get checkout_order_placed_escrow_message =>
      'يُحتجز دفعك في الضمان حتى تؤكد التسليم.';

  @override
  String get checkout_track_order => 'تتبّع الطلب';

  @override
  String get checkout_continue_shopping => 'متابعة التسوّق';

  @override
  String get checkout_payment_unavailable => 'الدفع غير متاح لهذا الطلب.';

  @override
  String get checkout_payment_failed => 'فشل الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get orders_my_orders => 'طلباتي';

  @override
  String get orders_buying => 'الشراء';

  @override
  String get orders_selling => 'البيع';

  @override
  String get orders_in_progress => 'قيد التنفيذ';

  @override
  String get orders_completed => 'مكتمل';

  @override
  String get orders_no_orders_yet => 'لا توجد طلبات بعد';

  @override
  String get orders_prefix_from => 'من';

  @override
  String get orders_prefix_to => 'إلى';

  @override
  String get orders_negotiated => 'متفاوَض عليه';

  @override
  String orders_price_dhs(int amount) {
    return '$amount Dhs';
  }

  @override
  String orders_counterpart_meta(String prefix, String name) {
    return '$prefix $name';
  }

  @override
  String get orders_order_details => 'تفاصيل الطلب';

  @override
  String get orders_tracking => 'التتبّع';

  @override
  String get orders_tracking_updates_empty => 'ستظهر تحديثات التتبّع هنا.';

  @override
  String get orders_emx_door_to_door =>
      'EMX من الباب إلى الباب · داخل الإمارات';

  @override
  String get orders_emx_tracking => 'تتبّع EMX';

  @override
  String get orders_track_confirmed_label => 'تم تأكيد الطلب';

  @override
  String get orders_track_confirmed_sub => 'البائع يجهّز قطعتك';

  @override
  String get orders_track_shipped_label => 'تم الشحن مع EMX';

  @override
  String get orders_track_shipped_sub => 'تم الاستلام · في الطريق';

  @override
  String get orders_track_out_label => 'خرج للتوصيل';

  @override
  String get orders_track_out_sub => 'سيصل اليوم';

  @override
  String get orders_track_delivered_label => 'تم التوصيل';

  @override
  String get orders_track_delivered_sub => 'أكّد لتحويل الدفع';

  @override
  String orders_carrier_prefix(String carrier) {
    return '$carrier · ';
  }

  @override
  String get orders_mark_as_shipped => 'وضع علامة كمُشحَن';

  @override
  String get orders_download_emx_label => 'تنزيل ملصق EMX';

  @override
  String get orders_confirm_receipt => 'تأكيد الاستلام';

  @override
  String get orders_leave_a_review => 'اترك تقييمًا';

  @override
  String get orders_view_live_tracking => 'عرض التتبّع المباشر';

  @override
  String get orders_report_a_problem => 'الإبلاغ عن مشكلة';

  @override
  String get orders_cancel_order => 'إلغاء الطلب';

  @override
  String get orders_confirm_receipt_message =>
      'هل تؤكد استلامك لهذا الطلب؟ هذا سيحوّل الدفع إلى البائع.';

  @override
  String get orders_cancel_order_message =>
      'هل تريد إلغاء هذا الطلب؟ سيتم استرداد الدفع.';

  @override
  String get orders_dialog_cancel => 'إلغاء';

  @override
  String get orders_dialog_confirm => 'تأكيد';

  @override
  String get orders_submit_report => 'إرسال البلاغ';

  @override
  String get orders_report_problem_hint => 'صِف ما هو الخطأ في طلبك';

  @override
  String get orders_submit_review => 'إرسال التقييم';

  @override
  String get orders_review_hint => 'شارك تفاصيل عن تجربتك (اختياري)';

  @override
  String get orders_messaging_coming_soon => 'المراسلة قريبًا.';

  @override
  String get orders_couldnt_open_link => 'تعذّر فتح الرابط.';

  @override
  String get orders_accept_return => 'قبول الإرجاع';

  @override
  String get orders_refuse_return => 'رفض الإرجاع';

  @override
  String get orders_accept_return_message =>
      'هل تقبل هذا الإرجاع؟ سيُسترد المبلغ للمشتري بعد استلامك القطعة مرة أخرى.';

  @override
  String get orders_download_return_label => 'تنزيل ملصق الإرجاع';

  @override
  String get orders_refuse_return_title => 'رفض الإرجاع';

  @override
  String get orders_refuse_return_hint => 'اشرح سبب رفضك لهذا الإرجاع';

  @override
  String get orders_refuse_return_error => 'أضف سببًا قبل التأكيد';

  @override
  String get orders_return_reason_label => 'سبب الإرجاع';

  @override
  String get orders_refuse_reason_label => 'سبب الرفض';

  @override
  String get orders_return_tracking_label => 'تتبّع الإرجاع';

  @override
  String get orders_status_pending => 'قيد الانتظار';

  @override
  String get orders_status_awaiting_shipment => 'بانتظار الشحن';

  @override
  String get orders_status_in_delivery => 'قيد التوصيل';

  @override
  String get orders_status_out_for_delivery => 'خرج للتوصيل';

  @override
  String get orders_status_completed => 'مكتمل';

  @override
  String get orders_status_return_requested => 'طُلب الإرجاع';

  @override
  String get orders_status_return_accepted => 'تم قبول الإرجاع';

  @override
  String get orders_status_return_refused => 'تم رفض الإرجاع';

  @override
  String get orders_status_return_completed => 'تم إتمام الإرجاع';

  @override
  String get orders_status_canceled => 'ملغى';

  @override
  String get orders_status_unknown => '—';

  @override
  String get profile_title => 'الملف الشخصي';

  @override
  String get chat_title => 'الدردشة';

  @override
  String get ds_password_strength_weak => 'ضعيفة';

  @override
  String get ds_password_strength_fair => 'مقبولة';

  @override
  String get ds_password_strength_good => 'جيدة';

  @override
  String get ds_password_strength_strong => 'قوية';

  @override
  String get notifications_title => 'الإشعارات';

  @override
  String get notifications_read_all => 'تحديد الكل كمقروء';

  @override
  String get notifications_empty => 'لقد اطّلعت على كل شيء.';

  @override
  String get notifications_profile_coming_soon => 'الملفات الشخصية قريبًا.';

  @override
  String get notifications_time_just_now => 'الآن';

  @override
  String notifications_time_minutes(int count) {
    return 'قبل $count د';
  }

  @override
  String notifications_time_hours(int count) {
    return 'قبل $count س';
  }

  @override
  String notifications_time_days(int count) {
    return 'قبل $count ي';
  }

  @override
  String get profile_edit => 'تعديل الملف الشخصي';

  @override
  String get profile_follow => 'متابعة';

  @override
  String get profile_following => 'تتابعه';

  @override
  String get profile_report_user => 'الإبلاغ عن المستخدم';

  @override
  String get profile_reported => 'شكرًا — تم استلام البلاغ.';

  @override
  String get profile_message_coming_soon => 'المراسلة قريبًا.';

  @override
  String get profile_edit_coming_soon => 'تعديل ملفك الشخصي قريبًا.';

  @override
  String get profile_settings_coming_soon => 'الإعدادات قريبًا.';

  @override
  String get profile_reel_coming_soon => 'تشغيل المقاطع قريبًا.';

  @override
  String get profile_tab_products => 'المنتجات';

  @override
  String get profile_tab_reels => 'المقاطع';

  @override
  String get profile_tab_reviews => 'التقييمات';

  @override
  String get profile_stat_listings => 'القوائم';

  @override
  String get profile_stat_followers => 'المتابِعون';

  @override
  String get profile_stat_following => 'يتابع';

  @override
  String get profile_no_listings => 'لا توجد قوائم بعد';

  @override
  String get profile_no_reels => 'لا توجد مقاطع بعد';

  @override
  String get profile_no_reviews => 'لا توجد تقييمات بعد';

  @override
  String profile_reviews_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييم',
      many: '$count تقييمًا',
      few: '$count تقييمات',
      two: 'تقييمان',
      one: 'تقييم واحد',
      zero: 'لا تقييمات',
    );
    return '$_temp0';
  }

  @override
  String get profile_no_followers => 'لا يوجد متابِعون بعد';

  @override
  String get profile_no_following => 'لا يتابع أحدًا بعد';

  @override
  String get profile_connections_title => 'التواصل';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_cancel => 'إلغاء';

  @override
  String get settings_save => 'حفظ';

  @override
  String get settings_saved => 'تم الحفظ.';

  @override
  String get settings_save_failed => 'تعذّر الحفظ. يرجى المحاولة مرة أخرى.';

  @override
  String get settings_link_failed => 'تعذّر فتح الرابط.';

  @override
  String get settings_section_profile => 'الملف الشخصي';

  @override
  String get settings_section_seller => 'البائع';

  @override
  String get settings_section_notifications => 'الإشعارات';

  @override
  String get settings_section_privacy => 'الخصوصية والأمان';

  @override
  String get settings_section_legal => 'الشؤون القانونية والدعم';

  @override
  String get settings_section_account => 'الحساب';

  @override
  String get settings_edit_profile => 'تعديل الملف الشخصي';

  @override
  String get edit_profile_discard_title => 'تجاهل التغييرات؟';

  @override
  String get edit_profile_discard_body =>
      'لديك تغييرات غير محفوظة. هل تريد المغادرة دون حفظ؟';

  @override
  String get edit_profile_discard_confirm => 'تجاهل';

  @override
  String get edit_profile_keep_editing => 'متابعة التعديل';

  @override
  String get settings_delivery_address => 'عنوان التوصيل';

  @override
  String get settings_payout_iban => 'IBAN للتحويلات';

  @override
  String get settings_seller_stats => 'إحصاءات البائع';

  @override
  String get settings_push_notifications => 'الإشعارات الفورية';

  @override
  String get settings_email_notifications => 'إشعارات البريد الإلكتروني';

  @override
  String get settings_blocked_users => 'المستخدمون المحظورون';

  @override
  String get settings_change_password => 'تغيير كلمة المرور';

  @override
  String get settings_terms => 'شروط الخدمة';

  @override
  String get settings_privacy => 'سياسة الخصوصية';

  @override
  String get settings_support => 'المساعدة والدعم';

  @override
  String get settings_version => 'الإصدار';

  @override
  String get settings_logout => 'تسجيل الخروج';

  @override
  String get settings_logout_confirm => 'هل تريد تسجيل الخروج من حسابك؟';

  @override
  String get settings_delete_account => 'حذف الحساب';

  @override
  String get settings_delete_confirm =>
      'هل تريد حذف حسابك نهائيًا؟ لا يمكن التراجع عن هذا.';

  @override
  String get settings_change_password_no_email =>
      'لا يوجد بريد إلكتروني مرتبط بهذا الحساب.';

  @override
  String get settings_password_reset_sent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور. تحقق من بريدك الإلكتروني.';

  @override
  String get settings_new_password => 'كلمة المرور الجديدة';

  @override
  String get settings_new_password_hint => 'كلمة المرور الجديدة';

  @override
  String get settings_confirm_password => 'تأكيد كلمة المرور';

  @override
  String get settings_confirm_password_hint => 'أعد إدخال كلمة المرور';

  @override
  String get settings_passwords_no_match => 'كلمتا المرور غير متطابقتين';

  @override
  String get settings_password_too_short => 'استخدم 8 أحرف على الأقل';

  @override
  String get settings_password_updated => 'تم تحديث كلمة المرور.';

  @override
  String get settings_support_unavailable => 'الدعم غير متاح حاليًا.';

  @override
  String get settings_address_line1 => 'سطر العنوان';

  @override
  String get settings_address_area => 'المنطقة';

  @override
  String get settings_address_city => 'المدينة';

  @override
  String get settings_address_emirate => 'الإمارة';

  @override
  String get settings_iban_label => 'IBAN';

  @override
  String get settings_iban_invalid => 'أدخل IBAN إماراتيًا صحيحًا (يبدأ بـ AE)';

  @override
  String get settings_iban_note => 'مشفّر ويُستخدم فقط لتحويل أرباح مبيعاتك.';

  @override
  String get settings_no_stats => 'لا توجد إحصاءات بعد.';

  @override
  String get settings_doc_unavailable => 'هذا المستند غير متاح حاليًا.';

  @override
  String get settings_no_blocked => 'لم تحظر أحدًا.';

  @override
  String get settings_unblock => 'إلغاء الحظر';

  @override
  String get settings_group_account => 'الحساب';

  @override
  String get settings_group_notifications => 'الإشعارات';

  @override
  String get settings_group_other => 'أخرى';

  @override
  String get settings_group_links => 'الروابط';

  @override
  String get settings_group_social => 'التواصل الاجتماعي';

  @override
  String get settings_group_preferences => 'التفضيلات';

  @override
  String get settings_personal_data => 'البيانات الشخصية';

  @override
  String get settings_personal_data_sub =>
      'الملف الشخصي والتفضيلات والمستخدمون المحظورون';

  @override
  String get settings_personal_information => 'المعلومات الشخصية';

  @override
  String get settings_security => 'الأمان';

  @override
  String get settings_security_sub => 'البريد الإلكتروني وكلمة المرور والهاتف';

  @override
  String get settings_payouts_sub => 'البيانات البنكية (IBAN)';

  @override
  String get settings_share_app => 'مشاركة التطبيق';

  @override
  String get settings_legal_notices => 'الإشعارات القانونية';

  @override
  String get settings_about => 'حول';

  @override
  String get settings_instagram => 'Instagram';

  @override
  String get settings_instagram_handle => '@klozy_uae';

  @override
  String get settings_clothing_preference => 'تفضيل الملابس';

  @override
  String get settings_preferred_size => 'المقاس المفضّل';

  @override
  String get settings_preferred_brands => 'الماركات المفضّلة';

  @override
  String get settings_change_email => 'تغيير البريد الإلكتروني';

  @override
  String get settings_phone_number => 'رقم الهاتف';

  @override
  String get settings_current_email => 'البريد الإلكتروني الحالي';

  @override
  String get settings_new_email => 'البريد الإلكتروني الجديد';

  @override
  String get settings_new_email_hint => 'you@email.com';

  @override
  String get settings_change_email_note =>
      'سنرسل رابط تأكيد إلى عنوانك الجديد. ستُطبَّق التغييرات بعد التأكيد.';

  @override
  String get settings_email_link_sent =>
      'تم إرسال رابط التأكيد. تحقق من صندوق الوارد الجديد للإنهاء.';

  @override
  String get settings_current_number => 'الرقم الحالي';

  @override
  String get settings_new_number => 'الرقم الجديد';

  @override
  String get settings_new_number_hint => '50 123 4567';

  @override
  String get settings_phone_note =>
      'سنرسل لك رمزًا من 6 أرقام لتأكيد رقمك الجديد.';

  @override
  String get settings_phone_updated => 'تم تحديث رقم الهاتف.';

  @override
  String settings_enter_code_for(String number) {
    return 'أدخل الرمز المكوّن من 6 أرقام المُرسَل إلى $number';
  }

  @override
  String get settings_share_message =>
      'اكتشف Klozy — شراء وبيع الأزياء المستعملة في الإمارات. https://klozy.app';

  @override
  String get settings_share_failed => 'تعذّر فتح المشاركة. حاول مرة أخرى.';

  @override
  String get onboarding_avatar_failed =>
      'تعذّر رفع صورتك. يرجى المحاولة مرة أخرى.';

  @override
  String get sell_weight => 'الوزن (بالجرام)';

  @override
  String get sell_weight_hint => 'مثال: 800';

  @override
  String get notifications_group_today => 'اليوم';

  @override
  String get notifications_group_earlier => 'سابقًا';

  @override
  String get checkout_add_address => 'أضف عنوان توصيل';

  @override
  String get checkout_add => 'إضافة';

  @override
  String get checkout_change => 'تغيير';

  @override
  String get address_add_title => 'إضافة عنوان';

  @override
  String get address_edit_title => 'تعديل العنوان';

  @override
  String get address_label => 'التسمية';

  @override
  String get address_recipient => 'اسم المستلم';

  @override
  String get address_phone => 'الهاتف';

  @override
  String get address_empty => 'لا توجد عناوين محفوظة بعد.';

  @override
  String get address_default => 'افتراضي';

  @override
  String get address_action_edit => 'تعديل';

  @override
  String get address_action_default => 'تعيين كافتراضي';

  @override
  String get address_action_delete => 'حذف';

  @override
  String get settings_payouts => 'التحويلات';

  @override
  String get payouts_pending => 'قيد الانتظار';

  @override
  String get payouts_lifetime => 'إجمالي المدفوع';

  @override
  String get payouts_empty => 'لا توجد تحويلات بعد.';

  @override
  String get payouts_status_completed => 'مكتمل';

  @override
  String get payouts_status_reversal => 'معكوس';

  @override
  String get payouts_status_pending => 'قيد الانتظار';

  @override
  String get profile_block_user => 'حظر المستخدم';

  @override
  String get profile_blocked => 'تم حظر المستخدم.';

  @override
  String get reels_edit_reel => 'تعديل المقطع';

  @override
  String get reels_caption_updated => 'تم تحديث الوصف.';

  @override
  String get reels_comments_title => 'التعليقات';

  @override
  String get reels_comments_label => 'تعليق';

  @override
  String get reels_no_comments => 'لا توجد تعليقات بعد — كن أول من يعلّق.';

  @override
  String get reels_comment_hint => 'أضف تعليقًا…';

  @override
  String get reels_comment_failed => 'تعذّر نشر تعليقك.';

  @override
  String get offers_title => 'العروض';

  @override
  String get offers_incoming => 'الواردة';

  @override
  String get offers_outgoing => 'الصادرة';

  @override
  String get offers_empty => 'لا توجد عروض هنا بعد.';

  @override
  String get offers_accept => 'قبول';

  @override
  String get offers_decline => 'رفض';

  @override
  String get offers_status_pending => 'قيد الانتظار';

  @override
  String get offers_status_accepted => 'مقبول';

  @override
  String get offers_status_declined => 'مرفوض';

  @override
  String get offers_status_cancelled => 'ملغى';

  @override
  String get legal_pending_title => 'شروط محدّثة';

  @override
  String get legal_pending_message =>
      'لقد حدّثنا مستنداتنا القانونية. يرجى مراجعتها والموافقة عليها للمتابعة.';

  @override
  String get legal_accept_continue => 'الموافقة والمتابعة';

  @override
  String get connect_title => 'توثيق البائع';

  @override
  String get connect_start => 'بدء التوثيق';

  @override
  String get connect_continue => 'متابعة التوثيق';

  @override
  String get connect_status_complete => 'موثّق';

  @override
  String get connect_status_pending => 'التوثيق قيد التنفيذ';

  @override
  String get connect_status_not_started => 'غير موثّق بعد';

  @override
  String get connect_explainer =>
      'البائعون المحترفون موثّقون ويُدفع لهم عبر Stripe. أكمل نموذج Stripe الآمن لتفعيل المدفوعات والتحويلات.';

  @override
  String get connect_details_submitted => 'تم إرسال التفاصيل';

  @override
  String get connect_charges_enabled => 'تم تفعيل المدفوعات';

  @override
  String get connect_payouts_enabled => 'تم تفعيل التحويلات';

  @override
  String get settings_preferences => 'تفضيلات الموجز';

  @override
  String get search_filter_brand => 'الماركة';

  @override
  String get search_filter_price => 'السعر (Dhs)';

  @override
  String get search_price_min => 'الأدنى';

  @override
  String get search_price_max => 'الأعلى';

  @override
  String search_brand_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ماركة',
      many: '$count ماركة',
      few: '$count ماركات',
      two: 'ماركتان',
      one: 'ماركة واحدة',
      zero: 'لا ماركات',
    );
    return '$_temp0';
  }

  @override
  String search_price_chip(int min, int max) {
    return '$min–$max Dhs';
  }

  @override
  String settings_iban_current(String masked) {
    return 'IBAN الحالي: $masked';
  }

  @override
  String get auth_or_continue_with => 'أو تابع باستخدام';

  @override
  String get onboarding_address_search_hint => 'ابحث عن عنوانك';

  @override
  String get account_gate_guest_title => 'أنشئ حسابًا أو سجّل الدخول للمتابعة';

  @override
  String get account_gate_guest_subtitle =>
      'انضم إلى Klozy لإضافة العناصر إلى قائمة الرغبات ومتابعة البائعين وشراء أزياء مستعملة.';

  @override
  String get account_gate_create_account => 'إنشاء حساب';

  @override
  String get account_gate_log_in => 'تسجيل الدخول';

  @override
  String get account_gate_incomplete_title => 'أكمل إعداد ملفك الشخصي';

  @override
  String get account_gate_incomplete_subtitle =>
      'أكمل ملفك الشخصي للوصول إلى جميع ميزات Klozy.';

  @override
  String get account_gate_finish_setup => 'إنهاء الإعداد';

  @override
  String get guest_tab_title => 'سجّل الدخول إلى Klozy';

  @override
  String get guest_tab_subtitle =>
      'أنشئ حسابًا أو سجّل الدخول للوصول إلى هذا القسم.';

  @override
  String get guest_tab_cta => 'إنشاء حساب';

  @override
  String get guest_tab_log_in => 'تسجيل الدخول';

  @override
  String get categoryPickerTitle => 'اختر الفئة';

  @override
  String get categoryPickerBreadcrumbRoot => 'كل الفئات';

  @override
  String get categoryPickerLoading => 'جارٍ التحميل...';

  @override
  String get categoryPickerRetry => 'إعادة المحاولة';

  @override
  String get categoryPickerDeepestHint => 'أعمق مستوى — صنّف حسب المقاس أدناه.';

  @override
  String get categoryPickerAddCategories => 'إضافة فئات';

  @override
  String get categoryPickerPreferred => 'الفئات المفضّلة';

  @override
  String get sellPhotosEmptyTitle => 'إضافة صور';

  @override
  String get sellPhotosEmptySubtitle => 'التقط أو ارفع صورًا لمنتجك';

  @override
  String get sellPhotosCounter => 'صور';

  @override
  String get sellRecapPhotoStripEdit => 'تعديل';

  @override
  String get sellRequiredHint => '* الحقول المطلوبة';

  @override
  String get settings_language => 'اللغة';

  @override
  String get offer_send_failed => 'تعذّر إرسال عرضك. حاول مرة أخرى.';

  @override
  String get product_see_offer => 'مشاهدة العرض';

  @override
  String get chat_empty_title => 'لا محادثات بعد';

  @override
  String get chat_empty_subtitle =>
      'أرسل رسالة لبائع من أي منتج لبدء المحادثة.';

  @override
  String get chat_composer_hint => 'رسالة…';

  @override
  String get chat_recording => 'جارٍ التسجيل…';

  @override
  String get chat_attach_photo => 'صورة وفيديو';

  @override
  String get chat_attach_camera => 'الكاميرا';

  @override
  String get chat_incomplete_profile_title => 'أكمل إعداد ملفك الشخصي';

  @override
  String get chat_incomplete_profile_subtitle =>
      'أكمل ملفك الشخصي لبدء المحادثة مع المشترين والبائعين.';

  @override
  String get chat_incomplete_profile_cta => 'إكمال الملف الشخصي';

  @override
  String get chat_menu_report => 'إبلاغ وحظر';

  @override
  String get chat_menu_delete => 'حذف المحادثة';

  @override
  String get chat_reply_self => 'تردّ على نفسك';

  @override
  String get chat_reply_other => 'ردّ';

  @override
  String get chat_media_placeholder => '[وسائط]';

  @override
  String get chat_offer_yours => 'عرضك';

  @override
  String get chat_offer_incoming => 'عرض';

  @override
  String get chat_offer_refuse => 'رفض';

  @override
  String get chat_offer_accept => 'قبول';

  @override
  String get chat_offer_pending => 'بانتظار الرد…';

  @override
  String get chat_offer_accepted => 'تم قبول العرض';

  @override
  String get chat_offer_declined => 'تم رفض العرض';

  @override
  String get chat_message_deleted => 'تم حذف الرسالة';

  @override
  String get chat_currency => 'Dhs';

  @override
  String get chat_purchase_confirmed => 'تم تأكيد الشراء';

  @override
  String get chat_purchase_for => 'بـ';

  @override
  String get chat_no_messages => 'لا رسائل بعد';

  @override
  String get chat_preview_photo => '📷 صورة';

  @override
  String get chat_preview_voice => '🎤 رسالة صوتية';

  @override
  String get chat_preview_offer_sent => 'أرسلت عرضًا';

  @override
  String get chat_preview_offer_new => 'عرض جديد';

  @override
  String get chat_preview_you_prefix => 'أنت: ';

  @override
  String get common_try_again => 'حاول مرة أخرى';

  @override
  String get common_time_just_now => 'الآن';

  @override
  String common_time_minutes_ago(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      many: 'منذ $count دقيقةً',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة واحدة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String common_time_hours_ago(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      many: 'منذ $count ساعةً',
      few: 'منذ $count ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة واحدة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String common_time_days_ago(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      many: 'منذ $count يومًا',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'منذ يوم واحد',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String get error_type_network_title => 'لا يوجد اتصال';

  @override
  String get error_type_network_message =>
      'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get error_type_timeout_title => 'استغرق الأمر وقتًا طويلاً';

  @override
  String get error_type_timeout_message =>
      'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get error_type_unauthorized_title => 'انتهت صلاحية الجلسة';

  @override
  String get error_type_unauthorized_message =>
      'يرجى تسجيل الدخول مرة أخرى للمتابعة.';

  @override
  String get error_type_not_found_title => 'غير موجود';

  @override
  String get error_type_not_found_message =>
      'لم نتمكن من العثور على ما كنت تبحث عنه.';

  @override
  String get error_type_server_title => 'حدث خطأ ما';

  @override
  String get error_type_server_message =>
      'حدث خلل في خوادمنا. يرجى المحاولة مرة أخرى.';

  @override
  String get error_type_unknown_title => 'حدث خطأ ما';

  @override
  String get error_type_unknown_message =>
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get reels_composer_post_failed =>
      'تعذّر نشر الريل الخاص بك. يرجى المحاولة مرة أخرى.';

  @override
  String get sell_publish_failed => 'تعذّر نشر إعلانك. يرجى المحاولة مرة أخرى.';

  @override
  String get auth_error_invalid_email =>
      'يبدو أن عنوان البريد الإلكتروني هذا غير صالح.';

  @override
  String get auth_error_user_disabled => 'تم تعطيل هذا الحساب.';

  @override
  String get auth_error_wrong_credentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get auth_error_email_already_in_use =>
      'يوجد حساب بالفعل بهذا البريد الإلكتروني.';

  @override
  String get auth_error_weak_password =>
      'اختر كلمة مرور أقوى (8 أحرف على الأقل).';

  @override
  String get auth_error_operation_not_allowed =>
      'طريقة تسجيل الدخول هذه غير مفعّلة.';

  @override
  String get auth_error_requires_recent_login =>
      'لأمانك، يرجى تسجيل الخروج ثم تسجيل الدخول مرة أخرى قبل تغيير هذا.';

  @override
  String get auth_error_too_many_requests =>
      'محاولات كثيرة جدًا. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get auth_error_network_request_failed =>
      'خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String get auth_error_invalid_phone_number =>
      'يبدو أن رقم الهاتف هذا غير صالح.';

  @override
  String get auth_error_invalid_verification_code => 'هذا الرمز غير صحيح.';

  @override
  String get auth_error_session_expired =>
      'انتهت صلاحية الرمز. اطلب رمزًا جديدًا.';

  @override
  String get auth_error_phone_already_in_use =>
      'هذا الرقم مرتبط بالفعل بحساب آخر.';

  @override
  String get auth_error_phone_verification_failed =>
      'فشل التحقق من رقم الهاتف. يرجى المحاولة مرة أخرى.';

  @override
  String get auth_error_google_sign_in_failed =>
      'فشل تسجيل الدخول باستخدام Google. يرجى المحاولة مرة أخرى.';

  @override
  String get auth_error_sign_in_cancelled => 'تم إلغاء تسجيل الدخول.';

  @override
  String get auth_error_apple_sign_in_failed =>
      'فشل تسجيل الدخول باستخدام Apple. يرجى المحاولة مرة أخرى.';

  @override
  String get auth_error_reauth_required_email =>
      'يرجى تسجيل الدخول مرة أخرى لتغيير بريدك الإلكتروني.';

  @override
  String get auth_error_reauth_required_password =>
      'لأمانك، يرجى تسجيل الدخول مرة أخرى قبل تغيير كلمة المرور.';

  @override
  String get auth_error_password_too_weak => 'يرجى اختيار كلمة مرور أقوى.';

  @override
  String get auth_error_password_update_failed => 'تعذّر تحديث كلمة المرور.';

  @override
  String get auth_error_reauth_required_phone =>
      'يرجى تسجيل الدخول مرة أخرى لتغيير رقمك.';

  @override
  String get auth_error_generic => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get address_form_label_hint => 'المنزل';

  @override
  String get sell_size_system_eu => 'EU';

  @override
  String get sell_size_system_us => 'US';

  @override
  String get payout_iban_hint => 'AE07 0331 2345 6789 0123 456';

  @override
  String get onboarding_seller_role_iban_hint => 'AE00 0000 0000 0000 0000';

  @override
  String get chat_media_voice_message => 'رسالة صوتية';

  @override
  String get chat_media_photo => 'صورة';

  @override
  String get chat_media_attachment => 'مرفق';
}
