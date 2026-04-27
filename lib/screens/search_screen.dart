import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/colors.dart';
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ListenableBuilder(
        listenable: _vm,
        builder: (ctx, _) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(t.get('sort_by'),
                  style: const TextStyle(
                      fontFamily: 'PoppinsMedium', fontSize: 16)),
              const SizedBox(height: 8),
              for (final field in SortField.values)
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _vm.sortField == field
                          ? kPrimary.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_sortIcon(field),
                        size: 18,
                        color: _vm.sortField == field
                            ? kPrimary
                            : colorScheme.onSurfaceVariant),
                  ),
                  title: Text(_sortLabel(field, t),
                      style: const TextStyle(fontFamily: 'PoppinsRegular')),
                  trailing: _vm.sortField == field
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                              _vm.sortDirection == SortDirection.asc
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: kPrimary,
                              size: 18),
                        )
                      : null,
                  onTap: () {
                    _vm.toggleSort(field);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _sortIcon(SortField f) => switch (f) {
        SortField.date => Icons.calendar_today_rounded,
        SortField.amount => Icons.attach_money_rounded,
        SortField.title => Icons.sort_by_alpha_rounded,
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
            final transactions =
                _vm.filterTransactions(txVm.transactions.toList());
            final hasResults = cards.isNotEmpty || transactions.isNotEmpty;

            return Scaffold(
              appBar: AppBar(
                title: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: t.get('search_hint'),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'PoppinsLight',
                        fontSize: 15),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: _vm.setQuery,
                ),
                actions: [
                  if (_vm.hasActiveFilters)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        _vm.clearAll();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: kDanger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(t.get('clear_filters'),
                            style: const TextStyle(
                                color: kDanger,
                                fontSize: 12,
                                fontFamily: 'PoppinsMedium')),
                      ),
                    ),
                ],
              ),
              body: Column(
                children: [
                  // ── Filter & sort bar ──────────────────────────────────────
                  _FilterBar(
                      vm: _vm,
                      onPickDate: () => _pickDateRange(context),
                      onSort: () => _showSortSheet(context, t),
                      t: t),

                  // ── Results ────────────────────────────────────────────────
                  Expanded(
                    child: _vm.query.isEmpty && !_vm.hasActiveFilters
                        ? _EmptySearch(t: t)
                        : !hasResults
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                          Icons.search_off_rounded,
                                          size: 28,
                                          color: colorScheme
                                              .onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(t.get('no_results'),
                                        style: TextStyle(
                                            color: colorScheme
                                                .onSurfaceVariant,
                                            fontFamily: 'PoppinsRegular')),
                                  ],
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  if (cards.isNotEmpty) ...[
                                    _SectionHeader(
                                        label: t.get('cards_section')),
                                    ...cards.map((c) => _CardTile(card: c)),
                                    const SizedBox(height: 12),
                                  ],
                                  if (transactions.isNotEmpty) ...[
                                    _SectionHeader(
                                        label:
                                            t.get('transactions_section')),
                                    ...transactions
                                        .map((tx) => _TransactionTile(tx: tx)),
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
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _CategoryChip(
                    label: t.get('filter_all'),
                    selected: vm.category == null,
                    onTap: () => vm.setCategory(null)),
                const SizedBox(width: 8),
                for (final cat in TransactionCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: _catLabel(cat, t),
                      selected: vm.category == cat,
                      onTap: () =>
                          vm.setCategory(vm.category == cat ? null : cat),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Date range + sort row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onPickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: vm.fromDate != null
                          ? kPrimary.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: vm.fromDate != null
                          ? Border.all(
                              color: kPrimary.withValues(alpha: 0.4),
                              width: 1)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range_rounded,
                            size: 15,
                            color: vm.fromDate != null
                                ? kPrimary
                                : colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          vm.fromDate != null
                              ? '${_fmt(vm.fromDate!)} – ${_fmt(vm.toDate!)}'
                              : t.get('date_range'),
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'PoppinsRegular',
                            color: vm.fromDate != null
                                ? kPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (vm.fromDate != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => vm.setDateRange(null, null),
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: kDanger),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort_rounded,
                            size: 15,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(t.get('sort_by'),
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'PoppinsRegular',
                                color: colorScheme.onSurfaceVariant)),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? kGradientPrimary : null,
          color: selected ? null : kPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : kPrimary,
            fontSize: 12,
            fontFamily: selected ? 'PoppinsMedium' : 'PoppinsRegular',
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
        padding: const EdgeInsets.only(bottom: 10, top: 4, left: 2),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'PoppinsMedium',
            fontSize: 11,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
}

class _CardTile extends StatelessWidget {
  final PaymentCard card;
  const _CardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(card.colorValue).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.credit_card_rounded,
                color: Color(card.colorValue), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.cardholderName,
                    style: const TextStyle(
                        fontFamily: 'PoppinsMedium', fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '**** **** **** ${card.cardNumber.replaceAll(' ', '').substring(12)}',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontFamily: 'PoppinsLight'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(card.expiryDate,
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontFamily: 'PoppinsRegular')),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final AppTransaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = tx.amount >= 0;
    final catColor = _catColor(tx.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_catIcon(tx.category), color: catColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: const TextStyle(
                        fontFamily: 'PoppinsMedium', fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '${tx.date.day.toString().padLeft(2, '0')}.${tx.date.month.toString().padLeft(2, '0')}.${tx.date.year}',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontFamily: 'PoppinsLight'),
                ),
              ],
            ),
          ),
          Text(
            tx.formattedAmount,
            style: TextStyle(
              color: isPositive ? kSuccess : kDanger,
              fontFamily: 'PoppinsMedium',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _catIcon(TransactionCategory c) => switch (c) {
        TransactionCategory.food => Icons.fastfood_rounded,
        TransactionCategory.transfer => Icons.swap_horiz_rounded,
        TransactionCategory.shopping => Icons.shopping_bag_rounded,
        TransactionCategory.utilities => Icons.bolt_rounded,
        TransactionCategory.other => Icons.receipt_rounded,
      };

  Color _catColor(TransactionCategory c) => switch (c) {
        TransactionCategory.food => kGold,
        TransactionCategory.transfer => kPrimary,
        TransactionCategory.shopping => kPrimary2,
        TransactionCategory.utilities => kCyan,
        TransactionCategory.other => kDarkMuted,
      };
}

class _EmptySearch extends StatelessWidget {
  final AppLocalizations t;
  const _EmptySearch({required this.t});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.search_rounded,
                size: 36, color: kPrimary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          Text(t.get('search_hint'),
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontFamily: 'PoppinsRegular')),
        ],
      ),
    );
  }
}
