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

  static const List<Color> _colorOptions = [
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.orange,
    Colors.indigo,
    Color(0xffDAA520),
  ];

  int _selectedColorIndex = 0;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  /// Luhn algorithm to validate card numbers.
  static bool _luhnCheck(String digits) {
    int sum = 0;
    bool alternate = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final card = PaymentCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardNumber: _cardNumberController.text.trim(),
      cardholderName: _nameController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      colorValue: _colorOptions[_selectedColorIndex].toARGB32(),
    );

    Navigator.pop(context, card);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.get('add_new_card'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: _cardNumberController,
                label: t.get('card_number'),
                hint: t.get('card_number_hint'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                maxLength: 19, // 16 digits + 3 spaces
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.get('card_number_required');
                  }
                  final digits = value.replaceAll(RegExp(r'\s'), '');
                  if (!RegExp(r'^\d+$').hasMatch(digits)) {
                    return t.get('card_number_digits_only');
                  }
                  if (digits.length != 16) {
                    return t.get('card_number_invalid');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _nameController,
                label: t.get('cardholder_name'),
                hint: t.get('cardholder_hint'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.get('name_required');
                  }
                  final trimmed = value.trim();
                  if (trimmed.length < 2) {
                    return t.get('name_too_short');
                  }
                  if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$').hasMatch(trimmed)) {
                    return t.get('name_letters_only');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _expiryController,
                label: t.get('expiry_date'),
                hint: t.get('expiry_hint'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryDateFormatter(),
                ],
                maxLength: 5, // MM/YY
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
                  if (month < 1 || month > 12) {
                    return t.get('expiry_invalid_month');
                  }
                  final now = DateTime.now();
                  final currentYear = now.year % 100;
                  final currentMonth = now.month;
                  if (year < currentYear ||
                      (year == currentYear && month < currentMonth)) {
                    return t.get('expiry_expired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Text(
                t.get('card_color'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_colorOptions.length, (index) {
                  final isSelected = index == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = index),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _colorOptions[index],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: colorScheme.onSurface, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffffd674),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    t.get('add_card'),
                    style: const TextStyle(
                      fontFamily: "PoppinsMedium",
                      fontSize: 16,
                    ),
                  ),
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: TextStyle(color: colorScheme.onSurface, fontFamily: "PoppinsRegular"),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        labelStyle: TextStyle(color: Colors.grey[400], fontFamily: "PoppinsLight"),
        hintStyle: TextStyle(color: Colors.grey[600], fontFamily: "PoppinsLight"),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffffd674)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

/// Formats card number input as groups of 4 digits: "1234 5678 9012 3456"
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

/// Formats expiry input as "MM/YY" automatically inserting the slash.
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
