import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ShowSnackBar {
  static successToast({required BuildContext context, required String showMessage}) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: showMessage,
      ),
    );
  }

  static void error({required BuildContext context, required String showMessage}) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: showMessage,
      ),
    );
  }

  static void info({required BuildContext context, required String showMessage}) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: showMessage,
      ),
    );
  }
}
