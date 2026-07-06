import 'package:flexischool/providers/change_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late ChangePasswordProvider changePasswordProvider;

  @override
  void initState() {
    changePasswordProvider = ChangePasswordProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => changePasswordProvider,
      child: Consumer<ChangePasswordProvider>(
        builder: (context, value, child) => Form(
          key: value.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Stack(
            children: [
              Scaffold(
                bottomNavigationBar: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: kToolbarHeight,
                    margin: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (value.formKey.currentState!.validate()) {
                          value.checkOldPassword(context);
                        }
                      },
                      child: value.changePasswordLoader
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : const Text(
                              'Change Password',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),
                appBar: AppBar(
                  title: const Text(
                    'Change password',
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CommonTextFormField(
                        controller: value.oldPasswordController,
                        labelText: 'Enter Old Password',
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please enter old password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CommonTextFormField(
                        controller: value.newPasswordController,
                        labelText: 'Enter New Password',
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please enter new password';
                          }
                          if (val == value.oldPasswordController.text.trim()) {
                            return 'New password could not be old password';
                          }
                          if (validatePassword(val) != null) {
                            return validatePassword(val);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CommonTextFormField(
                        controller: value.confirmPasswordController,
                        labelText: 'Confirm New Password',
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please confirm new password';
                          }
                          if (val != value.newPasswordController.text) {
                            return 'Password does not match';
                          }
                          if (validatePassword(val) != null) {
                            return validatePassword(val);
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (value.changePasswordLoader)
                Container(color: Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }

  String? validatePassword(String value) {
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one\nuppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one\nlowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one\ndigit';
    }
    if (!value.contains(RegExp(r'[@#$%^&+=]'))) {
      return "Password must contain at least one\nspecial character (@, #, \$, %, ^, &, +, =)";
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }
}

class CommonTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hintText;
  final String? labelText;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;

  const CommonTextFormField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText,
    this.contentPadding,
    this.prefixIcon,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTapOutside: (focusNode) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        disabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        isDense: true,
        contentPadding:
            contentPadding ?? const EdgeInsets.symmetric(vertical: 10.0),
        prefixIcon: prefixIcon,
        labelText: labelText,
        errorStyle: const TextStyle(
          fontFamily: "Montserrat Regular",
          fontSize: 14.0,
        ),
        hintText: hintText,
      ),
      validator: validator,
    );
  }
}
