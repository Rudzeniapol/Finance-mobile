import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/viewmodels/cards_viewmodel.dart';
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
    _pageController = PageController(viewportFraction: 0.95);
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
        title: Text(t.get('delete_card'),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          t.get('delete_card_confirm'),
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.get('delete'),
                style: const TextStyle(color: Colors.redAccent)),
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

  Widget _buildCardSection(CardsViewModel vm, double resHeight) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    if (vm.isLoading) {
      return const ShimmerCardLoading();
    }
    if (vm.cards.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card_off, color: Colors.grey[600], size: 40),
              const SizedBox(height: 8),
              Text(
                t.get('no_cards_yet'),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: "PoppinsLight",
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.get('tap_to_add'),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: "PoppinsLight",
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
        onPageChanged: (index) => _currentPage = index,
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

  @override
  Widget build(BuildContext context) {
    final resHeight = MediaQuery.of(context).size.height;
    final t = AppLocalizations.of(context);

    return Consumer<CardsViewModel>(
      builder: (context, vm, _) => Scaffold(
        appBar: AppBar(
          actions: const [
            Icon(Icons.more_vert, size: 25),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(left: 10, right: 10),
          children: [
            SizedBox(height: resHeight * 0.025),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('your_cards'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      _cardCountText(context, vm.count),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                MaterialButton(
                  onPressed: () => _addCard(vm),
                  color: const Color(0xffffd674),
                  textColor: Colors.black,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8.0),
                  minWidth: 0,
                  child: const Icon(Icons.add, size: 30),
                ),
              ],
            ),
            SizedBox(height: resHeight * 0.025),
            _buildCardSection(vm, resHeight),
            SizedBox(height: resHeight * 0.025),
            Text(
              t.get('recent_transactions'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: resHeight * 0.025),
            TransactionWidget(
              ammount: "+\$2,010",
              date: t.get('date_june_14'),
              image: 'assets/images/burger.png',
              title: "KFC",
            ),
            SizedBox(height: resHeight * 0.015),
            TransactionWidget(
              ammount: "+\$12,010",
              date: t.get('date_june_28'),
              image: 'assets/images/paypal.png',
              title: "Paypal",
            ),
            SizedBox(height: resHeight * 0.015),
            TransactionWidget(
              ammount: "+\$232,010",
              date: t.get('date_aug_28'),
              image: 'assets/images/maintenance.png',
              title: "Car Repair",
            ),
          ],
        ),
      ),
    );
  }
}
