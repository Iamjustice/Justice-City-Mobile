import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedPropertiesController extends StateNotifier<Set<String>> {
  SavedPropertiesController() : super(<String>{});

  bool contains(String listingId) {
    return state.contains(listingId.trim());
  }

  void toggle(String listingId) {
    final id = listingId.trim();
    if (id.isEmpty) return;
    final next = <String>{...state};
    if (!next.add(id)) {
      next.remove(id);
    }
    state = next;
  }

  void remove(String listingId) {
    final id = listingId.trim();
    if (id.isEmpty || !state.contains(id)) return;
    final next = <String>{...state}..remove(id);
    state = next;
  }

  void clear() {
    if (state.isEmpty) return;
    state = <String>{};
  }
}

final savedListingIdsProvider =
    StateNotifierProvider<SavedPropertiesController, Set<String>>(
  (ref) => SavedPropertiesController(),
);

final isListingSavedProvider = Provider.family<bool, String>((ref, listingId) {
  final id = listingId.trim();
  if (id.isEmpty) return false;
  return ref.watch(savedListingIdsProvider).contains(id);
});
