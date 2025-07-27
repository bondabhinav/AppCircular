import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

// Removed: import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:external_path/external_path.dart';

ValueNotifier<String> downloadMessage = ValueNotifier('');

class DownloadPdf {
//   static int dialogOpen = 0;
//
//   DownloadPdf._();
//
  static StreamController<double> percentage = StreamController<double>.broadcast();
//
//   static void downloadPdf(
//     String url,
//     String fileName,
//     BuildContext context,
//     Function(String)? messageCallBack,
//     Function(File)? fileCallBack, {
//     bool parseUrl = true,
//   }) async {
//     final connectivity = await Connectivity().checkConnectivity();
//     if (connectivity != ConnectivityResult.none) {
//       if (Platform.isAndroid) {
//         dialogOpen = 1;
//         try {
//           FileDownloader.downloadFile(
//             url: url,
//             name: fileName.replaceAll(RegExp('[^A-Za-z0-9]\\s+'), ''),
//             onProgress: (name, progress) async {
//            //   percentage.add(progress);
//               debugPrint('progress ---------> $progress');
//            //   int progress = ((received / total) * 100).toInt();
//               if (Platform.isAndroid) {
//                 await NotificationService.showNotification(
//                   channelId: 1,
//                   title: fileName,
//                   body: "",
//                   summary: "",
//                   progress: progress.toInt(),
//                   notificationLayout: NotificationLayout.ProgressBar,
//                 );
//               }
//             },
//             onDownloadCompleted: (path) async {
//               downloadMessage.value = "Download completed in $path";
//               await NotificationService.cancelProgressNotification();
//               await NotificationService.showNotification(
//                 channelId: 2,
//                 title: fileName,
//                 body: "",
//                 summary: "",
//                 payload: {"path": path},
//               );
//             },
//             onDownloadError: (error) {
//               downloadMessage.value = error;
//               ShowSnackBar.error(context: context, showMessage: error.toString());
//             },
//           );
//         } on Exception catch (e) {
//           downloadMessage.value = e.toString();
//         }
//       } else {
//         Dio dio = Dio();
//         try {
//           final response = await dio.get(
//             url,
//             options: Options(responseType: ResponseType.bytes),
//             onReceiveProgress: (downloaded, total) {
//               if (total != -1) {
//                 percentage.add((downloaded / total) * 100);
//               }
//             },
//           );
//           Directory? appDocDir;
//           if (Platform.isAndroid) {
//             appDocDir = await getExternalStorageDirectory();
//           } else {
//             appDocDir = await getTemporaryDirectory();
//           }
//           String filePath = '${appDocDir!.path}/$fileName.pdf';
//           File file = File(filePath);
//           final completedFile = await file.writeAsBytes(response.data);
//           fileCallBack!(completedFile);
//           messageCallBack!("File saved to: $filePath'");
//         } catch (e) {
//           messageCallBack!("File not downloaded");
//           debugPrint(e.toString());
//         }
//       }
//     } else {
//       // Fluttertoast.showToast(
//       //   msg: "Please check your internet connection and try again!",
//       //   toastLength: Toast.LENGTH_LONG,
//       // );
//     }
//   }
//
//   static ReceivePort _port = ReceivePort();
//
//   static Future<void> downloadFileWithFlutterDownloader(
//     String url,
//     String fileName,
//     BuildContext context,
//     Function(String)? messageCallBack,
//   ) async {
//     final connectivity = await Connectivity().checkConnectivity();
//     if (connectivity == ConnectivityResult.none) {
//       ShowSnackBar.error(
//         context: context,
//         showMessage: "Please check your internet connection and try again!"
//       );
//       return;
//     }
//
//     try {
//       // Initialize port for download callback
//       IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
//       _port.listen((dynamic data) {
//         String id = data[0];
//         DownloadTaskStatus status = data[1];
//         int progress = data[2];
//
//         debugPrint('Download task ($id) is in status ($status) and progress ($progress)');
//
//         if (status == DownloadTaskStatus.complete) {
//           messageCallBack?.call('Download completed');
//         } else if (status == DownloadTaskStatus.failed) {
//           messageCallBack?.call('Download failed');
//         }
//       });
//
//       // Register callback
//       FlutterDownloader.registerCallback(downloadCallback);
//
//       // Get the external storage directory
//       final Directory? directory = await getExternalStorageDirectory();
//       if (directory == null) {
//         throw Exception('Could not access external storage');
//       }
//
//       // Ensure the directory exists
//       if (!await directory.exists()) {
//         await directory.create(recursive: true);
//       }
//
//       // Enqueue the download task
//       final taskId = await FlutterDownloader.enqueue(
//         url: url,
//         headers: {}, // Add any headers if needed
//         savedDir: directory.path,
//         fileName: fileName,
//         showNotification: true,
//         openFileFromNotification: true,
//         saveInPublicStorage: true,
//       );
//
//     } catch (e) {
//       ShowSnackBar.error(context: context, showMessage: e.toString());
//       messageCallBack?.call('Download failed: ${e.toString()}');
//     }
//   }
//
//   // This callback function must be a top-level or static function
//   @pragma('vm:entry-point')
//   static void downloadCallback(String id, int status, int progress) {
//     final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
//     send?.send([id, DownloadTaskStatus.values[status], progress]);
//   }
//
//   // Don't forget to dispose the port when you're done
//   static void dispose() {
//     IsolateNameServer.removePortNameMapping('downloader_send_port');
//   }
//
//   static Future<void> downloadFileWithDio(
//     String url,
//     String fileName,
//     BuildContext context,
//     Function(String)? messageCallBack,
//     Function(File)? fileCallBack,
//   ) async {
//     final connectivity = await Connectivity().checkConnectivity();
//     if (connectivity == ConnectivityResult.none) {
//       ShowSnackBar.error(
//         context: context,
//         showMessage: "Please check your internet connection and try again!"
//       );
//       return;
//     }
//
//     Dio dio = Dio();
//     int lastProgressNotified = 0;
//
//     try {
//       // Get directory to save file
//       Directory? appDocDir;
//       if (Platform.isAndroid) {
//         appDocDir = await getExternalStorageDirectory();
//       } else {
//         appDocDir = await getTemporaryDirectory();
//       }
//
//       if (appDocDir == null) {
//         throw Exception('Could not access storage directory');
//       }
//
//       String filePath = '${appDocDir.path}/$fileName';
//
//       // Show initial notification
//       if (Platform.isAndroid) {
//         await NotificationService.showNotification(
//           channelId: 1,
//           title: fileName,
//           body: "Download starting...",
//           summary: "",
//           progress: 0,
//           notificationLayout: NotificationLayout.ProgressBar,
//         );
//       }
//
//       // Start download with progress tracking
//       await dio.download(
//         url,
//         filePath,
//         onReceiveProgress: (received, total) async {
//           // Only update notification if progress changed by at least 5%
//           if (total > 0) { // Ensure total is greater than 0 to avoid division by zero
//             int currentProgress = ((received / total) * 100).round();
//
//             // Only update notification if progress changed significantly
//             if (currentProgress - lastProgressNotified >= 5 || currentProgress == 100) {
//               lastProgressNotified = currentProgress;
//
//               // Update notification with progress
//               if (Platform.isAndroid) {
//                 await NotificationService.showNotification(
//                   channelId: 1,
//                   title: fileName,
//                   body: "$currentProgress%",
//                   summary: "",
//                   progress: currentProgress,
//                   notificationLayout: NotificationLayout.ProgressBar,
//                 );
//               }
//
//               // Safely update percentage stream
//               try {
//                 percentage.add(currentProgress.toDouble());
//               } catch (e) {
//                 debugPrint('Error updating percentage stream: $e');
//               }
//             }
//           }
//         },
//       );
//
//       // Download completed
//       downloadMessage.value = "Download completed in $filePath";
//
//       // Show completed notification
//       if (Platform.isAndroid) {
//         await NotificationService.cancelProgressNotification();
//         await NotificationService.showNotification(
//           channelId: 2,
//           title: "$fileName downloaded",
//           body: "Download complete",
//           summary: "",
//           payload: {"path": filePath},
//         );
//       }
//
//       // Call the callback with the file
//       File file = File(filePath);
//       if (file.existsSync()) {
//         fileCallBack?.call(file);
//         messageCallBack?.call("File saved to: $filePath");
//       } else {
//         messageCallBack?.call("File download complete but not found at expected location");
//       }
//     } catch (e) {
//       // Handle errors
//       debugPrint('Error downloading file: $e');
//
//       if (Platform.isAndroid) {
//         await NotificationService.cancelProgressNotification();
//       }
//
//       // Handle specific format exception
//       if (e is FormatException) {
//         ShowSnackBar.error(context: context, showMessage: "Error during download progress calculation");
//         messageCallBack?.call("Download failed: Error tracking progress");
//       } else {
//         ShowSnackBar.error(context: context, showMessage: e.toString());
//         messageCallBack?.call("Download failed: ${e.toString()}");
//       }
//
//       downloadMessage.value = e.toString();
//     }
//   }

