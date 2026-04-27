import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/models/payment_card.dart';

class AddCardSheet extends StatefulWidget {
  const AddCardSheet({super.key});

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();

  // Six gradient pairs — each maps to a card theme
  static const List<List<Color>> _gradients = [
    [Color(0xFF4C6EF5), Color(0xFF845EF7)], // indigo-violet
    [Color(0xFF11998E), Color(0xFF38EF7D)], // teal-green
    [Color(0xFFEB3349), Color(0xFFF45C43)], // red-coral
    [Color(0xFF6A11CB), Color(0xFF2575FC)], // purple-blue
    [Color(0xFFFF8C00), Color(0xFFFFD700)], // amber-gold
    [Color(0xFF1F2A40), Color(0xFF3D4F70)], // slate-navy
  ];

  // Store solid colour for card (derived from gradient start)
  int _selectedIndex = 0;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final card = PaymentCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardNumber: _cardNumberController.text.trim(),
      cardholderName: _nameController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      colorValue: _gradients[_selectedIndex][0].toARGB32(),
    );
    Navigator.pop(context, card);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Card preview mini
              _CardPreview(
                gradient: _gradients[_selectedIndex],
                number: _cardNumberController.text.isEmpty
                    ? '•••• •••• •••• ••••'
                    : _cardNumberController.text,
                name: _nameController.text.isEmpty
                    ? t.get('cardholder_hint')
                    : _nameController.text.toUpperCase(),
                expiry: _expiryController.text.isEmpty
                    ? '••/••'
                    : _expiryController.text,
              ),
              const SizedBox(height: 24),

              Text(t.get('add_new_card'),
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),

              // Card number
              _buildField(
                controller: _cardNumberController,
                label: t.get('card_number'),
                hint: t.get('card_number_hint'),
                icon: Icons.credit_card_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                maxLength: 19,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.get('card_number_required');
                  }
                  final digits = value.replaceAll(RegExp(r'\s'), '');
                  if (!RegExp(r'^\d+$').hasMatch(digits)) {
                    return t.get('card_number_digits_only');
                  }
                  if (digits.length != 16) return t.get('card_number_invalid');
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Cardholder name
              _buildField(
                controller: _nameController,
                label: t.get('cardholder_name'),
                hint: t.get('cardholder_hint'),
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.get('name_required');
                  }
                  final trimmed = value.trim();
                  if (trimmed.length < 2) return t.get('name_too_short');
                  if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$').hasMatch(trimmed)) {
                    return t.get('name_letters_only');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Expiry date
              _buildField(
                controller: _expiryController,
                label: t.get('expiry_date'),
                hint: t.get('expiry_hint'),
                icon: Icons.calendar_month_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryDateFormatter(),
                ],
                maxLength: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.get('expiry_required');
                  }
                  final trimmed = value.trim();
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(trimmed)) {
                    return t.get('expiry_invalid');
                  }
                  final parts = trimmed.split('/');
                  final month = int.parse(parts[0]);
                  final year = int.parse(parts[1]);
                  if (month < 1 || month > 12) return t.get('expiry_invalid_month');
                  final now = DateTime.now();
                  if (year < now.year % 100 ||
                      (year == now.year % 100 && month < now.month)) {
                    return t.get('expiry_expired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Colour / gradient picker
              Text(t.get('card_color'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_gradients.length, (i) {
                  final isSelected = i == _selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _gradients[i],
                        ),
                        border: isSelected
                            ? Border.all(color: colorScheme.onSurface, width: 2.5)
                            : Border.all(color: Colors.transparent, width: 2.5),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _gradients[i][0].withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(t.get('add_card')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      onChanged: (_) => setState(() {}), // refresh card preview
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontFamily: 'PoppinsRegular',
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: Icon(icon, size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

// ── Live card preview ─────────────────────────────────────────────────────────

class _CardPreview extends StatelessWidget {
  final List<Color> gradient;
  final String number;
  final String name;
  final String expiry;

  const _CardPreview({
    required this.gradient,
    required this.number,
    required this.name,
    required this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Chip placeholder
            Container(
              width: 36,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Card number
            Text(
              number,
              style: const TextStyle(
                fontFamily: 'PoppinsMedium',
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            // Bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'PoppinsRegular',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  expiry,
                  style: const TextStyle(
                    fontFamily: 'PoppinsMedium',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Input formatters ──────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
