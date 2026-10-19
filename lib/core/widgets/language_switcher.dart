import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/locale_provider.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = ref.watch(localeProvider);
    final bool isAr = locale.languageCode == 'ar';

    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggle(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 6 : 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE9E4F5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EN',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isAr ? const Color(0xFFA599B5) : const Color(0xFF2B2433),
                    fontWeight: isAr ? FontWeight.w500 : FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 6),
            Container(width: 1, height: 14, color: const Color(0xFFE9E4F5)),
            const SizedBox(width: 6),
            Text(
              'ع',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isAr ? const Color(0xFF2B2433) : const Color(0xFFA599B5),
                    fontWeight: isAr ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
