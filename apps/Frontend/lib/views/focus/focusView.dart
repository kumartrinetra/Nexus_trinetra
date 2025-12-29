import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/focus/focusController.dart';
import '../../models/focusModel.dart';
import 'package:nexus_frontend/widgets/sliverAppBar.dart';

class FocusView extends ConsumerWidget {
  const FocusView({super.key});

  String _format(Duration d) =>
      "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:"
      "${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(focusControllerProvider);
    final controller = ref.read(focusControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: CustomScrollView(
        slivers: [
          myAppBar("Focus Mode", "Deep Work & Productivity",
              "assets/images/loginIcon.png"),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  _focusCard(focus, controller),
                  SizedBox(height: 16.r),
                  _stats(focus),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _focusCard(FocusModel focus, FocusController controller) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:
            const LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Working on",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        const SizedBox(height: 6),

        // 🧠 SUBJECT (EDITABLE)
        focus.isRunning
            ? Text(focus.subject,
                style: const TextStyle(color: Colors.white70))
            : TextFormField(
                initialValue: focus.subject,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "What are you focusing on?",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: controller.setSubject,
              ),

        const SizedBox(height: 16),

        // ⏱ DURATION
        if (!focus.isRunning)
          Wrap(
            spacing: 8,
            children: [1, 45, 60].map((m) {
              return ChoiceChip(
                label: Text("$m min"),
                selected: focus.selectedDuration.inMinutes == m,
                onSelected: (_) =>
                    controller.setDuration(Duration(minutes: m)),
              );
            }).toList(),
          ),

        const SizedBox(height: 20),

        // ⏲ TIMER
        Center(
          child: Text(_format(focus.remaining),
              style: TextStyle(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),

        const SizedBox(height: 16),

        // ▶ CONTROLS
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          if (!focus.isRunning)
            _btn("Start", controller.start),
          if (focus.isRunning && !focus.isPaused)
            _btn("Pause", controller.pause),
          if (focus.isPaused)
            _btn("Resume", controller.resume),
          if (focus.isRunning || focus.isPaused)
            _btn("Stop", controller.stop),
        ])
      ]),
    );
  }

  Widget _stats(FocusModel f) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _stat("${f.sessionsCompleted}", "Sessions"),
          _stat("${f.pauses}", "Pauses"),
          _stat("${f.productivity.toInt()}%", "Productivity"),
        ]),
      ),
    );
  }

  Widget _btn(String t, VoidCallback f) =>
      ElevatedButton(onPressed: f, child: Text(t));

  Widget _stat(String v, String l) =>
      Column(children: [Text(v), Text(l)]);
}
