import 'dart:ui';

/// Groups pins whose on-screen positions are within [threshold] pixels of an
/// existing group, so a dense area can be drawn as one numbered badge instead
/// of a stack of pins.
///
/// Grouping is greedy and order-stable: each point joins the first group whose
/// seed point (its first member) is within [threshold], otherwise it starts a
/// new group. Comparing against the seed rather than *any* member keeps groups
/// compact, so a long line of pins 19px apart does not chain into one badge
/// spanning the whole map. Every input index appears exactly once.
List<List<int>> clusterIndexes(
  List<Offset> screenPoints, {
  double threshold = 20,
}) {
  final List<List<int>> groups = [];

  for (var i = 0; i < screenPoints.length; i++) {
    List<int>? target;
    for (final group in groups) {
      final seed = screenPoints[group.first];
      if ((seed - screenPoints[i]).distance <= threshold) {
        target = group;
        break;
      }
    }
    if (target == null) {
      groups.add([i]);
    } else {
      target.add(i);
    }
  }

  return groups;
}
