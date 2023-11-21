import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants.dart';
import '../../global_bloc.dart';
import '../../models/assignment.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AssignmentDetails extends StatefulWidget {
  const AssignmentDetails(this.assignment, {Key? key}) : super(key: key);
  final Assignment assignment;

  @override
  State<AssignmentDetails> createState() => _AssignmentDetailsState();
}

class _AssignmentDetailsState extends State<AssignmentDetails> {
  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: Column(
          children: [
            MainSection(assignment: widget.assignment),
            ExtendedSection(assignment: widget.assignment),
            const Spacer(),
            SizedBox(
              width: 100.w,
              height: 7.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  //open alert dialog box,+global bloc, later
                  //cool its working
                  openAlertBox(context, globalBloc);
                },
                child: Text(
                  'Delete',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: kScaffoldColor),
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  }


  openAlertBox(BuildContext context, GlobalBloc globalBloc) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kScaffoldColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          contentPadding: EdgeInsets.only(top: 1.h),
          title: Text(
            'Delete This Reminder?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () {
                //global block to delete assignment,later
                globalBloc.removeAssignment(widget.assignment);
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text(
                'OK',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: kSecondaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MainSection extends StatelessWidget {
  const MainSection({Key? key, this.assignment}) : super(key: key);
  final Assignment? assignment;
  Hero makeIcon(double size) {
    if (assignment!.urgentType == 'High') {
      return Hero(
        tag: assignment!.assignmentName! + assignment!.urgentType!,
        child: SvgPicture.asset(
          'assets/icons/high.svg',
          color: kOtherColor,
          height: 7.h,
        ),
      );
    } else if (assignment!.urgentType == 'Medium') {
      return Hero(
        tag: assignment!.assignmentName! + assignment!.urgentType!,
        child: SvgPicture.asset(
          'assets/icons/medium.svg',
          color: kOtherColor,
          height: 7.h,
        ),
      );
    } else if (assignment!.urgentType == 'Low') {
      return Hero(
        tag: assignment!.assignmentName! + assignment!.urgentType!,
        child: SvgPicture.asset(
          'assets/icons/low.svg',
          color: kOtherColor,
          height: 7.h,
        ),
      );
    } else if (assignment!.urgentType == 'Lowest') {
      return Hero(
        tag: assignment!.assignmentName! + assignment!.urgentType!,
        child: SvgPicture.asset(
          'assets/icons/lowest.svg',
          color: kOtherColor,
          height: 7.h,
        ),
      );
    }
    //in case of no assignment type icon selection
    return Hero(
      tag: assignment!.assignmentName! + assignment!.urgentType!,
      child: Icon(
        Icons.error,
        color: kOtherColor,
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        makeIcon(7.h),
        SizedBox(
          width: 2.w,
        ),
        Column(
          children: [
            Hero(
              tag: assignment!.assignmentName!,
              child: Material(
                color: Colors.transparent,
                child: MainInfoTab(
                    fieldTitle: 'Assignment Name',
                    fieldInfo: assignment!.assignmentName!),
              ),
            ),
            MainInfoTab(
                fieldTitle: 'Due Date',
                fieldInfo: assignment!.duedate!),
          ],
        )
      ],
    );
  }
}

class MainInfoTab extends StatelessWidget {
  const MainInfoTab(
      {Key? key, required this.fieldTitle, required this.fieldInfo})
      : super(key: key);
  final String fieldTitle;
  final String fieldInfo;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 10.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(
              height: 0.3.h,
            ),
            Text(
              fieldInfo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class ExtendedSection extends StatelessWidget {
  const ExtendedSection({Key? key, this.assignment}) : super(key: key);
  final Assignment? assignment;
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ExtendedInfoTab(
          fieldTitle: 'Urgent Type ',
          fieldInfo: assignment!.urgentType! == 'None'
              ? 'Not Specified'
              : assignment!.urgentType!,
        ),
        ExtendedInfoTab(
          fieldTitle: 'Reminder',
          fieldInfo:
              'Every ${assignment!.interval} hours   | ${assignment!.interval == 24 ? "One time a day" : "${(24 / assignment!.interval!).floor()} times a day"}',
        ),
        ExtendedInfoTab(
          fieldTitle: 'Start Time',
          fieldInfo:
              '${assignment!.startTime![0]}${assignment!.startTime![1]}:${assignment!.startTime![2]}${assignment!.startTime![3]}',
        ),
      ],
    );
  }
}

class ExtendedInfoTab extends StatelessWidget {
  const ExtendedInfoTab(
      {Key? key, required this.fieldTitle, required this.fieldInfo})
      : super(key: key);
  final String fieldTitle;
  final String fieldInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: Text(
              fieldTitle,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: kTextColor,
                  ),
            ),
          ),
          Text(
            fieldInfo,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }
}
