import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/models/crowd_report_model.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

void main() {
  test('local override emits when added', () async {
    final container = ProviderContainer();
    addTearDown(() => container.dispose());

    final events = <Map<String, CrowdLevel>>[];
    final sub = container.listen(localCrowdOverridesProvider, (prev, next) {
      next.maybeWhen(data: (m) => events.add(m), orElse: () {});
    }, fireImmediately: false);

    // Start by adding an optimistic override
    addLocalCrowdOverride('S1', CrowdLevel.high, ttl: const Duration(seconds: 30));

    // Give the event loop a tick to process the broadcast
    await Future.delayed(const Duration(milliseconds: 50));

    expect(events.isNotEmpty, true);
    expect(events.last.containsKey('S1'), true);

    sub.close();
  });

  test('aggregated coach provider splits comma-separated coach positions', () async {
    final report1 = CrowdReportModel(
      id: 'r2',
      stationId: 'S2',
      userId: 'u2',
      crowdLevelValue: 5,
      coachPosition: '0,2',
      createdAt: DateTime.now(),
    );

    final container = ProviderContainer(overrides: [
      liveReportsProvider.overrideWithValue(const AsyncValue.data([/* placeholder */]) ),
    ]);

    // It's easier to build the provider using the reports directly by creating
    // a ProviderContainer with the liveReportsProvider overridden as AsyncValue.data
    // and then reading the aggregated provider after injecting the reports via
    // recreating the container. We'll instead create a new container in which
    // the provider will compute based on a single synchronous emission.
    final container2 = ProviderContainer(overrides: [
      liveReportsProvider.overrideWithValue(AsyncValue.data([report1])),
    ]);

    addTearDown(() {
      container.dispose();
      container2.dispose();
    });

    final coachMap = container2.read(aggregatedCrowdByStationCoachProvider);

    expect(coachMap.containsKey('S2'), true);
    expect(coachMap['S2']!.containsKey('0'), true);
    expect(coachMap['S2']!.containsKey('2'), true);
    expect(coachMap['S2']!['0'], CrowdLevel.high);
    expect(coachMap['S2']!['2'], CrowdLevel.high);
  });
}
