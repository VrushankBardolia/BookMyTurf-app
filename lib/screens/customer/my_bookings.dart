import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
            final turf = booking['turf'];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: BMTTheme.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BMTTheme.brand.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  // Top Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      '$API/turfImages/${turf['image']}',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Turf Name + Date Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                turf['name'],
                                style: TextStyle(
                                  color: BMTTheme.brand,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildDateBadge(booking['date']),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Address or Area
                        Text(
                          turf['address'] ?? turf['area'],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Time Row
                        Row(
                          children: [
                            Icon(Icons.access_time, color: BMTTheme.brand, size: 20),
                            SizedBox(width: 6),
                            Text(
                              "${booking['start_time']} → ${booking['end_time']}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Amount Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: ₹${booking['total_amount']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Advance: ₹${booking['advance_amount']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

}