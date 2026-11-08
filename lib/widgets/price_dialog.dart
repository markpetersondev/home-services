import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Asks the provider for a job price. Returns null if they cancel.
Future<double?> showSetPriceDialog(BuildContext context) {
  return showDialog<double>(
    context: context,
    builder: (_) => const _SetPriceDialog(),
  );
}

class _SetPriceDialog extends StatefulWidget {
  const _SetPriceDialog();

  @override
  State<_SetPriceDialog> createState() => _SetPriceDialogState();
}

class _SetPriceDialogState extends State<_SetPriceDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final price = double.tryParse(_controller.text.trim());
    if (price == null || price <= 0) {
      setState(() => _error = 'Enter a price greater than 0');
      return;
    }
    Navigator.pop(context, price);
  }

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Set Job Price',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textPrimary),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          hintText: 'e.g. 3500',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 6, 14),
            child: Text(
              'Rs.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(),
          errorText: _error,
          filled: true,
          fillColor: AppColors.background,
          border: _border(AppColors.border),
          enabledBorder: _border(AppColors.border),
          focusedBorder: _border(AppColors.primary, 1.5),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _confirm,
          child: const Text(
            'Confirm',
            style: TextStyle(color: AppColors.statusInProgress),
          ),
        ),
      ],
    );
  }
}
