import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flexischool/common/dio_client.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

ValueNotifier<String> downloadMessage = ValueNotifier('');

class DownloadPdf {
  static final StreamController<double> percentage =
      StreamController<double>.broadcast();

  static Future<void> downloadPdf(
    String url,
    String fileName,
    BuildContext context,
    Function(String)? messageCallBack, {
    bool saveImagesToGallery = true,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _showError(
        context,
        messageCallBack,
        'Please check your internet connection and try again!',
      );
      return;
    }

    final safeFileName = _safeFileName(fileName, url);
    var notificationId = _notificationId('$url|$safeFileName');
    var lastProgressNotified = -1;

    try {
      final downloadDirectory = await _downloadDirectory();
      await downloadDirectory.create(recursive: true);

      final filePath = await _availableFilePath(
        downloadDirectory,
        safeFileName,
      );
      notificationId = _notificationId(filePath);
      final dio = DioClient.create();

      debugPrint('Download start: $url');
      debugPrint('Download target: $filePath');

      if (Platform.isAndroid) {
        await NotificationService.showDownloadProgress(
          id: notificationId,
          fileName: safeFileName,
          progress: 0,
        );
      }

      await dio.download(
        url,
        filePath,
        options: Options(
          followRedirects: true,
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(seconds: 30),
        ),
        onReceiveProgress: (received, total) async {
          if (total <= 0) {
            return;
          }

          final progress = ((received / total) * 100)
              .round()
              .clamp(0, 100)
              .toInt();
          _emitProgress(progress.toDouble());

          if (!Platform.isAndroid) {
            return;
          }

          final shouldNotify =
              progress == 100 ||
              lastProgressNotified < 0 ||
              progress - lastProgressNotified >= 5;

          if (shouldNotify) {
            lastProgressNotified = progress;
            await NotificationService.showDownloadProgress(
              id: notificationId,
              fileName: safeFileName,
              progress: progress,
            );
          }
        },
      );

      final downloadedFile = File(filePath);
      if (!await downloadedFile.exists()) {
        throw FileSystemException('Downloaded file was not found', filePath);
      }

      _emitProgress(100);

      if (Platform.isAndroid) {
        await NotificationService.cancelProgressNotification(
          id: notificationId,
        );
      }

      final galleryMessage = await _saveImageToGalleryIfNeeded(
        downloadedFile,
        safeFileName,
        saveImagesToGallery,
      );

      final completeMessage = galleryMessage ?? 'File saved to: $filePath';
      downloadMessage.value = completeMessage;
      messageCallBack?.call(completeMessage);

      await NotificationService.showDownloadComplete(
        id: notificationId + 1,
        fileName: safeFileName,
        filePath: filePath,
        body: _completionNotificationBody(galleryMessage),
      );
    } on DioException catch (e) {
      await _handleFailure(
        context: context,
        messageCallBack: messageCallBack,
        notificationId: notificationId,
        fileName: safeFileName,
        error: _dioErrorMessage(e),
      );
    } catch (e) {
      await _handleFailure(
        context: context,
        messageCallBack: messageCallBack,
        notificationId: notificationId,
        fileName: safeFileName,
        error: e.toString(),
      );
    }
  }

  static Future<Directory> _downloadDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw FileSystemException('Could not access Android storage directory');
      }
      return Directory(path.join(directory.path, 'downloads'));
    }

    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return Directory(path.join(directory.path, 'Downloads'));
    }

    final directory = await getApplicationDocumentsDirectory();
    return Directory(path.join(directory.path, 'Downloads'));
  }

  static String _safeFileName(String fileName, String url) {
    final parsedUrl = Uri.tryParse(url);
    final urlFileName = parsedUrl != null && parsedUrl.pathSegments.isNotEmpty
        ? parsedUrl.pathSegments.last
        : null;
    final candidate = fileName.trim().isNotEmpty ? fileName : urlFileName;
    final decoded = _decodeFileName(candidate ?? '');
    final baseName = path.basename(decoded).split('?').first.trim();
    final sanitized = baseName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (sanitized.isNotEmpty) {
      return sanitized;
    }

    return 'download_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String _decodeFileName(String fileName) {
    try {
      return Uri.decodeComponent(fileName);
    } catch (_) {
      return fileName;
    }
  }

  static Future<String> _availableFilePath(
    Directory directory,
    String fileName,
  ) async {
    final extension = path.extension(fileName);
    final nameWithoutExtension = path.basenameWithoutExtension(fileName);

    var candidate = path.join(directory.path, fileName);
    var suffix = 1;

    while (await File(candidate).exists()) {
      candidate = path.join(
        directory.path,
        '$nameWithoutExtension ($suffix)$extension',
      );
      suffix += 1;
    }

    return candidate;
  }

  static int _notificationId(String value) {
    return (value.hashCode & 0x3fffffff) + 1000;
  }

  static Future<String?> _saveImageToGalleryIfNeeded(
    File file,
    String fileName,
    bool saveImagesToGallery,
  ) async {
    if (!saveImagesToGallery ||
        !Platform.isAndroid ||
        !_isImageFile(fileName)) {
      return null;
    }

    try {
      final result = await ImageGallerySaverPlus.saveFile(
        file.path,
        name: path.basenameWithoutExtension(fileName),
      );
      debugPrint('Gallery save result: $result');
      return 'Image saved to gallery successfully';
    } catch (e) {
      debugPrint('Gallery save failed: $e');
      return 'File downloaded, but gallery save failed: $e';
    }
  }

  static bool _isImageFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.png' ||
        extension == '.gif' ||
        extension == '.webp' ||
        extension == '.heic';
  }

  static String _completionNotificationBody(String? galleryMessage) {
    if (galleryMessage == 'Image saved to gallery successfully') {
      return 'Saved to gallery. Tap to open.';
    }

    return 'Tap to open.';
  }

  static void _emitProgress(double progress) {
    try {
      percentage.add(progress);
    } catch (e) {
      debugPrint('Error updating download progress stream: $e');
    }
  }

  static String _dioErrorMessage(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return 'Download failed with status code $statusCode';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Download timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Network connection failed. Please try again.';
      case DioExceptionType.cancel:
        return 'Download was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Could not verify the download server.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return error.message ?? 'Download failed. Please try again.';
    }
  }

  static Future<void> _handleFailure({
    required BuildContext context,
    required Function(String)? messageCallBack,
    required int notificationId,
    required String fileName,
    required String error,
  }) async {
    debugPrint('Download failed: $error');

    if (Platform.isAndroid) {
      await NotificationService.cancelProgressNotification(id: notificationId);
    }

    downloadMessage.value = error;
    messageCallBack?.call('Download failed: $error');

    if (context.mounted) {
      ShowSnackBar.error(context: context, showMessage: error);
    }

    await NotificationService.showDownloadFailed(
      id: notificationId + 2,
      fileName: fileName,
      body: error,
    );
  }

  static void _showError(
    BuildContext context,
    Function(String)? messageCallBack,
    String message,
  ) {
    downloadMessage.value = message;
    messageCallBack?.call(message);
    if (context.mounted) {
      ShowSnackBar.error(context: context, showMessage: message);
    }
  }
}
