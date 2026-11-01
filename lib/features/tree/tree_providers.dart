import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/config.dart';
import '../../core/utils/circle_providers.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';
import '../../data/repositories/tree_repository.dart';

final treePersonsProvider = StreamProvider<List<TreePerson>>((ref) {
  if (AppConfig.useMockData) {
    return Stream.value(MockData.persons);
  }
  final circle = ref.watch(myCircleProvider).value;
  if (circle == null) return Stream.value(const <TreePerson>[]);
  return ref.watch(treeRepositoryProvider).watchPersons(circle.id);
});

/// Convenience list used by sync widgets while the tree loads.
final treePersonsValueProvider = Provider<List<TreePerson>>((ref) {
  return ref.watch(treePersonsProvider).value ?? const <TreePerson>[];
});
