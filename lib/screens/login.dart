import 'dart:convert';

import 'package:flexischool/common/webService.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRoute extends StatelessWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      /*
      appBar: AppBar(
        title: const Text('Flexi School'),
      ),*/
      body: LoginWidget(),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  //Form Key
  final FocusNode noteFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  Duration _showDuration = const Duration(seconds: 2);
  String _schoolName = '';
  late String _logo = '';
  String userType = '';

  //TextField Controller
  // TextEditingController _usernameController = TextEditingController(text: 'E00031');
  // TextEditingController _passwordController = TextEditingController(text: 'OPJS123');
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //Err Msg Declare
  bool _isLoading = false;
  String _errorMessage = '';
  bool _is_logo_loading = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showPassword() {
    setState(() {
      Clipboard.setData(ClipboardData(text: _obscureText ? '' : '********'));
      Future.delayed(_showDuration, () {
        Clipboard.setData(const ClipboardData(text: ''));
      });
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response)),
          );
          Navigator.pushReplacementNamed(context, '/studentDashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response)),
          );
        }
      }).catchError((e) {
        setState(() {
          _errorMessage = 'Invalid Login Credentials.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage)),
          );
        });
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      loginStore.loginValidate(_usernameController.text, _passwordController.text).then((response) {
        //API Response
        //print(response);
        if (response['status'] == true) {
          loginStore.loginInStatus = LoginStatus.loggedIn;
          loginStore.notify();

          //print(loginStore.userName);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );

          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          _errorMessage = response['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage)),
          );
        }

        //API Response
      }).catchError((e) {
        setState(() {
          // _errorMessage = 'Error: $e';
          _errorMessage = 'Invalid Login Credentials.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage)),
          );
        });
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
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
      print(schoolUrl);
    } else {
      Navigator.pushReplacementNamed(context, '/schoolUrl');
    }

    final schoolLogo = prefs.getString('global_school_logo');

    //print(schoolLogo);

    var requestedData = {
      "SCHOOL_ID": 1,
    };
    var body = json.encode(requestedData);

    try {
      final response = await http.post(
        Uri.parse('${schoolUrl}schoolsearchbyschoolid/schoolsearchbyschoolid'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          //"Authorization": token
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final responseSplit = responseData['schoolSearch'][0];

        setState(() {
          _is_logo_loading = false;
          _schoolName = responseSplit['SCHOOL_NAME'];
          _logo = (schoolLogo! + responseSplit['LOGO_PATH'])!;
        });

        //print(responseSplit);
      }
    } catch (e) {
      //_errorMessage = 'Get School Logo Error: $e';
      _errorMessage = 'Something went wrong please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    }
    ;
  }

  @override
  void initState() {
    super.initState();
    checkSchoolUrl();
  }

  @override
  Widget build(BuildContext context) {
    //final args = ModalRoute.of(context)!.settings.arguments as String;

    //final LoginProvider LoginStore =  Provider.of<LoginProvider>(context);

    //print(LoginStore.loginInStatus.name);

    //LoginStore.loginInStatus = LoginStatus.loggedIn;
    //LoginStore.notify();

    // print(LoginStore.loginInStatus.name);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              WebService.clearAllPref();
              Navigator.pushReplacementNamed(context, '/home');
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 0.0),
        //color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10.0),
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        _schoolName,
                        style: const TextStyle(
                            //color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Montserrat Regular",
                            fontSize: 25),
                      )),
                  Container(
                      alignment: Alignment.center,
                      //padding: const EdgeInsets.all(10),
                      child: _is_logo_loading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.blue,
                              ),
                            )
                          : Image.network(
                              _logo,
                              width: 150,
                            )),
                  Container(
                      alignment: Alignment.center,
                      //padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Welcome',
                        style: TextStyle(
                            //color: Colors.blue,
                            fontFamily: "Montserrat Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      )),
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        userType == 'S'
                            ? 'Sign in as student to continue!'
                            : 'Sign in as teacher to continue!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "Montserrat Regular",
                        ),
                      )),
                  Container(
                    padding: const EdgeInsets.all(10),
                    //margin: EdgeInsets.only(top:50.0),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        //contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        isDense: true,
                        // Added this
                        contentPadding: EdgeInsets.all(14),
                        prefixIcon: Icon(Icons.account_circle, size: 25),
                        labelText: 'User ID',
                        errorStyle: TextStyle(
                          fontFamily: "Montserrat Regular",
                          fontSize: 14.0,
                        ),
                        //hintText: 'User ID',
                      ),
                      validator: (value) {
                        errorMessage('');
                        if (value == null || value.isEmpty) {
                          noteFocus.requestFocus();
                          return 'Please enter user Id';
                        }
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextFormField(
                      //obscureText: true,
                      obscureText: _obscureText,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        //contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        isDense: true,
                        // Added this
                        contentPadding: const EdgeInsets.all(14),
                        prefixIcon: const Icon(Icons.lock, size: 25),
                        labelText: 'Password',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                            _showPassword();
                          },
                          child: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                        errorStyle: const TextStyle(
                          fontFamily: "Montserrat Regular",
                          fontSize: 14.0,
                        ),
                      ),
                      validator: (value) {
                        errorMessage('');
                        if (value == null || value.isEmpty) {
                          noteFocus.requestFocus();
                          return 'Please enter Password';
                        }
                      },
                    ),
                  ),
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
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _isLoading ? null : _submitForm(context);
                          }

                          //Navigator.pushNamed(context, "/dashboard");
                        },
                      )),
                  TextButton(
                    onPressed: () {
                      //forgot password screen
                    },
                    child:
                        const Text('Forgot Password', style: TextStyle(decoration: TextDecoration.underline)),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    '$_errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Montserrat Regular",
                      color: Colors.red,
                    ),
                  ),
                  /*
                  Row(
                    children: <Widget>[
                      const Text('Does not have account?'),
                      TextButton(
                        child: const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {

                        },
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),*/
                ],
              ),
            )),
      ),
    );
  }
}
