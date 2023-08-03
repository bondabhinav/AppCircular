import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/student/student_circular_doc_list_respnose.dart';
import 'package:flexischool/models/student/student_circular_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final GetIt getIt = GetIt.instance;

class StudentCircularProvider extends ChangeNotifier {
  final loaderProvider = getIt<LoaderProvider>();
  StudentCircularListResponse? studentCircularListResponse;
  final apiService = ApiService();
  TabController? tabController;

  String? _message;

  String? get message => _message;

  // late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> fetchStudentCircularData() async {
    try {
      loaderProvider.showLoader();
      var data = {"STUDENT_ID": WebService.studentLoginData?.table1?.first.aDMSTUDENTID};
      final response = await apiService.post(url: Api.studentCircularListApi, data: data);
      if (response.statusCode == 200) {
        studentCircularListResponse = StudentCircularListResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        if (studentCircularListResponse!.classlist!.isEmpty) {
          _message = 'No circular found';
        }
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        _message = 'Something wents wrong';
        notifyListeners();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      loaderProvider.hideLoader();
      _message = e.toString();
      notifyListeners();
      //  throw Exception('Failed to connect to the API');
    }
  }

  Future<StudentCircularDocumentListResponse> fetchStudentDocumentData({required int circularId}) async {
    var studentCircularDocumentListResponse = StudentCircularDocumentListResponse();
    try {
      loaderProvider.showLoader();
      var data = {"APP_CIRCULAR_ID": circularId};
      final response = await apiService.post(url: Api.studentDocumentListApi, data: data);
      if (response.statusCode == 200) {
        studentCircularDocumentListResponse = StudentCircularDocumentListResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API ${e.toString()}');
    }
    return studentCircularDocumentListResponse;
  }

  // Future<void> downloadFile(BuildContext context, String url) async {
  //   final String fileName = url.split('/').last;
  //   var path = await TBIBDownloader().downloadFile(
  //     url: Api.imageBaseUrl + url,
  //     fileName: fileName,
  //     directoryName: 'Download',
  //     disabledDeleteFileButton: true,
  //     onReceiveProgress: ({int? receivedBytes, int? totalBytes}) {
  //       if (!context.mounted) {
  //         return;
  //       }
  //       _downloadProgress = (receivedBytes! / totalBytes!);
  //       notifyListeners();
  //     },
  //   );
  //   debugPrint('path $path');
  //   if (!context.mounted) {
  //     return;
  //   }
  //   _downloadProgress = 0.0;
  //   notifyListeners();
  //
  //   // Dio dio = Dio();
  //   // final String fileName = url.split('/').last;
  //   // String? filePath;
  //   // bool isImageFile = false;
  //   // Directory? appDocDir =
  //   //     Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
  //   // if (appDocDir != null) {
  //   //   final dirPath = Platform.isAndroid ? appDocDir.path : appDocDir.path;
  //   //   filePath = '$dirPath/$fileName';
  //   //   debugPrint('Directory path : $dirPath');
  //   //   isImageFile = checkIsImageFile(fileName);
  //   // }
  //   // debugPrint('Download api url : ${Api.imageBaseUrl + url}');
  //   // try {
  //   //   await dio.download(Api.imageBaseUrl + url, filePath, onReceiveProgress: (receivedBytes, totalBytes) {
  //   //     if (totalBytes != -1) {
  //   //       double progress = receivedBytes / totalBytes * 100;
  //   //       debugPrint('Download progress: ${progress.toStringAsFixed(0)}%');
  //   //       updateNotificationProgress(fileName, progress.toInt());
  //   //     }
  //   //   });
  //   //   if (isImageFile) {
  //   //     GallerySaver.saveImage(filePath!).then((bool? success) {
  //   //       debugPrint('Video is saved');
  //   //     });
  //   //   }
  //   //   if (context.mounted) {
  //   //     ShowSnackBar.successToast(context: context, showMessage: 'File downloaded successfully.');
  //   //   }
  //   // } catch (e) {
  //   //   debugPrint('Error during file download: $e');
  //   //   if (context.mounted) {
  //   //     ShowSnackBar.error(context: context, showMessage: 'Error during file download: $e');
  //   //   }
  //   // }
  // }

  // bool checkIsImageFile(String fileName) {
  //   String extension = path.extension(fileName).toLowerCase();
  //   return extension == '.jpg' || extension == '.jpeg' || extension == '.png' || extension == '.gif';
  // }

  Future<void> requestWritePermission(BuildContext context) async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
    } else {
      if (context.mounted) {
        ShowSnackBar.error(context: context, showMessage: 'Write permission denied.');
      }
    }
  }

  Future<void> updateCircularFlag(String id) async {
    try {
      var data = {"APP_CIRCULAR_ID": id};
      final response = await apiService.post(url: Api.updateCircularFlagApi, data: data);
      if (response.statusCode == 200) {
        //  var commonResponse = CommonResponse.fromJson(response.data);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      throw Exception('Failed to connect to the API');
    }
  }

  void updateFlagStatus(Classlist classList) {
    classList.fLAG = "Y";
    notifyListeners();
  }

  Future<void> downloadFile(BuildContext context, String url) async {
    final String fileName = url.split('/').last;

    // final directory = await getExternalStorageDirectory();

    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationSupportDirectory();
    }

    if (directory == null) {
      debugPrint('Error: Unsupported platform.');
      return;
    }

    final savePath = '${directory.path}/$fileName';
    debugPrint('save Path $savePath');
    debugPrint('download url ${Api.imageBaseUrl + url}');

    try {
      final dio = Dio();
      await dio.download(
        Api.imageBaseUrl + url,
        savePath,
        onReceiveProgress: (received, total) async {
          int progress = ((received / total) * 100).toInt();
          debugPrint('progress---> $progress');
          if (Platform.isAndroid) {
            await NotificationService.showNotification(
              channelId: 1,
              title: fileName,
              body: "",
              summary: "",
              progress: progress,
              notificationLayout: NotificationLayout.ProgressBar,
            );
          }
          //  NotificationService().showProgressNotification(progress, fileName);
        },
      );
      await NotificationService.cancelProgressNotification();
      await NotificationService.showNotification(
        channelId: 2,
        title: fileName,
        body: "",
        summary: "",
        payload: {"path": savePath},
      );
      //  NotificationService().cancelProgressNotification();
      //  NotificationService().showNotification(savePath, fileName);
    } catch (e) {
      debugPrint('Error during file download: $e');
    }
  }
}
