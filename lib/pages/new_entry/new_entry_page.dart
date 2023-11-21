import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants.dart';
import '../../global_bloc.dart';
import '../../models/errors.dart';
import '../../models/assignment.dart';
import '../../pages/home_page.dart';
import '../../pages/new_entry/new_entry_bloc.dart';
import '../../pages/success_screen/success_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../common/convert_time.dart';
import '../../models/urgent_type.dart';
import 'package:timezone/timezone.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({Key? key}) : super(key: key);

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}



class _NewEntryPageState extends State<NewEntryPage> {
  late TextEditingController nameController;
  late TextEditingController dueController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NewEntryBloc _newEntryBloc;
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dueController.dispose();
    _newEntryBloc.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    dueController = TextEditingController();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _newEntryBloc = NewEntryBloc();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    initializeNotifications();
    initializeErrorListen();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add New'),
      ),
      body: Provider<NewEntryBloc>.value(
        value: _newEntryBloc,
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelTitle(
                title: 'Assignment Name',
                isRequired: true,
              ),
              TextFormField(
                maxLength: 12,
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: kOtherColor),
              ),
              const PanelTitle(
                title: 'Due Date',
                isRequired: false,
              ),
              TextFormField(
                maxLength: 12,
                controller: dueController,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: kOtherColor),
              ),
              SizedBox(
                height: 2.h,
              ),
              const PanelTitle(title: 'Urgent Type', isRequired: false),
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: StreamBuilder<UrgentType>(
                  //new entry block
                  stream: _newEntryBloc.selectedUrgentType,
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        UrgentTypeColumn(
                            urgent: UrgentType.High,
                            name: 'High',
                            iconValue: 'assets/icons/high.svg',
                            isSelected: snapshot.data == UrgentType.High
                                ? true
                                : false),
                        UrgentTypeColumn(
                            urgent: UrgentType.Medium,
                            name: 'Medium',
                            iconValue: 'assets/icons/medium.svg',
                            isSelected: snapshot.data == UrgentType.Medium
                                ? true
                                : false),
                        UrgentTypeColumn(
                            urgent: UrgentType.Low,
                            name: 'Low',
                            iconValue: 'assets/icons/low.svg',
                            isSelected: snapshot.data == UrgentType.Low
                                ? true
                                : false),
                        UrgentTypeColumn(
                            urgent: UrgentType.Lowest,
                            name: 'Lowest',
                            iconValue: 'assets/icons/lowest.svg',
                            isSelected: snapshot.data == UrgentType.Lowest
                                ? true
                                : false),
                      ],
                    );
                  },
                ),
              ),
              const PanelTitle(title: 'Interval Selection', isRequired: true),
              const IntervalSelection(),
              const PanelTitle(title: 'Starting Time', isRequired: true),
              const SelectTime(),
              SizedBox(
                height: 2.h,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                  right: 8.w,
                ),
                child: SizedBox(
                  width: 80.w,
                  height: 8.h,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: const StadiumBorder(),
                    ),
                    child: Center(
                      child: Text(
                        'Confirm',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: kScaffoldColor,
                            ),
                      ),
                    ),
                    onPressed: () {
                      //add assignment
                      //some validations
                      //go to success screen
                      String? assignmentName;
                      String? dueDate;

                      //assignmentName
                      if (nameController.text == "") {
                        _newEntryBloc.submitError(EntryError.nameNull);
                        return;
                      }
                      if (nameController.text != "") {
                        assignmentName = nameController.text;
                      }
                      //duedate
                      if (dueController.text == "") {
                        _newEntryBloc.submitError(EntryError.nameNull);
                        return;
                      }
                      if (dueController.text != "") {
                        dueDate = dueController.text;
                      }
                      for (var assignment in globalBloc.assignmentList$!.value) {
                        if (assignmentName == assignment.assignmentName) {
                          _newEntryBloc.submitError(EntryError.nameDuplicate);
                          return;
                        }
                      }
                      if (_newEntryBloc.selectIntervals!.value == 0) {
                        _newEntryBloc.submitError(EntryError.interval);
                        return;
                      }
                      if (_newEntryBloc.selectedTimeOfDay$!.value == 'None') {
                        _newEntryBloc.submitError(EntryError.startTime);
                        return;
                      }

                      String urgentType = _newEntryBloc
                          .selectedUrgentType!.value
                          .toString()
                          .substring(13);

                      int interval = _newEntryBloc.selectIntervals!.value;
                      String startTime =
                          _newEntryBloc.selectedTimeOfDay$!.value;

                      List<int> intIDs =
                          makeIDs(24 / _newEntryBloc.selectIntervals!.value);
                      List<String> notificationIDs =
                          intIDs.map((i) => i.toString()).toList();

                      Assignment newEntryAssignment = Assignment(
                          notificationIDs: notificationIDs,
                          assignmentName: assignmentName,
                          duedate: dueDate,
                          urgentType: urgentType,
                          interval: interval,
                          startTime: startTime);

                      //update assignment list via global bloc
                      globalBloc.updateAssignmentList(newEntryAssignment);

                      //schedule notification
                      scheduleNotification(newEntryAssignment);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SuccessScreen()));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initializeErrorListen() {
    _newEntryBloc.errorState$!.listen((EntryError error) {
      switch (error) {
        case EntryError.nameNull:
          displayError("Please enter the assignment name");
          break;
        case EntryError.nameDuplicate:
          displayError("Assignment name already exists");
          break;
        case EntryError.due:
          displayError("Please enter the due date");
          break;
        case EntryError.interval:
          displayError("Please select the reminder's interval");
          break;
        case EntryError.startTime:
          displayError("Please select the reminder's starting time");
          break;
        default:
      }
    });
  }

  void displayError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kOtherColor,
        content: Text(error),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  List<int> makeIDs(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000000));
    }
    return ids;
  }

  initializeNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/launcher_icon');

    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  Future<void> scheduleNotification(Assignment assignment) async {
    var hour = int.parse(assignment.startTime![0] + assignment.startTime![1]);
    var minute = int.parse(assignment.startTime![2] + assignment.startTime![3]);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'repeatDailyAtTime channel id', 'repeatDailyAtTime channel name',
        importance: Importance.max,
        priority: Priority.high,
        ledColor: kOtherColor,
        ledOffMs: 1000,
        ledOnMs: 1000,
        enableLights: true);

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    for (int i = 0; i < 24 / assignment.interval!; i++) {
      if (hour + (assignment.interval! * i) > 23) {
        hour = hour + (assignment.interval! * i) - 24;
      } else {
        hour = hour + (assignment.interval! * i);
      }
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          int.parse(assignment.notificationIDs![i]),
          'Reminder: ${assignment.assignmentName}',
          assignment.urgentType.toString() != UrgentType.None.toString()
              ? 'Due! ${assignment.urgentType!.toLowerCase()}, according to schedule'
              : 'Dont forget about your assignment!',
          Time(hour, minute, 30),
          platformChannelSpecifics);
    }
  }
}

