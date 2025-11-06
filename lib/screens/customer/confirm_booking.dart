import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:book_my_turf/model/turf.dart';
import 'package:book_my_turf/screens/customer/payment.dart';
import 'package:book_my_turf/components/buttons.dart';
import 'package:book_my_turf/util/colors.dart';
import 'package:book_my_turf/components/input.dart';

class ConfirmBooking extends StatefulWidget {
  final Turf turf;
  final String date;
  final String start;
  final String end;
  final String duration;
  final String totalAmount;

  const ConfirmBooking({
    super.key,
    required this.turf,
    required this.date,
    required this.start,
    required this.end,
    required this.duration,
    required this.totalAmount,
  });

  @override
  State<ConfirmBooking> createState() => _ConfirmBookingState();
}

class _ConfirmBookingState extends State<ConfirmBooking> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController advanceAmountController = TextEditingController();
  late int advance;

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    fullNameController.text = prefs.getString("name")!;
    emailController.text = prefs.getString("email")!;
    phoneController.text = prefs.getString("phone")!;
    dateController.text = widget.date;
    startTimeController.text = "From ${widget.start}";
    endTimeController.text = "To ${widget.end}";
    durationController.text = "For ${widget.duration} hr";
    totalAmountController.text = "Total Amount ₹${widget.totalAmount}";
    final total = double.tryParse(widget.totalAmount) ?? 0;
    advance = (total / 2).round();
    advanceAmountController.text = "Advance Amount ₹$advance";
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Confirm Booking")),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          spacing: 12,
          children: [
            Input(
              controller: fullNameController,
              hint: "Full name",
              type: TextInputType.name,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Input(
              controller: emailController,
              hint: "Email",
              type: TextInputType.emailAddress,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Input(
              controller: phoneController,
              hint: "Phone no.",
              type: TextInputType.phone,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Input(
              controller: dateController,
              hint: "Booking Date",
              type: TextInputType.datetime,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Input(
              controller: startTimeController,
              hint: "Start time",
              type: TextInputType.name,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Input(
              controller: endTimeController,
              hint: "End time",
              type: TextInputType.name,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Input(
              controller: durationController,
              hint: "Duration",
              type: TextInputType.name,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Input(
              controller: totalAmountController,
              hint: "Total Amount",
              type: TextInputType.name,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Input(
              controller: advanceAmountController,
              hint: "Advance Amount",
              type: TextInputType.name,
              bgColor: BMTTheme.black,
              editable: false,
            ),
            Button(
              text: "Pay advance",
              onClick: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Payment(
                    turf: widget.turf,
                    advance: advance,
                    date: widget.date,
                    start: widget.start,
                    end: widget.end,
                    duration: widget.duration,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
