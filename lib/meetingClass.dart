class MeetingClass {
  final String uuid;
  final String title;
  final String startTime;
  final String endTime;
  final String eventUuid;
  final bool hasNotes;
  bool isArchived;

  MeetingClass(this.uuid, this.title, this.startTime, this.endTime,
      this.eventUuid, this.hasNotes, this.isArchived);

  @override
  String toString() {
    return 'Meeting{uuid: $uuid, title: $title, start_time: $startTime, end_time: $endTime, event_uuid: $eventUuid, has_notes: $hasNotes, is_archived: $isArchived}';
  }
}
