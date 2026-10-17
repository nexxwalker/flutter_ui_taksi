import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_taksi/screens/pick_up/components/pin_clustering.dart';

void main() {
  test('no points produce no groups', () {
    expect(clusterIndexes(const []), isEmpty);
  });

  test('distant pins each get their own group', () {
    final groups = clusterIndexes(
      const [Offset(0, 0), Offset(200, 0), Offset(0, 200)],
      threshold: 40,
    );
    expect(groups, [
      [0],
      [1],
      [2],
    ]);
  });

  test('pins inside the threshold collapse into one group', () {
    final groups = clusterIndexes(
      const [Offset(0, 0), Offset(20, 0), Offset(0, 20)],
      threshold: 40,
    );
    expect(groups, [
      [0, 1, 2],
    ]);
  });

  test('grouping is greedy and keeps input order', () {
    // 30px apart with a 20px threshold: 15 joins 0, 30 is too far from 0.
    final groups = clusterIndexes(
      const [Offset(0, 0), Offset(15, 0), Offset(30, 0)],
      threshold: 20,
    );
    expect(groups, [
      [0, 1],
      [2],
    ]);
  });

  test('every index appears exactly once', () {
    final points = [for (var i = 0; i < 25; i++) Offset(i * 7 % 50, i * 11 % 40)];
    final groups = clusterIndexes(points, threshold: 12);
    final flattened = groups.expand((group) => group).toList()..sort();
    expect(flattened, List.generate(points.length, (index) => index));
  });
}
