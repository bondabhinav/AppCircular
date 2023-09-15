import 'package:flexischool/common/constants.dart';
import 'package:flexischool/models/student/notification_list_response.dart';
import 'package:flexischool/providers/student/student_notification_provider.dart';
import 'package:flexischool/screens/assignment_detail_screen.dart';
import 'package:flexischool/screens/circulars_screen.dart';
import 'package:flexischool/screens/student/student_circular_detail_screen.dart';
import 'package:flexischool/utils/date_formater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class StudentNotificationScreen extends StatefulWidget {
  const StudentNotificationScreen({Key? key}) : super(key: key);

  @override
  State<StudentNotificationScreen> createState() => _StudentNotificationScreenState();
}

class _StudentNotificationScreenState extends State<StudentNotificationScreen> {
  StudentNotificationProvider? studentNotificationProvider;

  @override
  void initState() {
    studentNotificationProvider = StudentNotificationProvider();
    studentNotificationProvider?.fetchNotificationData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => studentNotificationProvider,
        builder: (context, child) {
          return Consumer<StudentNotificationProvider>(builder: (context, model, _) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Notifications'),
                  leading: IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  //  actions: [
                  //    IconButton(
                  //     icon: const Icon(Icons.calendar_today),
                  //     onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => CalendarPage(
                  //       onDateSelected: onDateSelected,
                  //     ),
                  //   ),
                  // );
                  //       },
                  //     ),
                  //   ],
                ),
                body: model.notificationListResponse == null
                    ? const Center(child: CircularProgressIndicator())
                    : model.notificationListResponse!.notification!.isEmpty
                        ? Center(child: Text(model.message ?? ""))
                        : ListView.builder(
                            itemCount: model.notificationListResponse?.notification?.length,
                            itemBuilder: (context, index) {
                              final notificationItem = model.notificationListResponse?.notification![index];
                              return InkWell(
                                onTap: () {
                                  if (notificationItem.nOTIFICATIONTYPE == 'ASSIGNMENT') {
                                    if (notificationItem.nOTIFICATIONFLAG == 'N') {
                                      model.notificationUpdate(notificationItem.nOTIFICATIONID, index);
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AssignmentDetailScreen(
                                              sessionId: Constants.sessionId,
                                                assignmentId: notificationItem.aPPASSIGNMENTID!)));
                                  } else if (notificationItem.nOTIFICATIONTYPE == 'CIRCULAR') {
                                    if (notificationItem.nOTIFICATIONFLAG == 'N') {
                                      model.notificationUpdate(notificationItem.nOTIFICATIONID, index);
                                    }
                                    debugPrint('check circular id ---> ${notificationItem.aPPCIRCULARID}');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => StudentCircularDetailScreen(
                                              sessionId: Constants.sessionId,
                                                id: notificationItem.aPPCIRCULARID!)));
                                  } else if (notificationItem.nOTIFICATIONTYPE == 'ATTENDANCE') {}
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    elevation: notificationItem?.nOTIFICATIONFLAG == 'N' ? 4.0 : 2.0,
                                    color: notificationItem?.nOTIFICATIONFLAG == 'N'
                                        ? Colors.grey[300]
                                        : Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              color: Colors.orange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.notifications,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        notificationItem?.nOTIFICATIONTYPE ?? "",
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    ),
                                                    dateItem(notificationItem!, model)
                                                  ],
                                                ),
                                                const SizedBox(height: 4.0),
                                                description(notificationItem, model),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ));
          });
        });
  }

  Widget description(NotificationData notification, StudentNotificationProvider model) {
    switch (notification.nOTIFICATIONTYPE) {
      case 'ASSIGNMENT':
        return SizedBox(
          height: 60,
          child: Html(
            shrinkWrap: true,
            data: model.getContentAsHTML(notification.aSSIGNMENTDETAILS ?? ""),
          ),
        );
      case 'CIRCULAR':
        return Text(notification.aPPCIRCULARDESCRIPTION ?? "");
      case 'ATTENDANCE':
        return const Text('you are absent today');
      default:
        return const SizedBox();
    }
  }

  Widget dateItem(NotificationData notification, StudentNotificationProvider model) {
    switch (notification.nOTIFICATIONTYPE) {
      case 'ASSIGNMENT':
        return Text(DateTimeUtils.formatDateTime(notification.aSSIGNMENTDATE ?? ""));
      case 'CIRCULAR':
        return Text(DateTimeUtils.formatDateTime(notification.aPPCIRCULARDATE ?? ""));
      case 'ATTENDANCE':
        return const Text('');
      default:
        return const SizedBox();
    }
  }
}
