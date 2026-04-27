import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/colors.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/screens/home.dart';
import 'package:my_app/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    bool success;
    if (_isRegister) {
      success = await auth.register(email, password);
    } else {
      success = await auth.signIn(email, password);
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kDarkBg, Color(0xFF1A1040), kPrimary2],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ──────────────────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: kGradientPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withValues(alpha: 0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MyFinance',
                    style: TextStyle(
                      fontFamily: 'PoppinsBold',
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Form card ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isRegister
                                ? t.get('register')
                                : t.get('sign_in'),
                            style: TextStyle(
                              fontFamily: 'PoppinsBold',
                              fontSize: 22,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRegister
                                ? t.get('create_account_subtitle')
                                : t.get('welcome_back'),
                            style: TextStyle(
                              fontFamily: 'PoppinsLight',
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: t.get('email'),
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return t.get('email_required');
                              }
                              if (!v.contains('@')) {
                                return t.get('email_invalid');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: t.get('password'),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return t.get('password_required');
                              }
                              if (v.length < 6) {
                                return t.get('password_too_short');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Error message
                          Consumer<AuthViewModel>(
                            builder: (_, auth, __) {
                              if (auth.error == null) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 4),
                                child: Text(
                                  auth.error!,
                                  style: const TextStyle(
                                    color: kDanger,
                                    fontFamily: 'PoppinsRegular',
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Submit button
                          Consumer<AuthViewModel>(
                            builder: (_, auth, __) {
                              return SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isRegister
                                              ? t.get('register')
                                              : t.get('sign_in'),
                                          style: const TextStyle(
                                            fontFamily: 'PoppinsMedium',
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Toggle mode
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isRegister
                                    ? t.get('already_have_account')
                                    : t.get('no_account'),
                                style: TextStyle(
                                  fontFamily: 'PoppinsRegular',
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<AuthViewModel>().clearError();
                                  setState(() => _isRegister = !_isRegister);
                                },
                                child: Text(
                                  _isRegister
                                      ? t.get('sign_in')
                                      : t.get('register'),
                                  style: const TextStyle(
                                    fontFamily: 'PoppinsMedium',
                                    fontSize: 13,
                                    color: kPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
