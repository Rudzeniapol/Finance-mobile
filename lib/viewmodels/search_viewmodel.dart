import 'package:flutter/material.dart';
import 'package:my_app/models/payment_card.dart';
import 'package:my_app/models/transaction.dart';
import 'package:my_app/utils/fuzzy_search.dart';

enum SortField { date, amount, title }

enum SortDirection { asc, desc }

/// Holds the current search query, category filter, date-range filter and
/// sort order. The actual filtering is done on-the-fly via [filterTransactions]
/// and [filterCards] — no data is stored here.
class SearchViewModel extends ChangeNotifier {
  String _query = '';
  TransactionCategory? _category; // null = all categories
  SortField _sortField = SortField.date;
  SortDirection _sortDirection = SortDirection.desc;
  DateTime? _fromDate;
  DateTime? _toDate;

  // ── Getters ─────────────────────────────────────────────────────────────────

  String get query => _query;
  TransactionCategory? get category => _category;
  SortField get sortField => _sortField;
  SortDirection get sortDirection => _sortDirection;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  bool get hasActiveFilters =>
      _query.isNotEmpty ||
      _category != null ||
      _fromDate != null ||
      _toDate != null;

  // ── Setters ─────────────────────────────────────────────────────────────────

  void setQuery(String q) {
    if (_query == q) return;
    _query = q;
    notifyListeners();
  }

  void setCategory(TransactionCategory? cat) {
    _category = cat;
    notifyListeners();
  }

  /// Toggles sort direction if the same field is selected twice.
  void toggleSort(SortField field) {
    if (_sortField == field) {
      _sortDirection = _sortDirection == SortDirection.asc
          ? SortDirection.desc
          : SortDirection.asc;
    } else {
      _sortField = field;
      _sortDirection = SortDirection.desc;
    }
    notifyListeners();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  void clearAll() {
    _query = '';
    _category = null;
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

  // ── Filtering ────────────────────────────────────────────────────────────────

  List<AppTransaction> filterTransactions(List<AppTransaction> all) {
    // 1. Fuzzy search
    var result = _query.isEmpty
        ? List<AppTransaction>.from(all)
        : FuzzySearch.search(
            _query, all, (t) => [t.title, t.category.name]);

    // 2. Category filter
    if (_category != null) {
      result = result.where((t) => t.category == _category).toList();
    }

    // 3. Date range
    if (_fromDate != null) {
      result = result.where((t) => !t.date.isBefore(_fromDate!)).toList();
    }
    if (_toDate != null) {
      final end = DateTime(
          _toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
      result = result.where((t) => !t.date.isAfter(end)).toList();
    }

    // 4. Sort
    result.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case SortField.date:
          cmp = a.date.compareTo(b.date);
        case SortField.amount:
          cmp = a.amount.compareTo(b.amount);
        case SortField.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      return _sortDirection == SortDirection.asc ? cmp : -cmp;
    });

    return result;
  }

  List<PaymentCard> filterCards(List<PaymentCard> all) {
    if (_query.isEmpty) return List.from(all);
    return FuzzySearch.search(
        _query, all, (c) => [c.cardholderName, c.cardNumber]);
  }
}
