import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/colors.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/screens/search_screen.dart';
import 'package:my_app/viewmodels/cards_viewmodel.dart';
import 'package:my_app/viewmodels/transaction_viewmodel.dart';
import 'package:my_app/widgets/add_card_sheet.dart';
import 'package:my_app/widgets/payment_card_widget.dart';
import 'package:my_app/widgets/shimmer_loading.dart';
import 'package:my_app/widgets/transactioncard.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addCard(CardsViewModel vm) async {
    final card = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddCardSheet(),
    );
    if (card != null) {
      await vm.addCard(card);
    }
  }

  Future<void> _deleteCard(CardsViewModel vm, int index) async {
    final t = AppLocalizations.of(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.get('delete_card'),
            style: TextStyle(
                fontFamily: 'PoppinsMedium',
                color: colorScheme.onSurface)),
        content: Text(
          t.get('delete_card_confirm'),
          style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontFamily: 'PoppinsRegular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.get('cancel'),
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.get('delete'),
                style: const TextStyle(
                    color: kDanger, fontFamily: 'PoppinsMedium')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final newCount = vm.count - 1;
      if (newCount == 0) {
        _currentPage = 0;
      } else if (_currentPage >= newCount) {
        _currentPage = newCount - 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentPage);
          }
        });
      }
      await vm.deleteCard(index);
    }
  }

  String _cardCountText(BuildContext context, int count) {
    final t = AppLocalizations.of(context);
    if (count == 0) return t.get('no_active_cards');
    if (count == 1) return t.get('you_have_1_card');
    return t.get('you_have_n_cards').replaceAll('{count}', count.toString());
  }

  Widget _buildCardSection(CardsViewModel vm) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (vm.isLoading) {
      return const ShimmerCardLoading();
    }

    if (vm.cards.isEmpty) {
      return Container(
        height: 190,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.credit_card_off_rounded,
                    color: colorScheme.onSurfaceVariant, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                t.get('no_cards_yet'),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontFamily: 'PoppinsMedium',
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.get('tap_to_add'),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'PoppinsLight',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: vm.cards.length,
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PaymentCardWidget(
              card: vm.cards[index],
              onDelete: () => _deleteCard(vm, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    if (count <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? kPrimary : kPrimary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTransactions(TransactionViewModel txVm, AppLocalizations t) {
    final colorScheme = Theme.of(context).colorScheme;

    if (txVm.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: kPrimary.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final transactions = txVm.transactions;
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(t.get('no_results'),
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'PoppinsLight')),
        ),
      );
    }

    return Column(
      children: transactions.map((tx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TransactionWidget(
            ammount: tx.formattedAmount,
            date: _formatDate(tx.date),
            image: tx.iconPath,
            title: tx.title,
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<CardsViewModel, TransactionViewModel>(
      builder: (context, vm, txVm, _) => Scaffold(
        appBar: AppBar(
          title: Text(t.get('your_cards')),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.search_rounded,
                    size: 20, color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),

            // ── Card count + add button ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cardCountText(context, vm.count),
                      style: TextStyle(
                        fontFamily: 'PoppinsRegular',
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _addCard(vm),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: kGold.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded,
                        size: 24, color: Colors.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Cards carousel ─────────────────────────────────────────────
            _buildCardSection(vm),
            _buildPageIndicator(vm.cards.length),

            const SizedBox(height: 28),

            // ── Transactions header ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.get('recent_transactions'),
                  style: const TextStyle(
                    fontFamily: 'PoppinsMedium',
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t.get('search'),
                      style: const TextStyle(
                        color: kPrimary,
                        fontSize: 12,
                        fontFamily: 'PoppinsMedium',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Transaction list ───────────────────────────────────────────
            _buildTransactions(txVm, t),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
