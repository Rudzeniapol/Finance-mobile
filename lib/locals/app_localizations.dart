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
    },
  };
}
