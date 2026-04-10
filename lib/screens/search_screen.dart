import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/models/payment_card.dart';
import 'package:my_app/models/transaction.dart';
import 'package:my_app/viewmodels/cards_viewmodel.dart';
import 'package:my_app/viewmodels/search_viewmodel.dart';
import 'package:my_app/viewmodels/transaction_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  late final SearchViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SearchViewModel();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _vm.dispose();
    super.dispose();
  }

  // ── Date range picker ───────────────────────────────────────────────────────

  Future<void> _pickDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _vm.fromDate != null && _vm.toDate != null
          ? DateTimeRange(start: _vm.fromDate!, end: _vm.toDate!)
          : null,
    );
    if (range != null) {
      _vm.setDateRange(range.start, range.end);
    }
  }

  // ── Sort bottom sheet ───────────────────────────────────────────────────────

  void _showSortSheet(BuildContext context, AppLocalizations t) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListenableBuilder(
        listenable: _vm,
        builder: (ctx, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Text(t.get('sort_by'),
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final field in SortField.values)
              ListTile(
                leading: Icon(_sortIcon(field)),
                title: Text(_sortLabel(field, t)),
                trailing: _vm.sortField == field
                    ? Icon(
                        _vm.sortDirection == SortDirection.asc
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Colors.blue)
                    : null,
                onTap: () {
                  _vm.toggleSort(field);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _sortIcon(SortField f) => switch (f) {
        SortField.date => Icons.calendar_today,
        SortField.amount => Icons.attach_money,
        SortField.title => Icons.sort_by_alpha,
      };

  String _sortLabel(SortField f, AppLocalizations t) => switch (f) {
        SortField.date => t.get('sort_date'),
        SortField.amount => t.get('sort_amount'),
        SortField.title => t.get('sort_name'),
      };

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _vm,
      builder: (ctx, _) {
        return Consumer2<CardsViewModel, TransactionViewModel>(
          builder: (context, cardsVm, txVm, _) {
            final cards = _vm.filterCards(cardsVm.cards.toList());
            final transactions = _vm.filterTransactions(txVm.transactions.toList());
            final hasResults = cards.isNotEmpty || transactions.isNotEmpty;

            return Scaffold(
              appBar: AppBar(
                title: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: t.get('search_hint'),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: _vm.setQuery,
                ),
                actions: [
                  if (_vm.hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        _controller.clear();
                        _vm.clearAll();
                      },
                      child: Text(t.get('clear_filters'),
                          style: const TextStyle(color: Colors.redAccent)),
                    ),
                ],
              ),
              body: Column(
                children: [
                  // ── Filter & sort bar ──────────────────────────────────────
                  _FilterBar(vm: _vm, onPickDate: () => _pickDateRange(context),
                      onSort: () => _showSortSheet(context, t), t: t),

                  // ── Results ────────────────────────────────────────────────
                  Expanded(
                    child: _vm.query.isEmpty && !_vm.hasActiveFilters
                        ? _EmptySearch(t: t)
                        : !hasResults
                            ? Center(
                                child: Text(t.get('no_results'),
                                    style: TextStyle(color: Colors.grey[500])))
                            : ListView(
                                padding: const EdgeInsets.all(12),
                                children: [
                                  if (cards.isNotEmpty) ...[
                                    _SectionHeader(label: t.get('cards_section')),
                                    ...cards.map((c) => _CardTile(card: c,
                                        colorScheme: colorScheme)),
                                    const SizedBox(height: 8),
                                  ],
                                  if (transactions.isNotEmpty) ...[
                                    _SectionHeader(
                                        label: t.get('transactions_section')),
                                    ...transactions.map((tx) => _TransactionTile(
                                        tx: tx, colorScheme: colorScheme)),
                                  ],
                                ],
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final SearchViewModel vm;
  final VoidCallback onPickDate;
  final VoidCallback onSort;
  final AppLocalizations t;

  const _FilterBar({
    required this.vm,
    required this.onPickDate,
    required this.onSort,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _CategoryChip(
                    label: t.get('filter_all'),
                    selected: vm.category == null,
                    onTap: () => vm.setCategory(null)),
                const SizedBox(width: 6),
                for (final cat in TransactionCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _CategoryChip(
                      label: _catLabel(cat, t),
                      selected: vm.category == cat,
                      onTap: () => vm.setCategory(
                          vm.category == cat ? null : cat),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Date range + sort row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onPickDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: vm.fromDate != null
                          ? Colors.blue.withOpacity(0.15)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: vm.fromDate != null
                          ? Border.all(color: Colors.blue, width: 1)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.date_range, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          vm.fromDate != null
                              ? '${_fmt(vm.fromDate!)} – ${_fmt(vm.toDate!)}'
                              : t.get('date_range'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (vm.fromDate != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => vm.setDateRange(null, null),
                            child: const Icon(Icons.close,
                                size: 12, color: Colors.redAccent),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSort,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort, size: 14),
                        const SizedBox(width: 4),
                        Text(t.get('sort_by'),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime? d) => d == null
      ? ''
      : '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

  String _catLabel(TransactionCategory c, AppLocalizations t) => switch (c) {
        TransactionCategory.food => t.get('filter_food'),
        TransactionCategory.transfer => t.get('filter_transfer'),
        TransactionCategory.shopping => t.get('filter_shopping'),
        TransactionCategory.utilities => t.get('filter_utilities'),
        TransactionCategory.other => t.get('filter_other'),
      };
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.blue,
            fontSize: 12,
            fontFamily: 'PoppinsRegular',
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey[500])),
      );
}

class _CardTile extends StatelessWidget {
  final PaymentCard card;
  final ColorScheme colorScheme;
  const _CardTile({required this.card, required this.colorScheme});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(card.colorValue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.credit_card, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.cardholderName,
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '**** **** **** ${card.cardNumber.replaceAll(' ', '').substring(12)}',
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontFamily: 'PoppinsLight'),
                  ),
                ],
              ),
            ),
            Text(card.expiryDate,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      );
}

class _TransactionTile extends StatelessWidget {
  final AppTransaction tx;
  final ColorScheme colorScheme;
  const _TransactionTile({required this.tx, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.amount >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _catColor(tx.category).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_catIcon(tx.category),
                color: _catColor(tx.category), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '${tx.date.day}.${tx.date.month}.${tx.date.year}',
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontFamily: 'PoppinsLight'),
                ),
              ],
            ),
          ),
          Text(
            tx.formattedAmount,
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.redAccent,
              fontFamily: 'PoppinsMedium',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  IconData _catIcon(TransactionCategory c) => switch (c) {
        TransactionCategory.food => Icons.fastfood,
        TransactionCategory.transfer => Icons.swap_horiz,
        TransactionCategory.shopping => Icons.shopping_bag,
        TransactionCategory.utilities => Icons.bolt,
        TransactionCategory.other => Icons.receipt,
      };

  Color _catColor(TransactionCategory c) => switch (c) {
        TransactionCategory.food => Colors.orange,
        TransactionCategory.transfer => Colors.blue,
        TransactionCategory.shopping => Colors.purple,
        TransactionCategory.utilities => Colors.teal,
        TransactionCategory.other => Colors.grey,
      };
}

class _EmptySearch extends StatelessWidget {
  final AppLocalizations t;
  const _EmptySearch({required this.t});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(t.get('search_hint'),
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
}
