import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/colors.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/screens/cards.dart';
import 'package:my_app/screens/drawer.dart';
import 'package:my_app/screens/notifications_screen.dart';
import 'package:my_app/screens/search_screen.dart';
import 'package:my_app/screens/settings.dart';
import 'package:my_app/viewmodels/exchange_rate_viewmodel.dart';
import 'package:my_app/widgets/bottombarItems.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int touchedIndex = -1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final resHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerScreen(),

      // ── App bar ────────────────────────────────────────────────────────
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState!.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/images/menu.png',
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.onSurface),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: kPrimary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset('assets/images/user.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: SafeArea(
        child: Column(
          children: [
            // Connectivity banner
            Consumer<ExchangeRateViewModel>(
              builder: (context, vm, _) {
                if (vm.isOnline) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  color: kDanger,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        t.get('no_connection'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'PoppinsRegular',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SizedBox(height: resHeight * 0.02),

                  // Section header
                  Text(
                    t.get('your_balance'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: resHeight * 0.018),

                  // ── Balance card ────────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CardScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: kGradientPrimary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.get('date_june_14_2020'),
                                style: TextStyle(
                                  fontFamily: 'PoppinsLight',
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '\$27,802.05',
                                style: TextStyle(
                                  fontFamily: 'PoppinsBold',
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: kSuccess.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.trending_up,
                                    color: Colors.greenAccent, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '15%',
                                  style: TextStyle(
                                    fontFamily: 'PoppinsMedium',
                                    fontSize: 13,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: resHeight * 0.025),

                  // ── Quick actions ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickAction(
                        icon: Icons.arrow_upward_rounded,
                        label: t.get('send'),
                        color: kPrimary,
                      ),
                      _QuickAction(
                        icon: Icons.arrow_downward_rounded,
                        label: t.get('receive'),
                        color: kSuccess,
                      ),
                      _QuickAction(
                        icon: Icons.compare_arrows_rounded,
                        label: t.get('services'),
                        color: kGold,
                      ),
                      _QuickAction(
                        icon: Icons.bolt_rounded,
                        label: t.get('pay_bill'),
                        color: kCyan,
                      ),
                    ],
                  ),
                  SizedBox(height: resHeight * 0.025),

                  // ── Exchange rates ─────────────────────────────────────
                  const _ExchangeRateCard(),
                  SizedBox(height: resHeight * 0.025),

                  // ── Activities header ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.get('activities'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.get('this_week'),
                          style: const TextStyle(
                            fontFamily: 'PoppinsMedium',
                            fontSize: 12,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: resHeight * 0.02),

                  // ── Bar chart ──────────────────────────────────────────
                  Container(
                    height: resHeight * 0.28,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: BarChart(mainBarData()),
                  ),
                  SizedBox(height: resHeight * 0.025),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom navigation ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 0),
            _navItem(Icons.notifications_outlined, 1, onTap: () {
              setState(() => bottomIndex = 1);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            }),
            _navItem(Icons.chat_bubble_outline_rounded, 2),
            _navItem(Icons.settings_outlined, 3, onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => setState(() => bottomIndex = index),
      child: BottomItems(active: bottomIndex == index, icon: icon),
    );
  }

  // ── Bar chart data (logic unchanged) ──────────────────────────────────────

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    Color barColor = kPrimary,
    double width = 14,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: touchedIndex == x ? kPrimary2 : barColor,
          width: width,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 15,
            color: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        const data = [5.0, 6.5, 5.0, 7.5, 9.0, 11.5, 6.5];
        return makeGroupData(i, data[i]);
      });

  BarChartData mainBarData() {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final months = [
      t.get('jan'),
      t.get('feb'),
      t.get('march'),
      t.get('april'),
      t.get('may'),
      t.get('jun'),
      t.get('jul'),
    ];

    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => colorScheme.surface,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${months[group.x]}\n',
              TextStyle(
                color: colorScheme.onSurface,
                fontFamily: 'PoppinsMedium',
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: const TextStyle(
                    color: kPrimary,
                    fontSize: 14,
                    fontFamily: 'PoppinsBold',
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= months.length) return const SizedBox();
              return SideTitleWidget(
                meta: meta,
                space: 10,
                child: Text(
                  months[idx],
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'PoppinsRegular',
                    fontSize: 11,
                  ),
                ),
              );
            },
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }
}

// ── Quick action button ──────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PoppinsRegular',
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Exchange Rate Card ──────────────────────────────────────────────────────

class _ExchangeRateCard extends StatelessWidget {
  const _ExchangeRateCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Consumer<ExchangeRateViewModel>(
      builder: (context, vm, _) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: kCyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.currency_exchange,
                            size: 16, color: kCyan),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        t.get('exchange_rates'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (vm.isFromCache)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Tooltip(
                            message: t.get('cached_data'),
                            child: const Icon(Icons.cached,
                                size: 16, color: kGold),
                          ),
                        ),
                      if (vm.status != ExchangeRateStatus.loading)
                        GestureDetector(
                          onTap: vm.fetchRates,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.refresh,
                                size: 16, color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBody(context, vm, t),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext ctx, ExchangeRateViewModel vm, AppLocalizations t) {
    switch (vm.status) {
      case ExchangeRateStatus.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
          ),
        );
      case ExchangeRateStatus.offline:
        if (vm.rates == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.wifi_off, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(t.get('no_connection'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }
        return _buildRates(ctx, vm, t);
      case ExchangeRateStatus.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(t.get('rates_error'),
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        );
      case ExchangeRateStatus.loaded:
        return _buildRates(ctx, vm, t);
    }
  }

  Widget _buildRates(
      BuildContext ctx, ExchangeRateViewModel vm, AppLocalizations t) {
    final rates = vm.rates!;
    final colorScheme = Theme.of(ctx).colorScheme;
    final currencyIcons = <String, String>{
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
    };

    return Column(
      children: [
        ...rates.rates.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                // Currency symbol badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      currencyIcons[e.key] ?? e.key[0],
                      style: const TextStyle(
                        fontFamily: 'PoppinsBold',
                        fontSize: 14,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${rates.base} → ${e.key}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontFamily: 'PoppinsRegular',
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  e.value.toStringAsFixed(4),
                  style: const TextStyle(
                    color: kPrimary,
                    fontFamily: 'PoppinsMedium',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (vm.isFromCache)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${t.get('cached_data')} · ${rates.date}',
              style: const TextStyle(
                color: kGold,
                fontSize: 10,
                fontFamily: 'PoppinsLight',
              ),
            ),
          ),
      ],
    );
  }
}
