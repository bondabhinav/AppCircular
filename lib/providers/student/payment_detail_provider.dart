import 'package:flutter/material.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/student/payment_detail_response.dart';

class PaymentDetailProvider with ChangeNotifier {
  final apiService = ApiService();
  PaymentDetailResponse? _paymentDetailResponse;
  bool _isLoading = false;
  String? _errorMessage;

  PaymentDetailResponse? get paymentDetailResponse => _paymentDetailResponse;
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

  Future<void> fetchPaymentDetail(int receiptNo) async {
    try {
      setLoading(true);
      setError(null);

      final studentData = WebService.studentLoginData?.table1?.first;
      if (studentData == null) {
        setError('Student data not found');
        return;
      }

      final requestBody = {
        "RECEIPT_NO": receiptNo.toString(),
        "SESSION_ID": Constants.sessionId,
        "STUDENT_ID": studentData.aDMSTUDENTID,
      };

      final response = await apiService.post(url: Api.getPaymentDetailApi, data: requestBody);

      if (response.statusCode == 200) {
        _paymentDetailResponse = PaymentDetailResponse.fromJson(response.data);
      } else {
        setError('Failed to fetch payment details: ${response.statusCode}');
      }
    } catch (e) {
      setError('Error fetching payment details: $e');
    } finally {
      setLoading(false);
    }
  }

  double get totalPaidAmount {
    if (_paymentDetailResponse?.table1 == null) return 0.0;
    return _paymentDetailResponse!.table1!.fold(0.0, (sum, item) => sum + (item.pAID ?? 0));
  }

  String get paymentDate {
    if (_paymentDetailResponse?.table1?.isNotEmpty == true) {
      final date = _paymentDetailResponse!.table1!.first.dATE;
      if (date != null) {
        try {
          final parsedDate = DateTime.parse(date);
          return "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}";
        } catch (e) {
          return 'N/A';
        }
      }
    }
    return 'N/A';
  }

  int get receiptNumber {
    if (_paymentDetailResponse?.table1?.isNotEmpty == true) {
      return _paymentDetailResponse!.table1!.first.rECIPTNO ?? 0;
    }
    return 0;
  }

  void clearData() {
    _paymentDetailResponse = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
} 