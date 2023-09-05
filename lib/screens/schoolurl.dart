import 'package:flexischool/providers/url_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/config.dart';

//Get School Url Screen
class Schoolurl extends StatelessWidget {
  const Schoolurl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //appBar: AppBar(
      //  title: const Text('Flexi School'),
      // ),
      //backgroundColor: Color(0xfffff8ef),
      body: SchoolurlWidget(),
    );
  }
}

class SchoolurlWidget extends StatefulWidget {
  const SchoolurlWidget({Key? key}) : super(key: key);

  @override
  State<SchoolurlWidget> createState() => _SchoolurlWidgetState();
}

class _SchoolurlWidgetState extends State<SchoolurlWidget> {
  //Form Declaration
  final FocusNode noteFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  // final _urlController =
  //    TextEditingController(text: 'https://swamivivekananddemo.sapinfotek.com');
  final _urlController = TextEditingController();

  //final _controller = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  //Call Get Url Api
  Future<void> _getUrl(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final UrlProvider urlAuth = Provider.of<UrlProvider>(context, listen: false);

    urlAuth.getUrl(_urlController.text).then((response) async {
      //API Response

      if (response['status'] == true) {
        urlAuth.urlInStatus = UrlStatus.urlIn;
        urlAuth.notify();

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(response['message'])),
        // );

        Navigator.pushReplacementNamed(context, '/login');
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
        _errorMessage = 'Something went wrong please try again.';
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

  void errorMessage(String val) {
    setState(() {
      _errorMessage = val;
    });
  }

  Future<void> checkData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('school_url_response');
    if (data != null) {
      // Do something with the data
      // print('school_url_response');
    }
  }

  // Future<void> _submitForm() async {
  //
  //   //Navigator.pushReplacementNamed(context, '/login');
  //
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = '';
  //   });
  //
  //
  //   var requestedData = {
  //     "SCHOOL_URL": _controller.text,
  //   };
  //   var body = json.encode(requestedData);
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(Constants.baseUrl+'GetURL'),
  //       headers: {
  //         "Accept": "application/json",
  //         "Content-Type": "application/json",
  //         //"Authorization": token
  //       },
  //       body: body,
  //     );
  //
  //
  //     if (response.statusCode == 200) {
  //         // Handle successful response.
  //       final responseData = json.decode(response.body);
  //       final responseSplit = responseData['Table1'][0];
  //
  //       final SchoolurlResponse = SchoolUrl.fromJson(responseSplit);
  //       final preferences = await SharedPreferences.getInstance();
  //
  //       var res = SchoolurlResponse.toJson();
  //       await preferences.setString(
  //         'school_url_response',
  //         json.encode(SchoolurlResponse.toJson()),
  //
  //       );
  //
  //       Navigator.pushReplacementNamed(context, '/login');
  //       //print(res['API_URL']);
  //
  //
  //     } else {
  //       setState(() {
  //         _errorMessage = 'Unexpected response: ${response.statusCode}';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //      // _errorMessage = 'Error: $e';
  //       _errorMessage = 'Something went wrong please try again.';
  //     });
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  //
  // }

  @override
  void initState() {
    super.initState();
    _errorMessage = '';
    checkData();
  }

  @override
  Widget build(BuildContext context) {
    // to get size
    var size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/images/pattern.jpg"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: size.height * .1,
                margin: const EdgeInsets.only(top: 10.0),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/sap.jpg"),
                    //image: NetworkImage(
                    //    'https://png.pngtree.com/background/20210712/original/pngtree-vector-school-building-background-design-picture-image_1180541.jpg'),
                    //fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: size.height * .2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/school-clip-art-86.png"),
                    //image: NetworkImage(
                    //    'https://png.pngtree.com/background/20210712/original/pngtree-vector-school-building-background-design-picture-image_1180541.jpg'),
                    //fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Flexi School',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Montserrat Regular",
                  fontSize: 20.0,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _urlController,
                focusNode: noteFocus,
                //initialValue: "https://swamivivekananddemo.sapinfotek.com",
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Enter your school url here',
                  border: OutlineInputBorder(),
                  //contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  isDense: true,
                  // Added this
                  contentPadding: EdgeInsets.all(14),
                  prefixIcon: Icon(Icons.public, size: 25),
                  //labelText: 'Enter your school url here',
                  filled: true,
                  fillColor: Colors.white,
                  errorStyle: TextStyle(
                    fontFamily: "Montserrat Regular",
                    fontSize: 14.0,
                  ),
                ),
                validator: (value) {
                  errorMessage('');
                  if (value == null || value.isEmpty) {
                    noteFocus.requestFocus();
                    return 'Please enter school url';
                  }

                  if (!isValidUrl(value)) {
                    return 'Please enter a valid URL.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              Container(
                width: 150.0,
                height: 40,
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
                      : const Text('Submit'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      //padding: MaterialStateProperty.all(EdgeInsets.all(50)),
                      textStyle:
                          MaterialStateProperty.all(const TextStyle(fontSize: 18, color: Colors.white))),
                  onPressed: () {
                    //errorMessage('Test Error');

                    if (_formKey.currentState!.validate()) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('Processing Data')),
                      // );

                      //_isLoading ? null : _submitForm();
                      _isLoading ? null : _getUrl(context);
                    }

                    //Navigator.pushNamed(context, "/login",arguments: " Login");
                  },
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                '$_errorMessage',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontFamily: "Montserrat Regular",
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
