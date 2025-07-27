import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flexischool/providers/student/payment_detail_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/common/webService.dart';

class PaymentDetailScreen extends StatefulWidget {
  final int receiptNumber;

  const PaymentDetailScreen({super.key, required this.receiptNumber});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  late PaymentDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<PaymentDetailProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchPaymentDetail(widget.receiptNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Consumer<PaymentDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchPaymentDetail(widget.receiptNumber),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Receipt Number Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue[300]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    'Receipt Number: ${provider.receiptNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Student Details Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Admission no.', _getStudentAdmissionNo()),
                      const SizedBox(height: 16),
                      _buildDetailRow('Student Name', _getStudentName()),
                      const SizedBox(height: 16),
                      _buildDetailRow('Father\'s Name', _getFatherName()),
                      const SizedBox(height: 16),
                      _buildDetailRow('Class', _getStudentClass()),
                      const SizedBox(height: 16),
                      _buildDetailRow('Section', _getStudentSection()),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Fee Details Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue[300]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Text(
                    'Fee Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Fee Details Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (provider.paymentDetailResponse?.table1 != null)
                        ...provider.paymentDetailResponse!.table1!.map((fee) {
                          return Column(
                            children: [
                              _buildFeeDetailRow(
                                fee.fEETYPEDESC ?? 'N/A',
                                '₹${fee.pAID ?? 0}',
                              ),
                              if (fee != provider.paymentDetailResponse!.table1!.last)
                                const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      
                      if (provider.paymentDetailResponse?.table1?.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 20),
                        _buildFeeDetailRow(
                          'Total Amount',
                          '₹${provider.totalPaidAmount.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // // Pay Now Button (if needed for future functionality)
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 16),
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       // Future payment functionality can be added here
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text('Payment functionality will be implemented'),
                //           backgroundColor: Colors.blue,
                //         ),
                //       );
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       elevation: 2,
                //     ),
                //     child: const Text(
                //       'Pay Now',
                //       style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeDetailRow(String feeType, String amount, {bool isTotal = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            feeType,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.blue : Colors.black87,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: isTotal ? Colors.blue : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _getStudentAdmissionNo() {
    return WebService.studentLoginData?.table1?.first.aDMNO ?? 'N/A';
  }

  String _getStudentName() {
    final studentDashboard = Provider.of<StudentDashboardProvider>(context, listen: false);
    final studentData = studentDashboard.studentDetailResponse?.getstudentData?.first;
    if (studentData != null) {
      return '${studentData.fIRSTNAME ?? ''} ${studentData.lASTNAME ?? ''}'.trim();
    }
    return 'N/A';
  }

  String _getFatherName() {
    final studentDashboard = Provider.of<StudentDashboardProvider>(context, listen: false);
    final studentData = studentDashboard.studentDetailResponse?.getstudentData?.first;
    return studentData?.pARENTNAME ?? 'N/A';
  }

  String _getStudentClass() {
    return WebService.studentLoginData?.table1?.first.cLASSDESC ?? 'N/A';
  }

  String _getStudentSection() {
    return WebService.studentLoginData?.table1?.first.sECTIONDESC ?? 'N/A';
  }
} 