  static Future<void> downloadPdf(
    String url,
    String fileName,
    BuildContext context,
    Function(String)? messageCallBack,
  ) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      ShowSnackBar.error(
        context: context, 
        showMessage: "Please check your internet connection and try again!"
      );
      return;
    }

    Dio dio = Dio();
    int lastProgressNotified = 0;
    bool isCompleted = false;
    
    try {
      // Get app-specific directory which doesn't require special permissions
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access storage directory');
      }
      
      // Ensure filename has image extension
      if (!fileName.toLowerCase().endsWith('.jpg') && 
          !fileName.toLowerCase().endsWith('.png') &&
          !fileName.toLowerCase().endsWith('.jpeg')) {
        fileName = '$fileName.jpg';
      }
      
      String filePath = '${directory.path}/$fileName';
      
      // Show initial notification
      if (Platform.isAndroid) {
        await NotificationService.showNotification(
          channelId: 1,
          title: "Downloading $fileName",
          body: "Starting download...",
          summary: "",
          progress: 0,
        );
      }
      
      // Start download with progress tracking
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) async {
          if (total <= 0 || isCompleted) return; // Skip invalid totals or if completed
          
          try {
            // Calculate progress as integer percentage (0-100)
            int currentProgress = ((received / total) * 100).round();
            currentProgress = currentProgress.clamp(0, 100);
            
            // Only update if significant change or reaching 100%
            if ((currentProgress - lastProgressNotified >= 5) || 
                (currentProgress == 100 && !isCompleted)) {
              lastProgressNotified = currentProgress;
              
              if (Platform.isAndroid) {
                await NotificationService.showNotification(
                  channelId: 1,
                  title: "Downloading $fileName",
                  body: "Progress: $currentProgress%", 
                  summary: "",
                  progress: currentProgress,
                );
                
                // Update percentage stream safely
                if (!isCompleted) {
                  try {
                    percentage.add(currentProgress.toDouble());
                  } catch (e) {
                    debugPrint('Error updating percentage stream: $e');
                  }
                }
                
                // Mark as completed if we reach 100%
                if (currentProgress == 100) {
                  isCompleted = true;
                }
              }
            }
          } catch (e) {
            debugPrint('Error calculating progress: $e');
          }
        },
      );
      
      // Cancel progress notification
      if (Platform.isAndroid) {
        await NotificationService.cancelProgressNotification();
      }
      
      // Save to gallery
      if (Platform.isAndroid) {
        final File downloadedFile = File(filePath);
        if (await downloadedFile.exists()) {
          try {
            // Convert file path to Uint8List
            final bytes = await downloadedFile.readAsBytes();
            
            // Save to gallery using bytes
            final result = await ImageGallerySaverPlus.saveImage(
              bytes,
              name: fileName,
              isReturnImagePathOfIOS: true
            );
            
            debugPrint('Gallery save result: $result'); // Debug log
            
            // Show final notification
            await NotificationService.showNotification(
              channelId: 2,
              title: "$fileName downloaded",
              body: "Image saved to gallery. Tap to open.",
              summary: "",
              payload: {"path": filePath},
            );
            
            messageCallBack?.call("Image saved to gallery successfully");
            
          } catch (e) {
            debugPrint('Gallery save error with details: $e');
            
            // Show completion notification even if gallery save failed
            await NotificationService.showNotification(
              channelId: 2,
              title: "$fileName downloaded",
              body: "Image downloaded. Tap to open.",
              summary: "",
              payload: {"path": filePath},
            );
            
            messageCallBack?.call("Image downloaded but gallery save failed: $e");
          }
        } else {
          messageCallBack?.call("Downloaded file not found at: $filePath");
        }
      } else {
        messageCallBack?.call("Image downloaded to: $filePath");
      }
      
    } catch (e) {
      debugPrint('Error downloading image: $e');
      if (Platform.isAndroid) {
        await NotificationService.cancelProgressNotification();
      }
      ShowSnackBar.error(context: context, showMessage: e.toString());
      messageCallBack?.call("Download failed: ${e.toString()}");
    }
  }
}
