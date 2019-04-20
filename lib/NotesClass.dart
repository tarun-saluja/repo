class NotesClass {
  final int actionItems;
  final String meetingTitle;
  final bool isArchived;
  final String updatedAt;
  final String meetingUuid;
  final String eventUuid;

  NotesClass(this.actionItems, this.meetingTitle, this.isArchived,
      this.updatedAt, this.meetingUuid, this.eventUuid);

  @override
  String toString() {
    return 'RecentNote{action_items: $actionItems, meeting_title: $meetingTitle, is_archived: $isArchived, updated_at: $updatedAt, meeting_uuid: $meetingUuid, event_uuid: $eventUuid}';
  }
}
