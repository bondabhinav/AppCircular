import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';

ValueNotifier<String> downloadMessage = ValueNotifier('');

class DownloadPdf {
  static int dialogOpen = 0;

  DownloadPdf._();

  static StreamController<double> percentage = StreamController<double>.broadcast();

  static void downloadPdf(
    String url,
    String fileName,
    BuildContext context,
    Function(String)? messageCallBack,
    Function(File)? fileCallBack, {
    bool parseUrl = true,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      if (Platform.isAndroid) {
        dialogOpen = 1;
        try {
          FileDownloader.downloadFile(
            url: url,
            name: fileName.replaceAll(RegExp('[^A-Za-z0-9]\\s+'), ''),
            onProgress: (name, progress) async {
           //   percentage.add(progress);
              debugPrint('progress ---------> $progress');
           //   int progress = ((received / total) * 100).toInt();
              if (Platform.isAndroid) {
                await NotificationService.showNotification(
                  channelId: 1,
                  title: fileName,
                  body: "",
                  summary: "",
                  progress: progress.toInt(),
                  notificationLayout: NotificationLayout.ProgressBar,
                );
              }
            },
            onDownloadCompleted: (path) async {
              downloadMessage.value = "Download completed in $path";
              await NotificationService.cancelProgressNotification();
              await NotificationService.showNotification(
                channelId: 2,
                title: fileName,
                body: "",
                summary: "",
                payload: {"path": path},
              );
            },
            onDownloadError: (error) {
              downloadMessage.value = error;
              ShowSnackBar.error(context: context, showMessage: error.toString());
            },
          );
        } on Exception catch (e) {
          downloadMessage.value = e.toString();
        }
      } else {
        Dio dio = Dio();
        try {
          final response = await dio.get(
            url,
            options: Options(responseType: ResponseType.bytes),
            onReceiveProgress: (downloaded, total) {
              if (total != -1) {
                percentage.add((downloaded / total) * 100);
              }
            },
          );
          Directory? appDocDir;
          if (Platform.isAndroid) {
            appDocDir = await getExternalStorageDirectory();
          } else {
            appDocDir = await getTemporaryDirectory();
          }
          String filePath = '${appDocDir!.path}/$fileName.pdf';
          File file = File(filePath);
          final completedFile = await file.writeAsBytes(response.data);
          fileCallBack!(completedFile);
          messageCallBack!("File saved to: $filePath'");
        } catch (e) {
          messageCallBack!("File not downloaded");
          debugPrint(e.toString());
        }
      }
    } else {
      // Fluttertoast.showToast(
      //   msg: "Please check your internet connection and try again!",
      //   toastLength: Toast.LENGTH_LONG,
      // );
    }
  }
}
