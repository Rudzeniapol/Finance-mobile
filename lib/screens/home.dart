import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_app/helpers/colors.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/screens/cards.dart';
import 'package:my_app/screens/drawer.dart';
import 'package:my_app/screens/settings.dart';
import 'package:my_app/widgets/bottombarItems.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int touchedIndex = -1;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final res_width = MediaQuery.of(context).size.width;
    final res_height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerScreen(),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/menu.png',
              color: colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset(
              'assets/images/user.png',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(left: 10, right: 10),
          children: [
            SizedBox(
              height: res_height * 0.025,
            ),
            Text(
              t.get('your_balance'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              height: res_height * 0.025,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardScreen()),
                );
              },
              child: Container(
                height: res_height * 0.125,
                decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.get('date_june_14_2020'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "\$27,802.05",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "15%",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_upward,
                            color: colorScheme.onSurface,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: res_height * 0.025,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.arrow_upward,
                      color: kprimarycolor,
                      size: 35,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.arrow_downward,
                      color: kprimarycolor,
                      size: 35,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.food_bank,
                      color: kprimarycolor,
                      size: 35,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.charging_station_rounded,
                      color: kprimarycolor,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: res_height * 0.025,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.get('activities'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Container(
                  width: res_width * 0.25,
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        t.get('this_week'),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: res_height * 0.025,
            ),
            Container(
              height: res_height * 0.3,
              child: BarChart(
                mainBarData(),
              ),
            ),
            SizedBox(
              height: res_height * 0.025,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
        child: Container(
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      bottomIndex = 0;
                    });
                  },
                  child: BottomItems(
                      active: bottomIndex == 0 ? true : false,
                      icon: Icons.home),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      bottomIndex = 1;
                    });
                  },
                  child: BottomItems(
                      active: bottomIndex == 1 ? true : false,
                      icon: Icons.notifications),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      bottomIndex = 2;
                    });
                  },
                  child: BottomItems(
                      active: bottomIndex == 2 ? true : false,
                      icon: Icons.chat_bubble),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  },
                  child: BottomItems(
                      active: bottomIndex == 3 ? true : false,
                      icon: Icons.settings),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    Color barColor = kprimarycolor,
    double width = 15,
    List<int> showTooltips = const [],
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: width,
          borderSide: BorderSide(color: colorScheme.onSurface, width: 1),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 15,
            color: colorScheme.surface,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5);
          case 1:
            return makeGroupData(1, 6.5);
          case 2:
            return makeGroupData(2, 5);
          case 3:
            return makeGroupData(3, 7.5);
          case 4:
            return makeGroupData(4, 9);
          case 5:
            return makeGroupData(5, 11.5);
          case 6:
            return makeGroupData(6, 6.5);
          default:
            return throw Error();
        }
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
          getTooltipColor: (BarChartGroupData group) => colorScheme.surface,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final weekDay = months[group.x];
            return BarTooltipItem(
              '$weekDay\n',
              TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: const TextStyle(
                    color: kprimarycolor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final style = TextStyle(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    final months = [
      t.get('jan'),
      t.get('feb'),
      t.get('march'),
      t.get('april'),
      t.get('may'),
      t.get('jun'),
      t.get('jul'),
    ];
    final idx = value.toInt();
    final text = idx >= 0 && idx < months.length
        ? Text(months[idx], style: style)
        : Text('', style: style);
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: text,
    );
  }
}
