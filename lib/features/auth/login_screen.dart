import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/language_switcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+966';

  static const List<(String, String)> _countries = [
    ('+966', '🇸🇦 SA'),
    ('+971', '🇦🇪 AE'),
    ('+92', '🇵🇰 PK'),
    ('+965', '🇰🇼 KW'),
    ('+974', '🇶🇦 QA'),
    ('+973', '🇧🇭 BH'),
    ('+968', '🇴🇲 OM'),
    ('+20', '🇪🇬 EG'),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue(AppLocalizations l10n) {
    if (_phoneController.text.trim().isEmpty) return;
    context.go('/otp?phone=$_countryCode${_phoneController.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 80),
                  const LanguageSwitcher(compact: true),
                  const SizedBox(width: 80),
                ],
              ),
              const Spacer(),
              Text(l10n.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  GestureDetector(
                    onTap: _showCountryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: AhlColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AhlColors.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Text(_countryCode, style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(hintText: l10n.phoneHint),
                      onSubmitted: (_) => _continue(l10n),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AhlButton(label: l10n.continueBtn, onPressed: () => _continue(l10n)),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _countries.length,
            itemBuilder: (context, index) {
              final (code, flag) = _countries[index];
              return ListTile(
                leading: Text(flag, style: const TextStyle(fontSize: 20)),
                title: Text(code),
                selected: code == _countryCode,
                selectedColor: AhlColors.primary,
                onTap: () {
                  setState(() => _countryCode = code);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
