import 'dart:convert';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/change_password_response.dart';
import 'package:flexischool/models/common_model.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:provider/provider.dart';

import '../common/api_urls.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final apiService = ApiService();
  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _changePasswordLoader = false;

  get changePasswordLoader => _changePasswordLoader;

  void setChangePasswordLoader(bool value) {
    _changePasswordLoader = value;
    notifyListeners();
  }

  Future<void> checkOldPassword(BuildContext context) async {
    setChangePasswordLoader(true);
    dynamic teacherData;
    try {
      final type = await WebService.getLoginType();
      if (type.toString() == 'T') {
        teacherData = jsonDecode(await WebService.getTeacherDetails());
        debugPrint('teacherData: ${teacherData['EMPLOYEE_ID']}');
      }
      var data = type.toString() == 'S'
          ? {
              "ADM_NO": WebService.studentLoginData!.table1!.first.aDMNO.toString(),
              "STUD_PASSWORD": oldPasswordController.text
            }
          : {"EMPLOYEE_ID": teacherData['EMPLOYEE_ID'].toString()};
      final response = await apiService.post(
          url: type.toString() == 'S' ? Api.getStudentPasswordApi : Api.getTeacherPasswordApi, data: data);
      if (response.statusCode == 200) {
        final checkOldPasswordResponse = CheckOldPasswordResponse.fromJson(response.data);
        if (checkOldPasswordResponse.table1 != null && checkOldPasswordResponse.table1!.isNotEmpty) {
          if (type.toString() == 'T'
              ? checkOldPasswordResponse.table1!.first.uSER_PASSWORD.toString().trim() == oldPasswordController.text.trim()
              : checkOldPasswordResponse.table1!.first.sTUDPASSWORD.toString().trim() ==
                  oldPasswordController.text.trim()) {
            if (context.mounted) {
              changePassword(context: context, teacherData: teacherData, type: type);
            }
          } else {
            setChangePasswordLoader(false);
            if (context.mounted) {
              ShowSnackBar.error(context: context, showMessage: 'old password is incorrect');
            }
          }
        } else {
          setChangePasswordLoader(false);
          if (context.mounted) {
            customTaost(context, 'Something wents wrong');
          }
        }
      } else {
        setChangePasswordLoader(false);
        if (context.mounted) {
          customTaost(context, 'Something wents wrong');
        }
      }
    } catch (e) {
      setChangePasswordLoader(false);
      if (context.mounted) {
        customTaost(context, 'Something wents wrong');
      }
      debugPrint('Failed to connect to the API ${e.toString()}');
    }
  }

  Future<void> changePassword({required BuildContext context, dynamic type, var teacherData}) async {
    try {
      var data = type.toString() == 'S'
          ? {
              "ADM_NO": WebService.studentLoginData!.table1!.first.aDMNO.toString(),
              "STUD_PASSWORD": newPasswordController.text.trim()
            }
          : {
              "EMPLOYEE_ID": teacherData['EMPLOYEE_ID'].toString(),
              "STUD_PASSWORD": newPasswordController.text
            };
      final response = await apiService.post(
          url: type.toString() == 'S' ? Api.changeStudentPasswordApi : Api.changeTeacherPasswordApi,
          data: data);
      if (response.statusCode == 200) {
        final commonResponse = CommonResponse.fromJson(response.data);
        if (commonResponse.success ?? false) {
          if (context.mounted) {
            ShowSnackBar.successToast(
                context: context, showMessage: 'Password changed successfully, please re-login');
            logout(context);
          }
        } else {
          setChangePasswordLoader(false);
          if (context.mounted) {
            customTaost(context, 'Something wents wrong');
          }
        }
      } else {
        setChangePasswordLoader(false);
        if (context.mounted) {
          customTaost(context, 'Something wents wrong');
        }
      }
    } catch (e) {
      setChangePasswordLoader(false);
      if (context.mounted) {
        customTaost(context, 'Something wents wrong');
      }
      debugPrint('Failed to connect to the API ${e.toString()}');
    }
  }

  void customTaost(BuildContext context, String message) {
    ShowSnackBar.error(context: context, showMessage: message);
  }

  Future<void> logout(BuildContext context) async {
    try {
      String? appDeviceId = await WebService.getFcmData();
      if (context.mounted) {
        if (appDeviceId != null) {
          debugPrint('app Device Id $appDeviceId');
          final studentModel = Provider.of<StudentDashboardProvider>(context, listen: false);
          await studentModel.logoutApi(context, appDeviceId);
          setChangePasswordLoader(false);
        } else {
          debugPrint('else logout');
          final LoginProvider loginStore = Provider.of<LoginProvider>(context, listen: false);
          loginStore.userLogout();
          FlutterAppBadger.removeBadge();
          setChangePasswordLoader(false);
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      setChangePasswordLoader(false);
    }
  }
}
