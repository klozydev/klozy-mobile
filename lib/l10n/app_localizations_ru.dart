// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get app_name => 'Klozy';

  @override
  String get error_page_show_details => 'ПОКАЗАТЬ ПОДРОБНОСТИ';

  @override
  String get error_page_hide_details => 'СКРЫТЬ ПОДРОБНОСТИ';

  @override
  String get error_page_copy_for_support => 'СКОПИРОВАТЬ ДЛЯ ПОДДЕРЖКИ';

  @override
  String get error_page_need_help => 'НУЖНА ПОМОЩЬ?';

  @override
  String get error_page_support_email_label => 'support@klozy.app';

  @override
  String get error_page_source_label => 'ИСТОЧНИК';

  @override
  String get error_page_stage_label => 'ЭТАП';

  @override
  String get error_page_request_label => 'ЗАПРОС';

  @override
  String get error_page_message_label => 'СООБЩЕНИЕ';

  @override
  String get error_scenario_network_title => 'Похоже, вы не в сети';

  @override
  String get error_scenario_network_body =>
      'Для синхронизации нужно подключение. Проверьте Wi-Fi или мобильный интернет и попробуйте снова.';

  @override
  String get error_scenario_network_primary => 'Повторить подключение';

  @override
  String get error_scenario_network_secondary => 'Работать офлайн';

  @override
  String get error_scenario_server_title =>
      'Что-то пошло не так на нашей стороне';

  @override
  String get error_scenario_server_body =>
      'На сервере произошла непредвиденная ошибка. Наша команда уже уведомлена. Вы можете повторить попытку через мгновение.';

  @override
  String get error_scenario_server_primary => 'Попробовать снова';

  @override
  String get error_scenario_server_secondary => 'Связаться с поддержкой';

  @override
  String get error_scenario_session_title => 'Пожалуйста, войдите снова';

  @override
  String get error_scenario_session_body =>
      'Ваша сессия истекла в целях безопасности. Войдите снова, чтобы продолжить.';

  @override
  String get error_scenario_session_primary => 'Войти';

  @override
  String get error_scenario_session_secondary => 'Отмена';

  @override
  String get error_scenario_permission_title => 'У вас нет доступа сюда';

  @override
  String get error_scenario_permission_body =>
      'Этот ресурс ограничен. Попросите вашего менеджера предоставить доступ.';

  @override
  String get error_scenario_permission_primary => 'Назад';

  @override
  String get error_scenario_permission_secondary => 'Запросить доступ';

  @override
  String get error_scenario_notfound_title => 'Мы не смогли это найти';

  @override
  String get error_scenario_notfound_body =>
      'Возможно, это было удалено или перемещено.';

  @override
  String get error_scenario_notfound_primary => 'Назад';

  @override
  String get error_scenario_notfound_secondary => 'Обновить';

  @override
  String get error_scenario_rate_limit_title => 'Притормозите на минуту';

  @override
  String get error_scenario_rate_limit_body =>
      'Вы отправили слишком много запросов за короткое время. Сделайте небольшой перерыв — вы можете повторить попытку через 30 секунд.';

  @override
  String get error_scenario_rate_limit_primary => 'Повторить через 30 с';

  @override
  String get error_scenario_rate_limit_secondary => 'Отмена';

  @override
  String get error_scenario_maintenance_title => 'Мы скоро вернёмся';

  @override
  String get error_scenario_maintenance_body =>
      'Сервис проходит плановое техническое обслуживание. Работа должна возобновиться в течение 15 минут.';

  @override
  String get error_scenario_maintenance_primary => 'Проверить статус';

  @override
  String get error_scenario_maintenance_secondary => 'Уведомить меня';

  @override
  String get error_scenario_generic_title => 'Что-то пошло не так';

  @override
  String get error_scenario_generic_body =>
      'Произошла непредвиденная ошибка. Пожалуйста, попробуйте снова через мгновение.';

  @override
  String get error_scenario_generic_primary => 'Попробовать снова';

  @override
  String get error_scenario_generic_secondary => 'Отмена';

  @override
  String get error_scenario_server_http_label => 'Внутренняя ошибка сервера';

  @override
  String get error_scenario_session_http_label => 'Сессия истекла';

  @override
  String get error_scenario_permission_http_label => 'Доступ запрещён';

  @override
  String get error_scenario_notfound_http_label => 'Не найдено';

  @override
  String get error_scenario_rate_limit_http_label => 'Слишком много запросов';

  @override
  String get error_scenario_maintenance_http_label =>
      'Техническое обслуживание';

  @override
  String get auth_country_uae => 'ОБЪЕДИНЁННЫЕ АРАБСКИЕ ЭМИРАТЫ';

  @override
  String get auth_welcome_title =>
      'Покупайте и продавайте\nлюбимую одежду секонд-хенд.';

  @override
  String get auth_get_started => 'Начать';

  @override
  String get auth_already_have_account => 'У меня уже есть аккаунт · ';

  @override
  String get auth_log_in => 'Войти';

  @override
  String get auth_create_account_title => 'Создайте аккаунт';

  @override
  String get auth_welcome_back_title => 'С возвращением';

  @override
  String get auth_create_account_subtitle =>
      'Присоединяйтесь к тысячам тех, кто покупает и продаёт одежду по всем ОАЭ.';

  @override
  String get auth_welcome_back_subtitle =>
      'Войдите, чтобы продолжить с того места, где остановились.';

  @override
  String get auth_sign_up => 'Зарегистрироваться';

  @override
  String get auth_email_hint => 'Адрес электронной почты';

  @override
  String get auth_email_invalid => 'Введите корректный адрес электронной почты';

  @override
  String get auth_password_hint => 'Пароль';

  @override
  String get auth_forgot_password => 'Забыли пароль?';

  @override
  String get auth_continue_apple => 'Продолжить с Apple';

  @override
  String get auth_continue_google => 'Продолжить с Google';

  @override
  String get auth_continue_phone => 'Продолжить с телефоном';

  @override
  String get auth_terms_prefix => 'Продолжая, вы соглашаетесь с ';

  @override
  String get auth_terms => 'Условиями';

  @override
  String get auth_terms_and => ' и ';

  @override
  String get auth_privacy_policy => 'Политикой конфиденциальности';

  @override
  String get auth_create_account_button => 'Создать аккаунт';

  @override
  String get auth_password_reset_sent =>
      'Ссылка для сброса пароля отправлена. Проверьте почту.';

  @override
  String get auth_phone_title => 'Какой ваш номер?';

  @override
  String get auth_phone_subtitle =>
      'Мы отправим вам 6-значный код, чтобы подтвердить, что это действительно вы.';

  @override
  String get auth_phone_number_hint => '50 123 4567';

  @override
  String get auth_phone_disclaimer =>
      'Могут применяться стандартные тарифы на сообщения. Ваш номер никогда не показывается публично.';

  @override
  String get auth_send_code => 'Отправить код';

  @override
  String get auth_enter_code_title => 'Введите код';

  @override
  String get auth_code_sent_to => 'Отправлено на ';

  @override
  String auth_resend_code_in(String time) {
    return 'Повторная отправка кода через $time';
  }

  @override
  String get auth_resend_code => 'Отправить код повторно';

  @override
  String get auth_code_spam_hint =>
      'Не получили? Проверьте папку «Спам». Новый код можно запросить после периода ожидания.';

  @override
  String get auth_verify => 'Подтвердить';

  @override
  String get auth_new_code_sent => 'Новый код отправлен.';

  @override
  String get onboarding_all_set => 'Всё готово!';

  @override
  String onboarding_all_set_named(String name) {
    return 'Всё готово, $name!';
  }

  @override
  String get onboarding_feed_ready_subtitle =>
      'Ваша лента Klozy готова. Открывайте, продавайте и покупайте образы — всё в одном месте.';

  @override
  String get onboarding_start_exploring => 'Начать обзор';

  @override
  String get onboarding_complete_profile_title => 'Заполните профиль';

  @override
  String get onboarding_complete_profile_subtitle =>
      'Так другие участники будут видеть вас в Klozy.';

  @override
  String get onboarding_photo_upload_coming_soon =>
      'Загрузка фото скоро появится.';

  @override
  String get onboarding_first_name_label => 'Имя';

  @override
  String get onboarding_first_name_hint => 'Амира';

  @override
  String get onboarding_last_name_label => 'Фамилия';

  @override
  String get onboarding_last_name_hint => 'Хассан';

  @override
  String get onboarding_address_label => 'Адрес';

  @override
  String get onboarding_bio_label => 'О себе';

  @override
  String onboarding_bio_char_count(int count, int max) {
    return '$count/$max';
  }

  @override
  String get onboarding_bio_hint =>
      'Расскажите покупателям немного о своём стиле…';

  @override
  String get onboarding_continue => 'Продолжить';

  @override
  String get onboarding_skip => 'Пропустить';

  @override
  String get onboarding_personalize_title => 'Персонализируйте ленту';

  @override
  String get onboarding_personalize_subtitle =>
      'Выберите несколько вещей, которые вам нравятся, чтобы мы наполнили вашу ленту нужными находками. Вы можете изменить это в любой момент.';

  @override
  String get onboarding_categories_title => 'Категории';

  @override
  String get onboarding_categories_hint => 'Выберите любые';

  @override
  String get onboarding_sizes_title => 'Размеры';

  @override
  String get onboarding_clothing_label => 'Одежда';

  @override
  String onboarding_shoes_label(String system) {
    return 'Обувь · $system';
  }

  @override
  String get onboarding_brands_title => 'Бренды';

  @override
  String get onboarding_brands_hint => 'Подпишитесь на любимые';

  @override
  String get onboarding_brands_search_hint => 'Поиск брендов';

  @override
  String get onboarding_no_brand_matches => 'Брендов не найдено.';

  @override
  String get onboarding_show_feed => 'Показать мою ленту';

  @override
  String onboarding_show_feed_count(int count) {
    return 'Показать мою ленту · выбрано $count';
  }

  @override
  String get onboarding_seller_account_set_up => 'Аккаунт продавца настроен.';

  @override
  String get onboarding_seller_role_title => 'Как вы будете продавать?';

  @override
  String get onboarding_seller_role_subtitle =>
      'Выберите аккаунт, который вам подходит. Вы можете сменить или повысить его в любой момент в Настройках.';

  @override
  String get onboarding_private_seller_title => 'Частный продавец';

  @override
  String get onboarding_private_seller_badge => 'Самый популярный';

  @override
  String get onboarding_private_seller_description =>
      'Разбираете собственный гардероб. Получайте оплату прямо на банковский счёт по IBAN — без бумажной волокиты.';

  @override
  String get onboarding_payout_iban_label => 'IBAN для выплат';

  @override
  String get onboarding_iban_shield_note =>
      'Зашифрован и используется только для перечисления выплат с продаж. Вы можете изменить его позже в разделе Настройки → Выплаты.';

  @override
  String get onboarding_pro_vendor_title => 'Профессиональный продавец';

  @override
  String get onboarding_pro_vendor_badge => 'Pro';

  @override
  String get onboarding_pro_vendor_description =>
      'Ведёте бизнес по перепродаже. Массовые объявления, фирменный магазин и аналитика. Верификация и оплата через Stripe (KYB).';

  @override
  String get onboarding_buyer_protection_note =>
      'Каждая продажа защищена системой защиты покупателей Klozy. Платёж удерживается на эскроу-счёте и перечисляется вам после подтверждения доставки.';

  @override
  String get home_tab_feed => 'Лента';

  @override
  String get home_tab_wishlist => 'Избранное';

  @override
  String get home_tab_reels => 'Reels';

  @override
  String get home_feed_empty => 'Здесь пока ничего нет.';

  @override
  String get home_category_all => 'Все';

  @override
  String get home_product_badge_new => 'Новое';

  @override
  String get home_wishlist_empty => 'Ваше избранное пусто';

  @override
  String get reels_composer_title => 'Новый reel';

  @override
  String get reels_pick_title => 'Создать reel';

  @override
  String get reels_pick_subtitle =>
      'Запишите короткое видео, демонстрирующее ваши вещи, или выберите одно из галереи.';

  @override
  String get reels_record_video => 'Записать видео';

  @override
  String get reels_choose_from_gallery => 'Выбрать из галереи';

  @override
  String get reels_caption_hint => 'Скажите что-нибудь о своём образе…';

  @override
  String get reels_tag_items_title => 'Отметьте товары из вашего магазина';

  @override
  String get reels_no_listings_to_tag =>
      'У вас пока нет активных объявлений для отметки.';

  @override
  String get reels_post_reel => 'Опубликовать reel';

  @override
  String get reels_posted_title => 'Reel опубликован!';

  @override
  String get reels_posted_subtitle =>
      'Он появится в Reels после завершения обработки.';

  @override
  String get reels_done => 'Готово';

  @override
  String get reels_delete_reel => 'Удалить reel';

  @override
  String get reels_report_reel => 'Пожаловаться на reel';

  @override
  String get reels_share => 'Поделиться';

  @override
  String reels_shop_the_look_count(int count) {
    return 'Купить образ · $count';
  }

  @override
  String get reels_no_tagged_items => 'Нет отмеченных товаров.';

  @override
  String get reels_shop_the_look => 'Купить образ';

  @override
  String get reels_deleted_snackbar => 'Reel удалён.';

  @override
  String get reels_report_received_snackbar => 'Спасибо — жалоба получена.';

  @override
  String get reels_empty => 'Пока нет reels';

  @override
  String get reels_link_copied_snackbar => 'Ссылка скопирована в буфер обмена.';

  @override
  String get search_hint => 'Поиск товаров, брендов…';

  @override
  String get search_sort_popular => 'Популярные';

  @override
  String get search_sort_latest => 'Новые';

  @override
  String get search_sort_price_asc => 'Цена ↑';

  @override
  String get search_sort_price_desc => 'Цена ↓';

  @override
  String get search_filters => 'Фильтры';

  @override
  String search_filters_with_count(int count) {
    return 'Фильтры · $count';
  }

  @override
  String get search_browse_categories => 'Просмотр категорий';

  @override
  String get search_popular_now => 'Сейчас популярно';

  @override
  String get search_no_results => 'Нет результатов';

  @override
  String search_result_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count результата',
      many: '$count результатов',
      few: '$count результата',
      one: '1 результат',
    );
    return '$_temp0';
  }

  @override
  String search_condition_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count состояния',
      many: '$count состояний',
      few: '$count состояния',
      one: '1 состояние',
    );
    return '$_temp0';
  }

  @override
  String search_size_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count размера',
      many: '$count размеров',
      few: '$count размера',
      one: '1 размер',
    );
    return '$_temp0';
  }

  @override
  String get search_filter_category => 'Категория';

  @override
  String get search_filter_condition => 'Состояние';

  @override
  String get search_filter_size => 'Размер';

  @override
  String get search_filter_reset => 'Сбросить';

  @override
  String get search_filter_show_results => 'Показать результаты';

  @override
  String get product_add_to_cart => 'В корзину';

  @override
  String get product_buy => 'Купить';

  @override
  String get product_in_cart_view_cart => 'В корзине · Посмотреть корзину';

  @override
  String get product_edit_listing => 'Редактировать объявление';

  @override
  String get product_status_sold => 'Продано';

  @override
  String get product_status_reserved => 'Зарезервировано';

  @override
  String get product_mark_as_sold => 'Отметить как проданное';

  @override
  String get product_mark_as_available => 'Отметить как доступное';

  @override
  String get product_delete_listing => 'Удалить объявление';

  @override
  String get product_report_listing => 'Пожаловаться на объявление';

  @override
  String get product_report_this_listing => 'Пожаловаться на это объявление';

  @override
  String get product_listing_deleted => 'Объявление удалено';

  @override
  String get product_back_to_feed => 'Назад в ленту';

  @override
  String get product_added_to_cart => 'Добавлено в корзину.';

  @override
  String get product_edit_coming_soon =>
      'Редактирование объявлений скоро появится.';

  @override
  String get product_messaging_coming_soon => 'Сообщения скоро появятся.';

  @override
  String get product_report_received => 'Спасибо — жалоба получена.';

  @override
  String get product_link_copied => 'Ссылка скопирована в буфер обмена.';

  @override
  String get product_stat_views => 'Просмотры';

  @override
  String get product_stat_likes => 'Лайки';

  @override
  String get product_stat_posted => 'Опубликовано';

  @override
  String get product_stamp_sold => 'ПРОДАНО';

  @override
  String get product_stamp_reserved => 'ЗАРЕЗЕРВИРОВАНО';

  @override
  String get product_make_offer => 'Предложить цену';

  @override
  String get product_currency_dhs => 'Dhs';

  @override
  String product_price_amount(int amount) {
    return '$amount ';
  }

  @override
  String get sell_sell_in_seconds => 'Продайте за секунды';

  @override
  String get sell_your_photos => 'Ваши фото';

  @override
  String get sell_add_photos_hint =>
      'Добавьте до 8 фото. ИИ заполнит ваше объявление.';

  @override
  String get sell_continue => 'Продолжить';

  @override
  String get sell_cover => 'Обложка';

  @override
  String get sell_add_a_photo => 'Добавить фото';

  @override
  String get sell_take_a_photo => 'Сделать фото';

  @override
  String get sell_choose_from_gallery => 'Выбрать из галереи';

  @override
  String get sell_analysing_your_photos => 'Анализируем ваши фото…';

  @override
  String get sell_identifying_the_item => 'Определяем товар…';

  @override
  String get sell_generating_title_and_price => 'Генерируем название и цену…';

  @override
  String get sell_title => 'Название';

  @override
  String get sell_price => 'Цена';

  @override
  String get sell_description => 'Описание';

  @override
  String get sell_category => 'Категория';

  @override
  String get sell_brand => 'Бренд';

  @override
  String get sell_size => 'Размер';

  @override
  String get sell_condition => 'Состояние';

  @override
  String get sell_suggested_by_ai => 'Предложено ИИ';

  @override
  String get sell_list_item => 'Разместить товар';

  @override
  String get sell_optional => 'Необязательно';

  @override
  String get sell_title_hint => 'напр. Кожаная байкерская куртка';

  @override
  String get sell_price_hint => 'AED';

  @override
  String get sell_description_hint =>
      'Добавьте детали о состоянии, посадке, материале…';

  @override
  String get sell_search_brands => 'Поиск брендов';

  @override
  String sell_use_quoted(String value) {
    return 'Использовать «$value»';
  }

  @override
  String get sell_title_error => 'Добавьте название (минимум 2 символа)';

  @override
  String get sell_price_error => 'Введите цену';

  @override
  String get sell_category_error => 'Выберите категорию';

  @override
  String get sell_condition_error => 'Выберите состояние';

  @override
  String get sell_youre_live => 'Вы в эфире!';

  @override
  String get sell_item_visible_to_buyers =>
      'Ваш товар теперь виден покупателям.';

  @override
  String get sell_view_listing => 'Посмотреть объявление';

  @override
  String get sell_back_to_home => 'На главную';

  @override
  String get cart_title => 'Корзина';

  @override
  String get cart_make_an_offer => 'Предложить цену';

  @override
  String get cart_cancel_offer => 'Отменить предложение';

  @override
  String get cart_check_out => 'Оформить заказ';

  @override
  String get cart_subtotal => 'Промежуточный итог';

  @override
  String get cart_offer_pending => 'Предложение на рассмотрении';

  @override
  String get cart_offer_accepted => 'Предложение принято';

  @override
  String get cart_pro_badge => 'PRO';

  @override
  String get cart_empty_title => 'Ваша корзина пуста';

  @override
  String get cart_empty_subtitle =>
      'Добавляйте товары, и они сгруппируются здесь по продавцам.';

  @override
  String get cart_offer_send => 'Отправить предложение';

  @override
  String get cart_offer_hint_single => 'Ваше предложение';

  @override
  String cart_offer_hint_multi(int count) {
    return 'Ваше предложение за все $count товаров';
  }

  @override
  String get cart_offer_error_below_total =>
      'Предложение должно быть ниже общей цены';

  @override
  String get cart_offer_chat_note =>
      'Одно предложение охватывает всё от этого продавца. Оно отправляется приватно в чат — продавец принимает или отклоняет его.';

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
      other: '$count товара',
      many: '$count товаров',
      few: '$count товара',
      one: '1 товар',
    );
    return '$_temp0';
  }

  @override
  String cart_sellers_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count продавца · одно предложение и оформление на продавца',
      many: '$count продавцов · одно предложение и оформление на продавца',
      few: '$count продавца · одно предложение и оформление на продавца',
      one: '1 продавец · одно предложение и оформление на продавца',
    );
    return '$_temp0';
  }

  @override
  String get checkout_title => 'Оформление заказа';

  @override
  String get checkout_delivery => 'Доставка';

  @override
  String get checkout_summary => 'Сводка';

  @override
  String get checkout_subtotal => 'Промежуточный итог';

  @override
  String get checkout_shipping_emx => 'Доставка (EMX)';

  @override
  String get checkout_buyer_protection => 'Защита покупателя';

  @override
  String get checkout_vat => 'VAT';

  @override
  String get checkout_total => 'Итого';

  @override
  String checkout_pay_amount(int amount) {
    return 'Оплатить $amount Dhs';
  }

  @override
  String checkout_amount_dhs(int amount) {
    return '$amount Dhs';
  }

  @override
  String get checkout_encrypted_escrow_note =>
      'Зашифрованное оформление · платёж удерживается на эскроу-счёте';

  @override
  String get checkout_order_placed_title => 'Заказ оформлен!';

  @override
  String get checkout_order_placed_escrow_message =>
      'Ваш платёж удерживается на эскроу-счёте, пока вы не подтвердите доставку.';

  @override
  String get checkout_track_order => 'Отследить заказ';

  @override
  String get checkout_continue_shopping => 'Продолжить покупки';

  @override
  String get checkout_payment_unavailable =>
      'Оплата недоступна для этого заказа.';

  @override
  String get checkout_payment_failed =>
      'Оплата не удалась. Пожалуйста, попробуйте снова.';

  @override
  String get orders_my_orders => 'Мои заказы';

  @override
  String get orders_buying => 'Покупки';

  @override
  String get orders_selling => 'Продажи';

  @override
  String get orders_in_progress => 'В процессе';

  @override
  String get orders_completed => 'Завершено';

  @override
  String get orders_no_orders_yet => 'Пока нет заказов';

  @override
  String get orders_prefix_from => 'от';

  @override
  String get orders_prefix_to => 'для';

  @override
  String orders_price_dhs(int amount) {
    return '$amount Dhs';
  }

  @override
  String orders_counterpart_meta(String prefix, String name) {
    return '$prefix $name';
  }

  @override
  String get orders_order_details => 'Детали заказа';

  @override
  String get orders_tracking => 'Отслеживание';

  @override
  String get orders_tracking_updates_empty =>
      'Обновления отслеживания появятся здесь.';

  @override
  String get orders_emx_door_to_door => 'EMX от двери до двери · по ОАЭ';

  @override
  String orders_carrier_prefix(String carrier) {
    return '$carrier · ';
  }

  @override
  String get orders_mark_as_shipped => 'Отметить как отправленное';

  @override
  String get orders_download_emx_label => 'Скачать накладную EMX';

  @override
  String get orders_confirm_receipt => 'Подтвердить получение';

  @override
  String get orders_leave_a_review => 'Оставить отзыв';

  @override
  String get orders_view_live_tracking =>
      'Смотреть отслеживание в реальном времени';

  @override
  String get orders_report_a_problem => 'Сообщить о проблеме';

  @override
  String get orders_cancel_order => 'Отменить заказ';

  @override
  String get orders_confirm_receipt_message =>
      'Подтвердить, что вы получили этот заказ? Это перечислит платёж продавцу.';

  @override
  String get orders_cancel_order_message =>
      'Отменить этот заказ? Платёж будет возвращён.';

  @override
  String get orders_dialog_cancel => 'Отмена';

  @override
  String get orders_dialog_confirm => 'Подтвердить';

  @override
  String get orders_submit_report => 'Отправить жалобу';

  @override
  String get orders_report_problem_hint =>
      'Опишите, что не так с вашим заказом';

  @override
  String get orders_submit_review => 'Отправить отзыв';

  @override
  String get orders_review_hint =>
      'Поделитесь деталями о вашем опыте (необязательно)';

  @override
  String get orders_messaging_coming_soon => 'Сообщения скоро появятся.';

  @override
  String get orders_couldnt_open_link => 'Не удалось открыть ссылку.';

  @override
  String get orders_status_pending => 'В ожидании';

  @override
  String get orders_status_awaiting_shipment => 'Ожидает отправки';

  @override
  String get orders_status_in_delivery => 'В доставке';

  @override
  String get orders_status_out_for_delivery => 'Передано в доставку';

  @override
  String get orders_status_completed => 'Завершено';

  @override
  String get orders_status_return_requested => 'Запрошен возврат';

  @override
  String get orders_status_canceled => 'Отменено';

  @override
  String get orders_status_unknown => '—';

  @override
  String get profile_title => 'Профиль';

  @override
  String get chat_title => 'Чат';

  @override
  String get ds_password_strength_weak => 'Слабый';

  @override
  String get ds_password_strength_fair => 'Средний';

  @override
  String get ds_password_strength_good => 'Хороший';

  @override
  String get ds_password_strength_strong => 'Надёжный';

  @override
  String get notifications_title => 'Уведомления';

  @override
  String get notifications_read_all => 'Прочитать все';

  @override
  String get notifications_empty => 'Вы всё просмотрели.';

  @override
  String get notifications_profile_coming_soon => 'Профили скоро появятся.';

  @override
  String get notifications_time_just_now => 'Только что';

  @override
  String notifications_time_minutes(int count) {
    return '$count мин назад';
  }

  @override
  String notifications_time_hours(int count) {
    return '$count ч назад';
  }

  @override
  String notifications_time_days(int count) {
    return '$count дн назад';
  }

  @override
  String get profile_edit => 'Редактировать профиль';

  @override
  String get profile_follow => 'Подписаться';

  @override
  String get profile_following => 'Вы подписаны';

  @override
  String get profile_report_user => 'Пожаловаться на пользователя';

  @override
  String get profile_reported => 'Спасибо — жалоба получена.';

  @override
  String get profile_message_coming_soon => 'Сообщения скоро появятся.';

  @override
  String get profile_edit_coming_soon =>
      'Редактирование профиля скоро появится.';

  @override
  String get profile_settings_coming_soon => 'Настройки скоро появятся.';

  @override
  String get profile_reel_coming_soon =>
      'Воспроизведение reels скоро появится.';

  @override
  String get profile_tab_products => 'Товары';

  @override
  String get profile_tab_reels => 'Reels';

  @override
  String get profile_tab_reviews => 'Отзывы';

  @override
  String get profile_stat_listings => 'Объявления';

  @override
  String get profile_stat_followers => 'Подписчики';

  @override
  String get profile_stat_following => 'Подписки';

  @override
  String get profile_no_listings => 'Пока нет объявлений';

  @override
  String get profile_no_reels => 'Пока нет reels';

  @override
  String get profile_no_reviews => 'Пока нет отзывов';

  @override
  String get profile_no_followers => 'Пока нет подписчиков';

  @override
  String get profile_no_following => 'Пока нет подписок';

  @override
  String get profile_connections_title => 'Связи';

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_cancel => 'Отмена';

  @override
  String get settings_save => 'Сохранить';

  @override
  String get settings_saved => 'Сохранено.';

  @override
  String get settings_save_failed =>
      'Не удалось сохранить. Пожалуйста, попробуйте снова.';

  @override
  String get settings_link_failed => 'Не удалось открыть ссылку.';

  @override
  String get settings_section_profile => 'Профиль';

  @override
  String get settings_section_seller => 'Продавец';

  @override
  String get settings_section_notifications => 'Уведомления';

  @override
  String get settings_section_privacy => 'Конфиденциальность и безопасность';

  @override
  String get settings_section_legal => 'Правовая информация и поддержка';

  @override
  String get settings_section_account => 'Аккаунт';

  @override
  String get settings_edit_profile => 'Редактировать профиль';

  @override
  String get settings_delivery_address => 'Адрес доставки';

  @override
  String get settings_payout_iban => 'IBAN для выплат';

  @override
  String get settings_seller_stats => 'Статистика продавца';

  @override
  String get settings_push_notifications => 'Push-уведомления';

  @override
  String get settings_email_notifications => 'Уведомления по электронной почте';

  @override
  String get settings_blocked_users => 'Заблокированные пользователи';

  @override
  String get settings_change_password => 'Изменить пароль';

  @override
  String get settings_terms => 'Условия обслуживания';

  @override
  String get settings_privacy => 'Политика конфиденциальности';

  @override
  String get settings_support => 'Помощь и поддержка';

  @override
  String get settings_version => 'Версия';

  @override
  String get settings_logout => 'Выйти';

  @override
  String get settings_logout_confirm => 'Выйти из вашего аккаунта?';

  @override
  String get settings_delete_account => 'Удалить аккаунт';

  @override
  String get settings_delete_confirm =>
      'Безвозвратно удалить ваш аккаунт? Это действие нельзя отменить.';

  @override
  String get settings_change_password_no_email =>
      'К этому аккаунту не привязана электронная почта.';

  @override
  String get settings_password_reset_sent =>
      'Ссылка для сброса пароля отправлена. Проверьте почту.';

  @override
  String get settings_support_unavailable => 'Поддержка сейчас недоступна.';

  @override
  String get settings_handle => 'Имя пользователя';

  @override
  String get settings_address_line1 => 'Строка адреса';

  @override
  String get settings_address_area => 'Район';

  @override
  String get settings_address_city => 'Город';

  @override
  String get settings_address_emirate => 'Эмират';

  @override
  String get settings_iban_label => 'IBAN';

  @override
  String get settings_iban_invalid =>
      'Введите корректный IBAN ОАЭ (начинается с AE)';

  @override
  String get settings_iban_note =>
      'Зашифрован и используется только для перечисления выплат с продаж.';

  @override
  String get settings_no_stats => 'Пока нет статистики.';

  @override
  String get settings_doc_unavailable => 'Этот документ сейчас недоступен.';

  @override
  String get settings_no_blocked => 'Вы никого не заблокировали.';

  @override
  String get settings_unblock => 'Разблокировать';

  @override
  String get onboarding_avatar_failed =>
      'Не удалось загрузить ваше фото. Пожалуйста, попробуйте снова.';

  @override
  String get sell_weight => 'Вес (граммы)';

  @override
  String get sell_weight_hint => 'напр. 800';

  @override
  String get notifications_group_today => 'Сегодня';

  @override
  String get notifications_group_earlier => 'Ранее';

  @override
  String get checkout_add_address => 'Добавить адрес доставки';

  @override
  String get checkout_add => 'Добавить';

  @override
  String get checkout_change => 'Изменить';

  @override
  String get address_add_title => 'Добавить адрес';

  @override
  String get address_edit_title => 'Редактировать адрес';

  @override
  String get address_label => 'Метка';

  @override
  String get address_recipient => 'Имя получателя';

  @override
  String get address_phone => 'Телефон';

  @override
  String get address_empty => 'Пока нет сохранённых адресов.';

  @override
  String get address_default => 'ПО УМОЛЧАНИЮ';

  @override
  String get address_action_edit => 'Редактировать';

  @override
  String get address_action_default => 'Сделать по умолчанию';

  @override
  String get address_action_delete => 'Удалить';

  @override
  String get settings_payouts => 'Выплаты';

  @override
  String get payouts_pending => 'В ожидании';

  @override
  String get payouts_lifetime => 'Всего выплачено';

  @override
  String get payouts_empty => 'Пока нет выплат.';

  @override
  String get payouts_status_completed => 'Завершено';

  @override
  String get payouts_status_reversal => 'Возвращено';

  @override
  String get payouts_status_pending => 'В ожидании';

  @override
  String get profile_block_user => 'Заблокировать пользователя';

  @override
  String get profile_blocked => 'Пользователь заблокирован.';

  @override
  String get reels_edit_reel => 'Редактировать reel';

  @override
  String get reels_caption_updated => 'Подпись обновлена.';

  @override
  String get reels_comments_title => 'Комментарии';

  @override
  String get reels_comments_label => 'Комментарий';

  @override
  String get reels_no_comments => 'Пока нет комментариев — будьте первым.';

  @override
  String get reels_comment_hint => 'Добавить комментарий…';

  @override
  String get reels_comment_failed => 'Не удалось опубликовать ваш комментарий.';

  @override
  String get offers_title => 'Предложения';

  @override
  String get offers_incoming => 'Входящие';

  @override
  String get offers_outgoing => 'Исходящие';

  @override
  String get offers_empty => 'Здесь пока нет предложений.';

  @override
  String get offers_accept => 'Принять';

  @override
  String get offers_decline => 'Отклонить';

  @override
  String get offers_status_pending => 'В ожидании';

  @override
  String get offers_status_accepted => 'Принято';

  @override
  String get offers_status_declined => 'Отклонено';

  @override
  String get offers_status_cancelled => 'Отменено';

  @override
  String get legal_pending_title => 'Обновлённые условия';

  @override
  String get legal_pending_message =>
      'Мы обновили наши правовые документы. Пожалуйста, ознакомьтесь и примите их, чтобы продолжить.';

  @override
  String get legal_accept_continue => 'Принять и продолжить';

  @override
  String get connect_title => 'Верификация продавца';

  @override
  String get connect_start => 'Начать верификацию';

  @override
  String get connect_continue => 'Продолжить верификацию';

  @override
  String get connect_status_complete => 'Верифицирован';

  @override
  String get connect_status_pending => 'Верификация в процессе';

  @override
  String get connect_status_not_started => 'Ещё не верифицирован';

  @override
  String get connect_explainer =>
      'Профессиональные продавцы проходят верификацию и получают оплату через Stripe. Заполните защищённую форму Stripe, чтобы включить платежи и выплаты.';

  @override
  String get connect_details_submitted => 'Данные отправлены';

  @override
  String get connect_charges_enabled => 'Платежи включены';

  @override
  String get connect_payouts_enabled => 'Выплаты включены';

  @override
  String get settings_preferences => 'Настройки ленты';

  @override
  String get search_filter_brand => 'Бренд';

  @override
  String get search_filter_price => 'Цена (Dhs)';

  @override
  String get search_price_min => 'Мин.';

  @override
  String get search_price_max => 'Макс.';

  @override
  String search_brand_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бренда',
      many: '$count брендов',
      few: '$count бренда',
      one: '1 бренд',
    );
    return '$_temp0';
  }

  @override
  String search_price_chip(int min, int max) {
    return '$min–$max Dhs';
  }

  @override
  String settings_iban_current(String masked) {
    return 'Текущий IBAN: $masked';
  }

  @override
  String get auth_or_continue_with => 'или продолжить с';

  @override
  String get onboarding_address_search_hint => 'Поиск вашего адреса';

  @override
  String get account_gate_guest_title =>
      'Создайте аккаунт или войдите, чтобы продолжить';

  @override
  String get account_gate_guest_subtitle =>
      'Присоединяйтесь к Klozy, чтобы добавлять товары в список желаний, подписываться на продавцов и покупать одежду секонд-хенд.';

  @override
  String get account_gate_create_account => 'Создать аккаунт';

  @override
  String get account_gate_log_in => 'Войти';

  @override
  String get account_gate_incomplete_title => 'Завершите настройку профиля';

  @override
  String get account_gate_incomplete_subtitle =>
      'Заполните профиль, чтобы открыть все возможности Klozy.';

  @override
  String get account_gate_finish_setup => 'Завершить настройку';

  @override
  String get guest_tab_title => 'Войдите в Klozy';

  @override
  String get guest_tab_subtitle =>
      'Создайте аккаунт или войдите, чтобы получить доступ к этому разделу.';

  @override
  String get guest_tab_cta => 'Создать аккаунт';

  @override
  String get guest_tab_log_in => 'Войти';

  @override
  String get categoryPickerTitle => 'Выберите категорию';

  @override
  String get categoryPickerBreadcrumbRoot => 'Все категории';

  @override
  String get categoryPickerLoading => 'Загрузка...';

  @override
  String get categoryPickerRetry => 'Повторить';

  @override
  String get categoryPickerAddCategories => 'Добавить категории';

  @override
  String get categoryPickerPreferred => 'Предпочитаемые категории';

  @override
  String get sellPhotosEmptyTitle => 'Добавить фото';

  @override
  String get sellPhotosEmptySubtitle =>
      'Сделайте или загрузите фото вашего товара';

  @override
  String get sellPhotosCounter => 'фото';

  @override
  String get sellRecapPhotoStripEdit => 'Изменить';

  @override
  String get sellRequiredHint => '* Обязательные поля';

  @override
  String get sellSizeSystem => 'Система размеров';

  @override
  String get settings_language => 'Язык';

  @override
  String get offer_send_failed =>
      'Не удалось отправить ваше предложение. Попробуйте ещё раз.';
}
