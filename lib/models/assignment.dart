class Assignment {
  final List<dynamic>? notificationIDs;
  final String? assignmentName;
  final String? duedate;
  final String? urgentType;
  final int? interval;
  final String? startTime;

  Assignment(
      {this.notificationIDs,
      this.assignmentName,
      this.duedate,
      this.urgentType,
      this.startTime,
      this.interval});

  //geters
  String get getName => assignmentName!;
  String get getDue => duedate!;
  String get getType => urgentType!;
  int get getInterval => interval!;
  String get getStartTime => startTime!;
  List<dynamic> get getIDs => notificationIDs!;

  Map<String, dynamic> toJson() {
    return {
      'ids': notificationIDs,
      'name': assignmentName,
      'due': duedate,
      'type': urgentType,
      'interval': interval,
      'start': startTime,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> parsedJson) {
    return Assignment(
      notificationIDs: parsedJson['ids'],
      assignmentName: parsedJson['name'],
      duedate: parsedJson['due'],
      urgentType: parsedJson['type'],
      interval: parsedJson['interval'],
      startTime: parsedJson['start'],
    );
  }
}
