import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/models/crowd_report_model.dart';
import 'package:metropulse/services/crowd_report_service.dart';
import 'package:metropulse/state/location_providers.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:metropulse/theme.dart';
// crowd_badge not required in this file

/// Call this to open the bottom sheet.
Future<void> showReportCrowdSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _ReportCrowdContent(),
  );
}

class _ReportCrowdContent extends ConsumerStatefulWidget {
  const _ReportCrowdContent();
  @override
  ConsumerState<_ReportCrowdContent> createState() => _ReportCrowdContentState();
}

class _ReportCrowdContentState extends ConsumerState<_ReportCrowdContent> {
  int selectionIndex = 2; // center by default
  final List<String> emojis = const ['😌', '🙂', '😐', '😟', '😫'];
  final List<String> labels = const ['Empty', 'Light', 'Moderate', 'Busy', 'Packed'];
  final Set<int> coachIndices = {};
  late final ConfettiController _confettiController;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _submit(String stationId, {String? userId}) async {
    setState(() => submitting = true);
    final now = DateTime.now();
    final levelValue = selectionIndex + 1; // 1..5 scale
    final report = CrowdReportModel(
      stationId: stationId,
      userId: userId,
      crowdLevelValue: levelValue,
      coachPosition: coachIndices.isEmpty ? null : coachIndices.join(','),
      createdAt: now,
    );
    // Optimistic local update so the map reflects the user's report immediately.
    try {
      final uiLevel = CrowdReportModel.toUiLevel(levelValue);
      addLocalCrowdOverride(stationId, uiLevel, ttl: const Duration(seconds: 30));
    } catch (_) {}
    await CrowdReportService.submitReport(report);
    if (!mounted) return;
    _confettiController.play();
    setState(() => submitting = false);
    // Sweet success UI
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        content: SizedBox(
          height: 160,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [Colors.purple, Colors.amber, Colors.green, Colors.red, Colors.blue],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Thanks for reporting! 🎉', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('+10 points added to your profile'),
                ],
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    ).then((_) {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stationAsync = ref.watch(currentStationProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Report Crowd', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 8),
            stationAsync.when(
              data: (station) => Text(
                station != null ? "You're at: ${station.name}" : "Select station",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
              ),
              loading: () => const Text('Detecting location...'),
              error: (_, __) => const Text('Location unavailable'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(emojis.length, (i) {
                final isSelected = selectionIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => selectionIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? MPColors.purple : Theme.of(context).colorScheme.surface,
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.25)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emojis[i], style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Text('Coach position (optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(6, (i) {
                final selected = coachIndices.contains(i);
                return FilterChip(
                  label: Text('Coach ${i + 1}'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        coachIndices.remove(i);
                      } else {
                        coachIndices.add(i);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: MPDecorations.purpleHeaderGradient,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: ElevatedButton(
                  onPressed: submitting || stationAsync.asData?.value == null
                      ? null
                      : () => _submit(stationAsync.asData!.value!.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Report'),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


