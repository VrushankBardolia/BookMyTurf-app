import 'package:book_my_turf/util/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/colors.dart';

class TurfBookings extends StatefulWidget {
  const TurfBookings({super.key});

  @override
  State<TurfBookings> createState() => _TurfBookingsState();
}

class _TurfBookingsState extends State<TurfBookings> {
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
      future: fetchTurfBookings(userEmail!),
      builder: (context, snapshot){
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
            final turf = booking['turf'];
            final customer = booking['customer'];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BMTTheme.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BMTTheme.brand.withValues(alpha: 0.3)),
              ),
              padding: EdgeInsets.fromLTRB(12,12,12,8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TURF NAME & STATUS BADGE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(turf['name'],
                          style: TextStyle(
                            color: BMTTheme.brand,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _buildDateBadge(booking['date']),
                    ],
                  ),

                  // TURF ADDRESS
                  Text(turf['address'], style: TextStyle(color: BMTTheme.white.withValues(alpha: 0.7)),),
                  SizedBox(height: 4),

                  // CUSTOMER DETAILS
                  Text("Customer Details", style: TextStyle(color: BMTTheme.white50)),

                  // CUSTOMER NAME
                  Row(
                    children: [
                      Icon(CupertinoIcons.person, color: BMTTheme.brand, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(customer['name'],
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),

                  // CUSTOMER PHONE
                  InkWell(
                    onTap: () => launchUrl(Uri(scheme: 'tel', path: customer['phone'])),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.phone, color: BMTTheme.brand, size: 20),
                        SizedBox(width: 8),
                        Text("+91 ${customer['phone']}",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),

                  // CUSTOMER EMAIL
                  Row(
                    children: [
                      Icon(CupertinoIcons.mail, color: BMTTheme.brand, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(customer['email'],
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  // DIVIDER
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Divider(color: BMTTheme.white.withValues(alpha: 0.3)),
                  ),

                  // DATE, SLOT TIMING & DURATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(CupertinoIcons.calendar_today, color: BMTTheme.brand, size: 20),
                              SizedBox(width: 8),
                              Text(formatDisplayDate(booking['date']),
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              )
                            ],
                          ),

                          SizedBox(height: 8),

                          // Booking Time Row
                          Row(
                            children: [
                              Icon(CupertinoIcons.clock, color: BMTTheme.brand, size: 20),
                              SizedBox(width: 8),
                              Text("${formatDisplayTime(booking['start_time'])} → ${formatDisplayTime(booking['end_time'])}",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // DURATION
                      Column(
                        children: [
                          Text("Duration"),
                          Row(
                            children: [
                              Icon(CupertinoIcons.alarm,size: 20, color: BMTTheme.brand,),
                              SizedBox(width: 8,),
                              Text("${booking['duration'].toString()} hr",style: TextStyle(fontSize: 16),),
                            ],
                          )
                        ],
                      )
                    ],
                  ),

                  // DIVIDER
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Divider(color: BMTTheme.white.withValues(alpha: 0.3)),
                  ),

                  // AMOUNT INFO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Amount", style: TextStyle(color: BMTTheme.white50)),
                          // SizedBox(height: 4),
                          Text("₹${booking['total_amount']}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Remaining Amount", style: TextStyle(color: BMTTheme.white50)),
                          // SizedBox(height: 4),
                          Text("₹${booking['advance_amount']}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateBadge(String dateStr) {
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
