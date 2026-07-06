import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flexischool/app_update.dart';
import 'package:flexischool/common/api_urls.dart';
// import 'package:flexischool/common/ota_update_service.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flexischool/screens/check_internet.dart';
import 'package:flexischool/screens/dashboard.dart';
import 'package:flexischool/screens/home.dart';
import 'package:flexischool/screens/login.dart';
import 'package:flexischool/screens/schoolurl.dart';
import 'package:flexischool/screens/student/student_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/config.dart';

// Loader Screen
class LoaderRoute extends StatefulWidget {
  const LoaderRoute({super.key});

  @override
  State<LoaderRoute> createState() => _LoaderRouteState();
}

class _LoaderRouteState extends State<LoaderRoute> {
  late final String appName = Constants.appName;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Load initial data
      await _loadInitialData().timeout(const Duration(seconds: 5));
    } catch (e) {
      log('Startup data load skipped: $e');
    }

    if (!mounted) return;

    // Check connection and navigate
    await _checkConnectionAndNavigate();
  }

  Future<void> _loadInitialData() async {
    // Load login data
    final loginData = await WebService.getStudentLoginDetails();
    if (loginData != null) {
      WebService.studentLoginData = loginData;
      if (mounted) setState(() {});
      log('user data ***** ${loginData.toJson().toString()}');
    }

    // Load URL data
    final schoolUrl = await WebService.getSchoolUrl();
    final imageUrl = await WebService.getSchoolImageUrl();

    Api.baseUrl = schoolUrl;
    if (mounted) setState(() {});
    log('baseUrl ***** ${Api.baseUrl}');

    Api.imageBaseUrl = imageUrl;
    if (mounted) setState(() {});
    log('imageUrlData ***** ${Api.imageBaseUrl}');
  }

  Future<void> _checkConnectionAndNavigate() async {
    List<ConnectivityResult> connectivityResult;
    try {
      connectivityResult = await Connectivity().checkConnectivity().timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      log('Connectivity check skipped: $e');
      await _navigateBasedOnUserState();
      return;
    }

    // Wait for 3 seconds before navigation
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (connectivityResult.contains(ConnectivityResult.none)) {
      // No internet connection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CheckInternet()),
      );
    } else {
      // Has internet connection
      await _navigateBasedOnUserState();
    }
  }

  Future<void> _navigateBasedOnUserState() async {
    if (!mounted) return;

    // OTA update entry point disabled.
    // try {
    //   final otaUpdateAvailable = await OtaUpdateService().checkAndUpdate(
    //     context: context,
    //     showProgress: true,
    //     onProgress: (progress) {
    //       log('OTA Update Progress: ${(progress * 100).toStringAsFixed(1)}%');
    //     },
    //     onError: (error) {
    //       log('OTA Update Error: $error');
    //     },
    //   );
    //
    //   // If OTA update is in progress, don't navigate (user will install update)
    //   if (otaUpdateAvailable) {
    //     return;
    //   }
    // } catch (e) {
    //   log('Error checking OTA update: $e');
    // }

    // Fallback: Check if Play Store update is required
    var updateRequired = false;
    try {
      updateRequired = await checkForUpdate(
        context,
      ).timeout(const Duration(seconds: 6), onTimeout: () => false);
    } catch (e) {
      log('Update check skipped: $e');
    }

    if (updateRequired) {
      _showUpdateRequiredScreen();
      return;
    }

    // Get user states
    final hasSchoolUrl = await _hasSchoolUrl();
    final hasLoginType = await _hasLoginType();
    final hasTeacherUser = await _hasTeacherUser();
    final hasStudentUser = await _hasStudentUser();

    // Navigate based on user state
    if (!hasTeacherUser && !hasStudentUser && !hasSchoolUrl) {
      // New user - go to school URL screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Schoolurl()),
      );
    } else if (!hasTeacherUser && !hasStudentUser && hasSchoolUrl) {
      // Has school URL but not logged in
      if (!hasLoginType) {
        // Go to home to select login type
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        // Go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginRoute()),
        );
      }
    } else {
      // User is logged in
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      loginProvider.assignUserProvider();

      if (hasTeacherUser) {
        // Navigate to teacher dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else if (hasStudentUser) {
        // Navigate to student dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentDashboardScreen(),
          ),
        );
      }
    }
  }

  void _showUpdateRequiredScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _UpdateRequiredScreen()),
    );
  }

  // Helper methods to check user state
  Future<bool> _hasSchoolUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('global_school_url') != null;
  }

  Future<bool> _hasLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('global_login_type') != null;
  }

  Future<bool> _hasTeacherUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_details') != null;
  }

  Future<bool> _hasStudentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('student_data') != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            appName,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 22.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Update Required Screen
class _UpdateRequiredScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, _) {
            SystemNavigator.pop();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    'Update Required',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'A new version of the app is available. Please update to continue using the app.',
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        const playStoreUrl =
                            'https://play.google.com/store/apps/details?id=flexischoolerpapp.sapinfotek.com';
                        if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
                          await launchUrl(Uri.parse(playStoreUrl));
                        } else {
                          throw 'Could not launch Play Store';
                        }
                        SystemNavigator.pop();
                      },
                      child: const Text(
                        'Update Now',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
