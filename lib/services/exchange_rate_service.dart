import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/models/exchange_rate.dart';

class ExchangeRateService {
  static const _cacheKey = 'exchange_rate_cache';
  static const _cacheTimeKey = 'exchange_rate_cache_time';
  static const _cacheMaxAge = Duration(hours: 1);
  static const _apiUrl =
      'https://api.frankfurter.app/latest?from=USD&to=EUR,GBP,JPY';

  static Future<ExchangeRate?> fetchRates() async {
    final response = await http.get(Uri.parse(_apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ExchangeRate.fromJson(data);
    }
    return null;
  }

  static Future<void> cacheRates(ExchangeRate rates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, ExchangeRate.encode(rates));
    await prefs.setInt(
        _cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<ExchangeRate?> getCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    return ExchangeRate.decode(jsonString);
  }

  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheTime = prefs.getInt(_cacheTimeKey);
    if (cacheTime == null) return false;
    final age = DateTime.now().millisecondsSinceEpoch - cacheTime;
    return age < _cacheMaxAge.inMilliseconds;
  }
}
