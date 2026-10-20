import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the active bottom navigation tab (Location, Tree, Safety, Chat,
/// Profile). Shared so in-screen shortcuts can switch tabs.
class ShellTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final shellTabProvider = NotifierProvider<ShellTabNotifier, int>(
  ShellTabNotifier.new,
);
