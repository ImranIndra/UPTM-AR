import 'package:assignment_reminder/pages/assignment_details/assignment_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../pages/new_entry/new_entry_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../constants.dart';
import '../global_bloc.dart';
import '../models/assignment.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: Column(
          children: [
            const TopContainer(),
            SizedBox(
              height: 2.h,
            ),
            //the widget take space as per need
            const Flexible(
              child: BottomContainer(),
            ),
          ],
        ),
      ),
      floatingActionButton: InkResponse(
        onTap: () {
          // go to new entry page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewEntryPage(),
            ),
          );
        },
        child: SizedBox(
          width: 18.w,
          height: 9.h,
          child: Card(
            color: kPrimaryColor,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(3.h),
            ),
            child: Icon(
              Icons.add_outlined,
              color: kScaffoldColor,
              size: 50.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class TopContainer extends StatelessWidget {
  const TopContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
            bottom: 1.h,
          ),
          child: Text(
            'Assignment Reminder. \nUPTM AR.',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(bottom: 1.h),
          child: Text(
            'Here are your reminder.',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        //lets show number of saved assignment from shared preferences
        StreamBuilder<List<Assignment>>(
            stream: globalBloc.assignmentList$,
            builder: (context, snapshot) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(bottom: 1.h),
                child: Text(
                  !snapshot.hasData ? '0' : snapshot.data!.length.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              );
            }),
      ],
    );
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Center(
    //   child: Text(
    //     'No Assignment',
    //     textAlign: TextAlign.center,
    //     style: Theme.of(context).textTheme.headline3,
    //   ),

    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);

    return StreamBuilder(
      stream: globalBloc.assignmentList$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          //if no data is saved
          return Container();
        } else if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No Assignment',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          );
        } else {
          return GridView.builder(
            padding: EdgeInsets.only(top: 1.h),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return AssignmentCard(assignment: snapshot.data![index]);
            },
          );
        }
      },
    );
  }
}

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({Key? key, required this.assignment}) : super(key: key);
  final Assignment assignment;
  //for getting the current details of the saved items

  //first need to get the assignment type icon
  //make a function

  Hero makeIcon(double size) {

    if (assignment.urgentType == 'High') {
      return Hero(
        tag: assignment.assignmentName! + assignment.urgentType!,
        child: SvgPicture.asset(
          'assets/icons/high.svg',
          color: kOtherColor,
          height: 7.h,
        ),
      );
    } else if (assignment.urgentType == 'Medium') {
      return Hero(
        tag: assignment.assignmentName! + assignment.urgentType!,
        child: SvgPicture.asset(
          'assets/icons/medium.svg',
          color: kOtherColor,
          height: 7.h,
        ),
      );
    } else if (assignment.urgentType == 'Low') {
      return Hero(
        tag: assignment.assignmentName! + assignment.urgentType!,
        child: SvgPicture.asset(
          'assets/icons/low.svg',
          color: kOtherColor,
          height: 7.h,
        ),
      );
    } else if (assignment.urgentType == 'Lowest') {
      return Hero(
        tag: assignment.assignmentName! + assignment.urgentType!,
        child: SvgPicture.asset(
          'assets/icons/lowest.svg',
          color: kOtherColor,
          height: 7.h,
        ),
      );
    }
    //in case of no assignment type icon selection
    return Hero(
      tag: assignment.assignmentName! + assignment.urgentType!,
      child: Icon(
        Icons.error,
        color: kOtherColor,
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.white,
      splashColor: Colors.grey,
      onTap: () {
        //go to details activity with animation, later

        Navigator.of(context).push(
          PageRouteBuilder<void>(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, Widget? child) {
                  return Opacity(
                    opacity: animation.value,
                    child: AssignmentDetails(assignment),
                  );
                },
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 1.h, bottom: 1.h),
        margin: EdgeInsets.all(1.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.h),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            //call the function here icon type
            makeIcon(7.h),
            const Spacer(),
            //hero tag animation, later
            Hero(
              tag: assignment.assignmentName!,
              child: Text(
                assignment.assignmentName!,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(
              height: 0.3.h,
            ),
            //time interval data with condition, later
            Text(
              assignment.interval == 1
                  ? "Every ${assignment.interval} hour"
                  : "Every ${assignment.interval} hour",
              overflow: TextOverflow.fade,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