class SelectTime extends StatefulWidget {
  const SelectTime({Key? key}) : super(key: key);

  @override
  State<SelectTime> createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;

  Future<TimeOfDay> _selectTime() async {
    final NewEntryBloc newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);

    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _time);

    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _clicked = true;


        newEntryBloc.updateTime(convertTime(_time.hour.toString()) +
            convertTime(_time.minute.toString()));
      });
    }
    return picked!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.h,
      child: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: kPrimaryColor, shape: const StadiumBorder()),
          onPressed: () {
            _selectTime();
          },
          child: Center(
            child: Text(
              _clicked == false
                  ? "Select Time"
                  : "${convertTime(_time.hour.toString())}:${convertTime(_time.minute.toString())}",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: kScaffoldColor),
            ),
          ),
        ),
      ),
    );
  }
}

class IntervalSelection extends StatefulWidget {
  const IntervalSelection({Key? key}) : super(key: key);

  @override
  State<IntervalSelection> createState() => _IntervalSelectionState();
}

class _IntervalSelectionState extends State<IntervalSelection> {
  final _intervals = [1, 2, 3, 4];
  var _selected = 0;
  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntryBloc = Provider.of<NewEntryBloc>(context);
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Remind me every',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: kTextColor,
                ),
          ),
          DropdownButton(
            iconEnabledColor: kOtherColor,
            dropdownColor: kScaffoldColor,
            itemHeight: 8.h,
            hint: _selected == 0
                ? Text(
                    'Select an Interval',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kPrimaryColor,
                        ),
                  )
                : null,
            elevation: 4,
            value: _selected == 0 ? null : _selected,
            items: _intervals.map(
              (int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kSecondaryColor,
                        ),
                  ),
                );
              },
            ).toList(),
            onChanged: (newVal) {
              setState(
                () {
                  _selected = newVal!;
                  newEntryBloc.updateInterval(newVal);
                },
              );
            },
          ),
          Text(
            _selected == 1 ? " hour" : " hours",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: kTextColor),
          ),
        ],
      ),
    );
  }
}

class UrgentTypeColumn extends StatelessWidget {
  const UrgentTypeColumn(
      {Key? key,
      required this.urgent,
      required this.name,
      required this.iconValue,
      required this.isSelected})
      : super(key: key);
  final UrgentType urgent;
  final String name;
  final String iconValue;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntryBloc = Provider.of<NewEntryBloc>(context);
    return GestureDetector(
      onTap: () {

        newEntryBloc.updateSelectedUrgent(urgent);
      },
      child: Column(
        children: [
          Container(
            width: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.h),
                color: isSelected ? kOtherColor : Colors.white),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 1.h,
                  bottom: 1.h,
                ),
                child: SvgPicture.asset(
                  iconValue,
                  height: 7.h,
                  color: isSelected ? Colors.white : kOtherColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Container(
              width: 20.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected ? kOtherColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: isSelected ? Colors.white : kOtherColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanelTitle extends StatelessWidget {
  const PanelTitle({Key? key, required this.title, required this.isRequired})
      : super(key: key);
  final String title;
  final bool isRequired;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: title,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            TextSpan(
              text: isRequired ? " *" : "",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: kPrimaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
