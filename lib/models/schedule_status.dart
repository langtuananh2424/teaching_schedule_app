// lib/models/schedule_status.dart
enum ScheduleStatus {
  NOT_TAUGHT,
  TAUGHT,
  ABSENT_APPROVED,
  ABSENT_UNAPPROVED,
  MAKEUP_TAUGHT,
  UNKNOWN;
}

ScheduleStatus scheduleStatusFromString(String status) {
  try {
    return ScheduleStatus.values.firstWhere(
          (e) => e.toString().split('.').last == status,
    );
  } catch (e) {
    return ScheduleStatus.UNKNOWN;
  }
}