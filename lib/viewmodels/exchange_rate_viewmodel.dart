import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/models/exchange_rate.dart';
import 'package:my_app/services/connectivity_service.dart';
import 'package:my_app/services/exchange_rate_service.dart';

enum ExchangeRateStatus { loading, loaded, error, offline }

class ExchangeRateViewModel extends ChangeNotifier {
  ExchangeRate? _rates;
  ExchangeRateStatus _status = ExchangeRateStatus.loading;
  bool _isOnline = true;
  bool _isFromCache = false;
  StreamSubscription<bool>? _connectivitySub;

  ExchangeRate? get rates => _rates;
  ExchangeRateStatus get status => _status;
  bool get isOnline => _isOnline;
  bool get isFromCache => _isFromCache;

  ExchangeRateViewModel() {
    _init();
  }

  Future<void> _init() async {
    _isOnline = await ConnectivityService.isConnected();
    _connectivitySub = ConnectivityService.onConnectivityChanged.listen((online) {
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
        if (online) fetchRates();
      }
    });
    await fetchRates();
  }

  Future<void> fetchRates() async {
    _status = ExchangeRateStatus.loading;
    notifyListeners();

    if (_isOnline) {
      try {
        final rates = await ExchangeRateService.fetchRates();
        if (rates != null) {
          _rates = rates;
          _isFromCache = false;
          _status = ExchangeRateStatus.loaded;
          await ExchangeRateService.cacheRates(rates);
        } else {
          await _loadFromCache();
        }
      } catch (_) {
        await _loadFromCache();
      }
    } else {
      _status = ExchangeRateStatus.offline;
      await _loadFromCache();
    }

    notifyListeners();
  }

  Future<void> _loadFromCache() async {
    final cached = await ExchangeRateService.getCachedRates();
    if (cached != null) {
      _rates = cached;
      _isFromCache = true;
      _status = ExchangeRateStatus.loaded;
    } else {
      _status = _isOnline ? ExchangeRateStatus.error : ExchangeRateStatus.offline;
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
