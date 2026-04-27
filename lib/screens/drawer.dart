import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/colors.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/screens/device_screen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/services/firebase_service.dart';
import 'package:my_app/viewmodels/auth_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthViewModel>();

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: kGradientPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: auth.isAuthenticated
                              ? Center(
                                  child: Text(
                                    auth.displayName.isNotEmpty
                                        ? auth.displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontFamily: 'PoppinsBold',
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/user.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    auth.isAuthenticated
                        ? auth.displayName
                        : 'Rudzenia Daniil',
                    style: const TextStyle(
                      fontFamily: 'PoppinsMedium',
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    auth.isAuthenticated
                        ? auth.email
                        : 'Jack of all trades dev',
                    style: TextStyle(
                      fontFamily: 'PoppinsLight',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Menu items ────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.business_outlined,
                    text: t.get('corporate_app'),
                    image: 'assets/images/corporation.png',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.shield_outlined,
                    text: t.get('security_settings'),
                    image: 'assets/images/policeman.png',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.shopping_bag_outlined,
                    text: t.get('online_shopping'),
                    image: 'assets/images/shopping-cart.png',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.local_grocery_store_outlined,
                    text: t.get('groceries'),
                    image: 'assets/images/food.png',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.build_outlined,
                    text: t.get('utilities'),
                    image: 'assets/images/tools.png',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.fingerprint,
                    text: t.get('thumb_scanner'),
                    image: 'assets/images/scanner.png',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.sensors_rounded,
                    text: t.get('device_features'),
                    image: 'assets/images/tools.png',
                    useIcon: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DeviceScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.share_rounded,
                    text: t.get('share_app'),
                    image: 'assets/images/tools.png',
                    useIcon: true,
                    onTap: () {
                      Navigator.pop(context);
                      Share.share(
                        'Check out MyFinance — smart money management app!',
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Sign out ─────────────────────────────────────────────────
            if (FirebaseService.isAvailable && auth.isAuthenticated)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _DrawerItem(
                  icon: Icons.logout_rounded,
                  text: t.get('sign_out'),
                  image: 'assets/images/scanner.png',
                  useIcon: true,
                  onTap: () async {
                    Navigator.pop(context);
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    }
                  },
                ),
              ),

            // ── Footer ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'MyFinance v1.0',
                style: TextStyle(
                  fontFamily: 'PoppinsLight',
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String image;
  final VoidCallback onTap;
  final bool useIcon;

  const _DrawerItem({
    required this.icon,
    required this.text,
    required this.image,
    required this.onTap,
    this.useIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: useIcon
              ? Icon(icon, color: colorScheme.onSurface, size: 20)
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    image,
                    color: colorScheme.onSurface,
                  ),
                ),
        ),
        title: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
