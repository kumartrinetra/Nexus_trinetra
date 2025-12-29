import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/focusModel.dart';

class FocusController extends Notifier<FocusModel> {
  Timer? _timer;

  @override
  FocusModel build() {
    ref.onDispose(() => _timer?.cancel());

    return FocusModel(
      selectedDuration: const Duration(minutes: 25),
      remaining: const Duration(minutes: 25),
      isRunning: false,
      isPaused: false,
      sessionsCompleted: 0,
      pauses: 0,
      productivity: 100, // average productivity
      subject: "Deep Work",
    );
  }

  /* ---------------- SUBJECT ---------------- */

  void setSubject(String value) {
    if (state.isRunning) return;
    state = state.copyWith(
      subject: value.trim().isEmpty ? "Deep Work" : value.trim(),
    );
  }

  /* ---------------- DURATION ---------------- */

  void setDuration(Duration duration) {
    if (state.isRunning) return;

    state = state.copyWith(
      selectedDuration: duration,
      remaining: duration,
    );
  }

  /* ---------------- START ---------------- */

  void start() {
    _timer?.cancel();

    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      remaining: state.selectedDuration,
      pauses: 0, // reset pauses for THIS session
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remaining.inSeconds <= 1) {
        _completeSession();
      } else {
        state = state.copyWith(
          remaining: state.remaining - const Duration(seconds: 1),
        );
      }
    });
  }

  /* ---------------- PAUSE / RESUME ---------------- */

  void pause() {
    if (!state.isRunning || state.isPaused) return;

    _timer?.cancel();
    state = state.copyWith(
      isPaused: true,
      pauses: state.pauses + 1,
    );
  }

  void resume() {
    if (!state.isPaused) return;

    state = state.copyWith(isPaused: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remaining.inSeconds <= 1) {
        _completeSession();
      } else {
        state = state.copyWith(
          remaining: state.remaining - const Duration(seconds: 1),
        );
      }
    });
  }

  /* ---------------- STOP ---------------- */

  void stop() {
    _timer?.cancel();

    final currentSessionProductivity =
        (100 - state.pauses * 10).clamp(0, 100).toDouble();

    final totalSessions = state.sessionsCompleted + 1;

    final newAverageProductivity =
        ((state.sessionsCompleted * state.productivity) +
                currentSessionProductivity) /
            totalSessions;

    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      sessionsCompleted: totalSessions,
      productivity: newAverageProductivity,
      pauses: 0,
      remaining: state.selectedDuration,
      subject: "Deep Work", // ✅ RESET SUBJECT
    );
  }

  /* ---------------- AUTO COMPLETE ---------------- */

  void _completeSession() {
    _timer?.cancel();

    final currentSessionProductivity =
        (100 - state.pauses * 10).clamp(0, 100).toDouble();

    final totalSessions = state.sessionsCompleted + 1;

    final newAverageProductivity =
        ((state.sessionsCompleted * state.productivity) +
                currentSessionProductivity) /
            totalSessions;

    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      sessionsCompleted: totalSessions,
      productivity: newAverageProductivity,
      pauses: 0,
      remaining: state.selectedDuration,
      subject: "Deep Work",
    );
  }
}

final focusControllerProvider =
    NotifierProvider<FocusController, FocusModel>(FocusController.new);
