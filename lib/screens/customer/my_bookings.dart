import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/api.dart';
import '../../util/colors.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  String? userEmail;

  Future<void> fetchUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString("email");
    });
  }

  String formatDisplayDate(String yyyyMMdd) {
    final date = DateTime.parse(yyyyMMdd);
    return DateFormat("dd MMMM y").format(date);
  }

  String formatDisplayTime(String hhmmss) {
    try {
      final parsed = DateFormat("HH:mm:ss").parse(hhmmss);
      return DateFormat("h:mm a").format(parsed);
    } catch (e) {
      return hhmmss;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    if (userEmail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: fetchCustomerBookings(userEmail!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No bookings yet"));
        }

        final bookings = snapshot.data!;

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, i) {
            final booking = bookings[i];
            return bookingCard(booking);
          },
        );
      },
    );
  }

  // --- Helper Widget for the Booking Card ---
  Widget bookingCard(Map<String, dynamic> booking) {
    final turf = booking['turf'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // Use a slightly lighter dark color for the card background for contrast
        color: BMTTheme.black,
        borderRadius: BorderRadius.circular(20),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: BMTTheme.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------------
          // SECTION 1: TURF INFO & STATUS
          // ------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(turf['name'],
                      style: TextStyle(
                        color: BMTTheme.brand,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(turf['address'],
                      style: TextStyle(
                        color: BMTTheme.white,
                        // fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              statusBadge(booking['date']),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: BMTTheme.white50),
          ),

          // ------------------------------------------------------------------
          // SECTION 2: BOOKING SLOT & DURATION
          // ------------------------------------------------------------------
          const Text("Booking Slot", style: TextStyle(color: BMTTheme.white50, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // DATE & TIME
              Row(
                children: [
                  Icon(CupertinoIcons.calendar_today, color: BMTTheme.brand, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatDisplayDate(booking['date']),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text("${formatDisplayTime(booking['start_time'])} - ${formatDisplayTime(booking['end_time'])}",
                        style: TextStyle(fontSize: 14, color: BMTTheme.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
              ),

              // DURATION
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BMTTheme.brand.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.alarm, size: 18, color: BMTTheme.brand),
                    const SizedBox(width: 6),
                    Text("${booking['duration'].toString()} hr",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: BMTTheme.brand),
                    ),
                  ],
                ),
              )
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: BMTTheme.white50),
          ),

          // ------------------------------------------------------------------
          // SECTION 4: AMOUNT INFO
          // ------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total amount
              Flexible(
                flex: 1,
                child: Column(
                  // crossAxisAlignment: isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text("Total Amount", style: TextStyle(color: BMTTheme.white50, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text("₹${booking['total_amount']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: BMTTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Advance Paid", style: TextStyle(color: BMTTheme.white50, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text("₹${booking['advance_amount']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Remaining Due", style: TextStyle(color: BMTTheme.white50, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text("₹${booking['advance_amount']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: BMTTheme.white50),
          ),
          // GOOGLE MAP LINK BUTTON
          if (turf['map_link'] != null && turf['map_link'].toString().isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse(turf['map_link']), mode: LaunchMode.externalApplication);
                },
                icon: Icon(CupertinoIcons.map, color: BMTTheme.brand),
                label: Text("Open in Google Maps",
                  style: TextStyle(
                    color: BMTTheme.brand,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget statusBadge(String dateStr) {
    final today = DateTime.now();
    final bookingDate = DateTime.parse(dateStr);

    String text;
    Color color;

    if (bookingDate.isBefore(DateTime(today.year, today.month, today.day))) {
      text = "Completed";
      color = Colors.green;
    } else if (bookingDate.isAtSameMomentAs(DateTime(today.year, today.month, today.day))) {
      text = "Today";
      color = Colors.orange;
    } else {
      text = "Upcoming";
      color = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

}