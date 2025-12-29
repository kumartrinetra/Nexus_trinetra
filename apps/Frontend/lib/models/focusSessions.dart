class FocusSession {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final int pauses;
  final bool completed;

  FocusSession({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.pauses,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      "startTime": startTime.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "duration": duration.inSeconds,
      "pauses": pauses,
      "completed": completed,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      startTime: DateTime.parse(json["startTime"]),
      endTime: DateTime.parse(json["endTime"]),
      duration: Duration(seconds: json["duration"]),
      pauses: json["pauses"],
      completed: json["completed"],
    );
  }
}
