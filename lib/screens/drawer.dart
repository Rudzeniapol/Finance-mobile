import 'package:flutter/material.dart';
import 'package:my_app/locals/app_localizations.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final res_height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      child: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.only(left: 25, right: 10),
          children: [
            SizedBox(
              height: res_height * 0.075,
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.close,
                      color: colorScheme.onSurface,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 60,
                child: Image.asset(
                  'assets/images/user.png',
                ),
              ),
            ),
            SizedBox(
              height: res_height * 0.0175,
            ),
            Text(
              "Rudzenia Daniil",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              "Jack of all trades dev",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(
              height: res_height * 0.04,
            ),
            DrawerItems(
              text: t.get('corporate_app'),
              image: 'assets/images/corporation.png',
            ),
            DrawerItems(
              text: t.get('security_settings'),
              image: 'assets/images/policeman.png',
            ),
            DrawerItems(
              text: t.get('online_shopping'),
              image: 'assets/images/shopping-cart.png',
            ),
            DrawerItems(
              text: t.get('groceries'),
              image: 'assets/images/food.png',
            ),
            DrawerItems(
              text: t.get('utilities'),
              image: 'assets/images/tools.png',
            ),
            DrawerItems(
              text: t.get('thumb_scanner'),
              image: 'assets/images/scanner.png',
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItems extends StatelessWidget {
  final text;
  final image;
  const DrawerItems({super.key, required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.asset(
        image,
        color: colorScheme.onSurface,
        width: 30,
        height: 30,
      ),
      onTap: () {
        Navigator.pop(context);
      },
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
