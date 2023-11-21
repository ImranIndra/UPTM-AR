import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/assignment.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GlobalBloc {
  BehaviorSubject<List<Assignment>>? _assignmentList$;
  BehaviorSubject<List<Assignment>>? get assignmentList$ => _assignmentList$;

  GlobalBloc() {
    _assignmentList$ = BehaviorSubject<List<Assignment>>.seeded([]);
    makeAssignmentList();
  }

  Future removeAssignment(Assignment tobeRemoved) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    List<String> assignmentJsonList = [];

    var blockList = _assignmentList$!.value;
    blockList.removeWhere(
        (medicine) => medicine.assignmentName == tobeRemoved.assignmentName);

    //remove notifications,todo
    for (int i = 0; i < (24 / tobeRemoved.interval!).floor(); i++) {
      flutterLocalNotificationsPlugin
          .cancel(int.parse(tobeRemoved.notificationIDs![i]));
    }

    if (blockList.isNotEmpty) {
      for (var blockAssignment in blockList) {
        String medicineJson = jsonEncode(blockAssignment.toJson());
        assignmentJsonList.add(medicineJson);
      }
    }

    sharedUser.setStringList('assignment', assignmentJsonList);
    _assignmentList$!.add(blockList);
  }

  Future updateAssignmentList(Assignment newAssignment) async {
    var blocList = _assignmentList$!.value;
    blocList.add(newAssignment);
    _assignmentList$!.add(blocList);

    Map<String, dynamic> tempMap = newAssignment.toJson();
    SharedPreferences? sharedUser = await SharedPreferences.getInstance();
    String newAssignmentJson = jsonEncode(tempMap);
    List<String> assignmentJsonList = [];
    if (sharedUser.getStringList('assignments') == null) {
      assignmentJsonList.add(newAssignmentJson);
    } else {
      assignmentJsonList = sharedUser.getStringList('assignments')!;
      assignmentJsonList.add(newAssignmentJson);
    }
    sharedUser.setStringList('assignments', assignmentJsonList);
  }

  Future makeAssignmentList() async {
    SharedPreferences? sharedUser = await SharedPreferences.getInstance();
    List<String>? jsonList = sharedUser.getStringList('assignments');
    List<Assignment> prefList = [];

    if (jsonList == null) {
      return;
    } else {
      for (String jsonAssignment in jsonList) {
        dynamic userMap = jsonDecode(jsonAssignment);
        Assignment tempAssignment = Assignment.fromJson(userMap);
        prefList.add(tempAssignment);
      }
      //state update
      _assignmentList$!.add(prefList);
    }
  }

  void dispose() {
    _assignmentList$!.close();
  }

}
