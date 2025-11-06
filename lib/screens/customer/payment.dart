import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:book_my_turf/screens/home.dart';
import 'package:book_my_turf/model/turf.dart';
import 'package:book_my_turf/util/colors.dart';
import '../../util/api.dart';

class Payment extends StatefulWidget {
  final Turf turf;
  final String date;
  final String start;
  final String end;
  final String duration;
  final int advance;

  const Payment({
    super.key,
    required this.turf,
    required this.advance,
    required this.date,
    required this.start,
    required this.end,
    required this.duration,
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  List<ApplicationMeta>? _apps;
  bool _loading = true;
  String email = "";

  Future<void> fetchUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email")!;
  }

  Future<void> _fetchApps() async {
    try {
      final apps = await UpiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all,
      );
      setState(() {
        _apps = apps;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _apps = [];
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching UPI apps: $e")));
    }
  }

  Future<void> onAppTap(ApplicationMeta appMeta) async {
    try {
      final transactionRef = DateTime.now().millisecondsSinceEpoch.toString();
      saveBooking();

      final response = await UpiPay.initiateTransaction(
        amount: widget.advance.toStringAsFixed(0),
        app: appMeta.upiApplication,
        receiverName: widget.turf.name,
        receiverUpiAddress: widget.turf.upi,
        transactionRef: transactionRef,
        transactionNote: 'Advance payment for ${widget.turf.name}',
      );

      String message;
      Color color = Colors.blue;
      IconData icon = Icons.info_outline;

      switch (response.status) {
        case UpiTransactionStatus.success:
          message = "✅ Payment Successful!";
          color = Colors.green;
          icon = Icons.check_circle_outline;
          break;

        case UpiTransactionStatus.failure:
          message = "Payment Failed. Please try again.";
          color = Colors.red;
          icon = Icons.cancel_outlined;
          break;

        case UpiTransactionStatus.submitted:
          message = "Transaction Submitted. Awaiting confirmation.";
          color = Colors.orange;
          icon = Icons.hourglass_bottom;
          break;
        case null:
          // TODO: Handle this case.
          throw UnimplementedError();
        case UpiTransactionStatus.launched:
          message = "💸 UPI App Launched. Booking saved!";
          color = Colors.blueAccent;
          icon = Icons.launch;
          break;
        case UpiTransactionStatus.failedToLaunch:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      if (!mounted) return;

      // Custom snack UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // NAVIGATE TO THE HOME SCREEN AFTER SUCCESSFUL PAYMENT
      if (response.status == UpiTransactionStatus.success) {
        // saveBooking();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false, // removes all previous routes
        );
      }

      // NAVIGATE TO THE HOME SCREEN AFTER UPI APP LAUNCHED (TESTING PURPOSE)
      if (response.status == UpiTransactionStatus.submitted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false, // removes all previous routes
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Payment Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatDateForMySQL(String date) {
    try {
      final inputFormat = DateFormat("d/M/yyyy");
      final parsed = inputFormat.parse(date);
      return DateFormat("yyyy-MM-dd").format(parsed);
    } catch (e) {
      print("Date parsing error: $e");
      return date; // fallback
    }
  }

  // Convert time from hh:mm a → HH:mm:ss (MySQL safe)
  String formatTimeForMySQL(String time) {
    try {
      final parsed = DateFormat("hh:mm a").parse(time);
      return DateFormat("HH:mm:ss").format(parsed);
    } catch (e) {
      print("Time parsing error: $e");
      return time;
    }
  }

  Future<void> saveBooking() async {
    try {
      final bookingResponse = await bookSlot(
        turfId: widget.turf.id,
        email: email,
        date: formatDateForMySQL(widget.date),
        startTime: formatTimeForMySQL(widget.start),
        endTime: formatTimeForMySQL(widget.end),
        duration: int.parse(widget.duration),
        totalAmount: widget.advance * 2,
        advanceAmount: widget.advance,
      );

      if (!mounted) return;
      print("Booking API Response: $bookingResponse");

      if (bookingResponse['status'] == 'success') {
        print("Booking chaltu thayu");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("🎉 Booking Confirmed!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ Booking failed: ${bookingResponse['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving booking: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchApps();
    fetchUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pay ${widget.turf.name}")),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 16),
            margin: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: BMTTheme.black,
              boxShadow: [
                BoxShadow(
                  color: BMTTheme.brand.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Text("Total payable: ₹${widget.advance}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _apps!.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _apps!.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final meta = _apps![index];
                      return ListTile(
                        onTap: () => onAppTap(meta),
                        title: Text(
                          meta.upiApplication.getAppName(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        leading: meta.iconImage(50),
                      );
                    },
                  )
                : noUPIAppFound(),
          ),
        ],
      ),
    );
  }

  Widget noUPIAppFound() {
    return Column(
      children: [
        SizedBox(height: 120),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: BMTTheme.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.1),
                  Colors.orange.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    color: Colors.orange,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No UPI App Found",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please install a UPI-enabled app (like Google Pay, PhonePe, or Paytm) to continue with the payment.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: BMTTheme.white50,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
