import 'dart:convert';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_badge/flutter_native_badge.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LoginRoute extends StatelessWidget {
  const LoginRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white, body: LoginWidget());
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final FocusNode noteFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final Duration _showDuration = const Duration(seconds: 2);
  String? _schoolName;
  String? _logo;
  String userType = '';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _is_logo_loading = true;
  bool _imageError = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showPassword() {
    setState(() {
      Clipboard.setData(ClipboardData(text: _obscureText ? '' : '********'));
      Future.delayed(_showDuration, () => Clipboard.setData(const ClipboardData(text: '')));
    });
  }

  //Call Get Url Api
  Future<void> _submitForm(BuildContext context) async {
    final type = await WebService.getLoginType();
    debugPrint('login type ==> $type');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final LoginProvider loginStore = Provider.of<LoginProvider>(context, listen: false);

    if (type == 'S') {
      loginStore.studentLogin(_usernameController.text, _passwordController.text).then((response) {
        if (response == 'You have successfully logged in!') {
          loginStore.loginInStatus = LoginStatus.loggedIn;
          loginStore.notify();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response)));
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/studentDashboard', (Route<dynamic> route) => false);
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response)));
          }
        }
      }).catchError((e) {
        setState(() {
          _errorMessage = 'Invalid Login Credentials.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage)));
        });
      }).whenComplete(() {
        setState(() => _isLoading = false);
      });
    } else {
      loginStore.loginValidate(_usernameController.text, _passwordController.text).then((response) {
        debugPrint('response--- $response');
        if (response['status'] == true) {
          loginStore.loginInStatus = LoginStatus.loggedIn;
          WebService.setTeacherLoginDetails(response['data']);
          loginStore.notify();
          FlutterNativeBadge.clearBadgeCount(requestPermission: true);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (Route<dynamic> route) => false);
          }
        } else {
          _errorMessage = response['message'];
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage)));
          }
        }
      }).catchError((e) {
        setState(() {
          _errorMessage = 'Invalid Login Credentials.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage)));
        });
      }).whenComplete(() {
        setState(() => _isLoading = false);
      });
    }
  }

  void errorMessage(String val) {
    setState(() {
      _errorMessage = val;
    });
  }

  Future<void> checkSchoolUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('global_school_url');
    userType = await WebService.getLoginType();
    setState(() {});
    String schoolUrl = "";
    if (data != null) {
      schoolUrl = data;
      debugPrint("schoolUrl -- $schoolUrl");
    } else {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/schoolUrl', (Route<dynamic> route) => false);
      }
    }

    final schoolLogo = prefs.getString('global_school_logo');

    var requestedData = {"SCHOOL_ID": 1};
    var body = json.encode(requestedData);

    try {
      final response = await ApiService()
          .post(url: '${schoolUrl}schoolsearchbyschoolid/schoolsearchbyschoolid', data: body);
      debugPrint('response.body --- ${response.data}');

      if (response.statusCode == 200) {
        // final responseData = json.decode(response.data);
        final responseSplit = response.data['schoolSearch'][0];

        setState(() {
          _is_logo_loading = false;
          _schoolName = responseSplit['SCHOOL_NAME'];
          _logo = (schoolLogo! + responseSplit['LOGO_PATH']);
          debugPrint('_logo ---$_logo');
        });
      }
    } catch (e) {
      _errorMessage = 'Something went wrong please try again.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage)));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkSchoolUrl());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
                onPressed: () {
                  WebService.clearAllPref();
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                },
                icon: const Icon(Icons.arrow_back_ios),
                color: Colors.black)),
        body: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 0.0),
            child: Padding(
                padding: const EdgeInsets.all(0),
                child: Form(
                    key: _formKey,
                    child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(10.0), children: <Widget>[
                      Text(_schoolName ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontFamily: "Montserrat Regular", fontSize: 25)),
                      const SizedBox(height: 10),
                      Container(
                          alignment: Alignment.center,
                          child: _logo != null
                              ? CachedNetworkImage(imageUrl: _logo!, width: 150)
                              : const SizedBox()),
                      Container(
                          alignment: Alignment.center,
                          child: const Text('Welcome',
                              style: TextStyle(
                                  fontFamily: "Montserrat Regular",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20))),
                      Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                              userType == 'S'
                                  ? 'Sign in as student to continue!'
                                  : 'Sign in as teacher to continue!',
                              style: const TextStyle(fontSize: 16, fontFamily: "Montserrat Regular"))),
                      Container(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                              controller: _usernameController,
                              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(14),
                                  prefixIcon: Icon(Icons.account_circle, size: 25),
                                  labelText: 'User ID',
                                  errorStyle: TextStyle(fontFamily: "Montserrat Regular", fontSize: 14.0)),
                              validator: (value) {
                                errorMessage('');
                                if (value == null || value.isEmpty) {
                                  noteFocus.requestFocus();
                                  return 'Please enter user Id';
                                }
                                return null;
                              })),
                      Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: TextFormField(
                              obscureText: _obscureText,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(14),
                                  prefixIcon: const Icon(Icons.lock, size: 25),
                                  labelText: 'Password',
                                  suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() => _obscureText = !_obscureText);
                                        _showPassword();
                                      },
                                      child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey)),
                                  errorStyle:
                                      const TextStyle(fontFamily: "Montserrat Regular", fontSize: 14.0)),
                              validator: (value) {
                                errorMessage('');
                                if (value == null || value.isEmpty) {
                                  noteFocus.requestFocus();
                                  return 'Please enter Password';
                                }
                                return null;
                              })),
                      const SizedBox(height: 20.0),
                      Container(
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ElevatedButton(
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1.5, color: Colors.deepPurple))
                                  : const Text('Login'),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _isLoading ? null : _submitForm(context);
                                }
                              })),
                      TextButton(
                          onPressed: () {},
                          child: const Text('Forgot Password',
                              style: TextStyle(decoration: TextDecoration.underline))),
                      const SizedBox(height: 10.0),
                      Text(_errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14.0, fontFamily: "Montserrat Regular", color: Colors.red)),
                    ])))));
  }
}
