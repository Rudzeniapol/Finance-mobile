import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/settings_provider.dart';

class AppLocalizations {
  final String locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context, {bool listen = true}) {
    final locale = Provider.of<SettingsProvider>(context, listen: listen).locale;
    return AppLocalizations(locale);
  }

  String get(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['en']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'your_balance': 'Your Balance',
      'activities': 'Activities',
      'this_week': 'This Week',
      'jan': 'Jan',
      'feb': 'Feb',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',

      'your_cards': 'Your Cards',
      'no_active_cards': 'No active cards',
      'you_have_1_card': 'You have 1 active card',
      'you_have_n_cards': 'You have {count} active cards',
      'no_cards_yet': 'No cards yet',
      'tap_to_add': 'Tap + to add your first card',
      'recent_transactions': 'Recent Transactions',
      'delete_card': 'Delete Card',
      'delete_card_confirm': 'Are you sure you want to remove this card?',
      'cancel': 'Cancel',
      'delete': 'Delete',

      'add_new_card': 'Add New Card',
      'card_number': 'Card Number',
      'card_number_hint': '1234 5678 9012 3456',
      'card_number_required': 'Card number is required',
      'card_number_invalid': 'Enter a valid card number',
      'card_number_digits_only': 'Card number must contain only digits',
      'card_number_luhn_failed': 'Card number is not valid',
      'cardholder_name': 'Cardholder Name',
      'cardholder_hint': 'FName LName',
      'name_required': 'Name is required',
      'name_too_short': 'Name must be at least 2 characters',
      'name_letters_only': 'Name must contain only letters and spaces',
      'expiry_date': 'Expiry Date',
      'expiry_hint': 'MM/YY',
      'expiry_required': 'Expiry date is required',
      'expiry_invalid': 'Use format MM/YY',
      'expiry_invalid_month': 'Month must be 01–12',
      'expiry_expired': 'This card has expired',
      'card_color': 'Card Color',
      'add_card': 'Add Card',

      'expiry_date_label': 'Expiry Date',

      'dark_mode': 'Dark Mode',
      'language': 'Language',

      'date_june_14_2020': 'June 14, 2020',
      'date_june_14': 'June 14',
      'date_june_28': 'June 28',
      'date_aug_28': 'Aug 28',

      'corporate_app': 'Corporate APP',
      'security_settings': 'Security Settings',
      'online_shopping': 'Online Shopping',
      'groceries': 'Groceries',
      'utilities': 'Utilities',
      'thumb_scanner': 'Thumb Scanner',
      'settings': 'Settings',

      'exchange_rates': 'Exchange Rates',
      'no_connection': 'No internet connection',
      'cached_data': 'Showing cached data',
      'rates_error': 'Could not load rates',

      // ── Search / Filter / Sort ──────────────────────────────────────────────
      'search': 'Search',
      'search_hint': 'Search cards and transactions…',
      'filter_all': 'All',
      'filter_food': 'Food',
      'filter_transfer': 'Transfer',
      'filter_shopping': 'Shopping',
      'filter_utilities': 'Utilities',
      'filter_other': 'Other',
      'sort_by': 'Sort by',
      'sort_date': 'Date',
      'sort_amount': 'Amount',
      'sort_name': 'Name',
      'date_range': 'Date range',
      'no_results': 'No results found',
      'cards_section': 'Cards',
      'transactions_section': 'Transactions',
      'clear_filters': 'Clear',

      // ── Notifications ───────────────────────────────────────────────────────
      'notifications': 'Notifications',
      'no_notifications': 'No notifications scheduled',
      'add_notification': 'New Reminder',
      'notification_title': 'Title',
      'notification_title_hint': 'e.g. Check balance',
      'notification_body': 'Message',
      'notification_body_hint': 'e.g. Review your weekly spending',
      'notification_default_body': 'MyFinance reminder',
      'notification_repeat': 'Repeat',
      'repeat_once': 'Once',
      'repeat_daily': 'Daily',
      'repeat_weekly': 'Weekly',
      'notification_time': 'Time',
      'notification_date': 'Date',
      'notification_weekday': 'Day of Week',
      'delete_notification': 'Delete reminder',
      'schedule': 'Schedule',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',

      // ── Firebase / ImageKit ─────────────────────────────────────────────────
      'upload_image': 'Upload Image',
      'uploading': 'Uploading…',
      'upload_failed': 'Upload failed',
      'firebase_sync': 'Cloud Sync',
    },
    'ru': {
      
      'your_balance': 'Ваш Баланс',
      'activities': 'Активность',
      'this_week': 'Эта неделя',
      'jan': 'Янв',
      'feb': 'Фев',
      'march': 'Март',
      'april': 'Апр',
      'may': 'Май',
      'jun': 'Июн',
      'jul': 'Июл',

      
      'your_cards': 'Ваши Карты',
      'no_active_cards': 'Нет активных карт',
      'you_have_1_card': 'У вас 1 активная карта',
      'you_have_n_cards': 'У вас {count} активных карт',
      'no_cards_yet': 'Нет карт',
      'tap_to_add': 'Нажмите + чтобы добавить карту',
      'recent_transactions': 'Последние Транзакции',
      'delete_card': 'Удалить Карту',
      'delete_card_confirm': 'Вы уверены, что хотите удалить эту карту?',
      'cancel': 'Отмена',
      'delete': 'Удалить',

      
      'add_new_card': 'Добавить Карту',
      'card_number': 'Номер Карты',
      'card_number_hint': '1234 5678 9012 3456',
      'card_number_required': 'Введите номер карты',
      'card_number_invalid': 'Введите корректный номер',
      'card_number_digits_only': 'Номер должен содержать только цифры',
      'card_number_luhn_failed': 'Номер карты недействителен',
      'cardholder_name': 'Имя Владельца',
      'cardholder_hint': 'Имя Фамилия',
      'name_required': 'Введите имя',
      'name_too_short': 'Имя должно быть не менее 2 символов',
      'name_letters_only': 'Имя должно содержать только буквы и пробелы',
      'expiry_date': 'Срок Действия',
      'expiry_hint': 'ММ/ГГ',
      'expiry_required': 'Введите срок действия',
      'expiry_invalid': 'Формат ММ/ГГ',
      'expiry_invalid_month': 'Месяц должен быть 01–12',
      'expiry_expired': 'Срок действия карты истёк',
      'card_color': 'Цвет Карты',
      'add_card': 'Добавить',

      'expiry_date_label': 'Срок Действия',

      'dark_mode': 'Тёмная тема',
      'language': 'Язык',
      
      'date_june_14_2020': '14 июня 2020',
      'date_june_14': '14 июня',
      'date_june_28': '28 июня',
      'date_aug_28': '28 авг',
      
      'corporate_app': 'Корпоративное',
      'security_settings': 'Безопасность',
      'online_shopping': 'Покупки',
      'groceries': 'Продукты',
      'utilities': 'Утилиты',
      'thumb_scanner': 'Сканер',
      'settings': 'Настройки',

      'exchange_rates': 'Курсы Валют',
      'no_connection': 'Нет подключения к интернету',
      'cached_data': 'Показаны кэшированные данные',
      'rates_error': 'Не удалось загрузить курсы',

      // ── Поиск / Фильтр / Сортировка ────────────────────────────────────────
      'search': 'Поиск',
      'search_hint': 'Поиск карт и транзакций…',
      'filter_all': 'Все',
      'filter_food': 'Еда',
      'filter_transfer': 'Переводы',
      'filter_shopping': 'Покупки',
      'filter_utilities': 'Коммунальные',
      'filter_other': 'Прочее',
      'sort_by': 'Сортировка',
      'sort_date': 'Дата',
      'sort_amount': 'Сумма',
      'sort_name': 'Название',
      'date_range': 'Период',
      'no_results': 'Ничего не найдено',
      'cards_section': 'Карты',
      'transactions_section': 'Транзакции',
      'clear_filters': 'Очистить',

      // ── Уведомления ─────────────────────────────────────────────────────────
      'notifications': 'Уведомления',
      'no_notifications': 'Нет запланированных уведомлений',
      'add_notification': 'Новое напоминание',
      'notification_title': 'Заголовок',
      'notification_title_hint': 'напр. Проверить баланс',
      'notification_body': 'Сообщение',
      'notification_body_hint': 'напр. Проверьте расходы за неделю',
      'notification_default_body': 'Напоминание MyFinance',
      'notification_repeat': 'Повтор',
      'repeat_once': 'Раз',
      'repeat_daily': 'Ежедневно',
      'repeat_weekly': 'Еженедельно',
      'notification_time': 'Время',
      'notification_date': 'Дата',
      'notification_weekday': 'День недели',
      'delete_notification': 'Удалить напоминание',
      'schedule': 'Запланировать',
      'mon': 'Пн',
      'tue': 'Вт',
      'wed': 'Ср',
      'thu': 'Чт',
      'fri': 'Пт',
      'sat': 'Сб',
      'sun': 'Вс',

      // ── Firebase / ImageKit ─────────────────────────────────────────────────
      'upload_image': 'Загрузить изображение',
      'uploading': 'Загрузка…',
      'upload_failed': 'Ошибка загрузки',
      'firebase_sync': 'Облачная синхронизация',
    },
  };
}
