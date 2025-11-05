import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:book_my_turf/model/turf.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';

class Payment extends StatefulWidget {
  final Turf turf;
  final int advance;
  const Payment({super.key, required this.turf, required this.advance});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  List<ApplicationMeta>? _apps;
  bool _loading = true;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching UPI apps: $e")),
      );
    }
  }

  Future<void> _onAppTap(ApplicationMeta appMeta) async {
    try {
      final transactionRef = DateTime.now().millisecondsSinceEpoch.toString();
      final response = await UpiPay.initiateTransaction(
        amount: widget.advance.toStringAsFixed(0),
        app: appMeta.upiApplication,
        receiverName: widget.turf.name,
        receiverUpiAddress: widget.turf.upi,
        transactionRef: transactionRef,
        transactionNote: 'Advance payment for ${widget.turf.name}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: ${response.status}")),
      );
      // You can also inspect response.transactionId, response.responseCode etc.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment error: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchApps();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pay ${widget.turf.name}"),
      ),
      body: Column(
        children: [
          Text("Total payable: ₹${widget.advance}"),
          Expanded(
            child: _apps!.isNotEmpty ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _apps!.length,
              itemBuilder: (context, index) {
                final meta = _apps![index];
                return ListTile(
                  onTap:()=> _onAppTap(meta),
                  title: Text(meta.upiApplication.getAppName(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  leading: meta.iconImage(50),
                );
              },
            ) : Column(
              children: [
                Icon(CupertinoIcons.multiply_circle,
                  color: Colors.orange,
                  size: 40,
                ),
                Text("No UPI App found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
