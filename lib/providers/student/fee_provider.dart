import 'package:flutter/material.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/student/fee_response.dart';
import 'package:flexischool/common/constants.dart';

class FeeProvider with ChangeNotifier {
  final apiService = ApiService();
  PaidFeeResponse? _paidFeeResponse;
  UnpaidFeeResponse? _unpaidFeeResponse;
  bool _isLoading = false;
  String? _errorMessage;

  PaidFeeResponse? get paidFeeResponse => _paidFeeResponse;

  UnpaidFeeResponse? get unpaidFeeResponse => _unpaidFeeResponse;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> fetchPaidFees() async {
    try {
      setLoading(true);
      setError(null);

      final studentData = WebService.studentLoginData?.table1?.first;
      if (studentData == null) {
        setError('Student data not found');
        return;
      }

      final requestBody = {
        "ADM_NO": studentData.aDMNO,
        "SESSION_ID": Constants.sessionId,
        "SCHOOL_ID": 1,
        "CLASS_ID": Constants.studentClassId,
        "STUDENT_ID": studentData.aDMSTUDENTID,
      };

      final response = await apiService.post(
        url: Api.getPaidFeesApi,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        _paidFeeResponse = PaidFeeResponse.fromJson(response.data);
      } else {
        setError('Failed to fetch paid fees: ${response.statusCode}');
      }
    } catch (e) {
      setError('Error fetching paid fees: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchUnpaidFees() async {
    try {
      setLoading(true);
      setError(null);

      final studentData = WebService.studentLoginData?.table1?.first;
      if (studentData == null) {
        setError('Student data not found');
        return;
      }

      final requestBody = {
        "ADM_NO": studentData.aDMNO,
        "SESSION_ID": Constants.sessionId,
        "SCHOOL_ID": 1,
        "CLASS_ID": Constants.studentClassId,
        "STUDENT_ID": studentData.aDMSTUDENTID,
      };

      final response = await apiService.post(
        url: Api.getUnpaidFeesApi,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        _unpaidFeeResponse = UnpaidFeeResponse.fromJson(response.data);
      } else {
        setError('Failed to fetch unpaid fees: ${response.statusCode}');
      }
    } catch (e) {
      setError('Error fetching unpaid fees: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchAllFees() async {
    await Future.wait([fetchPaidFees(), fetchUnpaidFees()]);
  }

  double get totalPaidAmount {
    if (_paidFeeResponse?.table1 == null) return 0.0;
    return _paidFeeResponse!.table1!.fold(
      0.0,
      (sum, item) => sum + (item.pAID ?? 0),
    );
  }

  double get totalUnpaidAmount {
    if (_unpaidFeeResponse?.table1 == null) return 0.0;
    return _unpaidFeeResponse!.table1!.fold(
      0.0,
      (sum, item) => sum + (item.uNPAID ?? 0),
    );
  }

  void clearData() {
    _paidFeeResponse = null;
    _unpaidFeeResponse = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
