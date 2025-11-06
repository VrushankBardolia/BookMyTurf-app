import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';

import '/screens/customer/confirm_booking.dart';
import '/model/turf.dart';
import '/util/api.dart';
import '/util/colors.dart';
import '/components/buttons.dart';

class SlotBooking extends StatefulWidget {
  final Turf turf;
  const SlotBooking({super.key, required this.turf});

  @override
  State<SlotBooking> createState() => _SlotBookingState();
}

class _SlotBookingState extends State<SlotBooking> with SingleTickerProviderStateMixin {
  String selectedDate = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  List<Map<String, dynamic>> slots = [];
  String? selectedStart;
  String? selectedEnd;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSlots();
  }

  Future<void> loadSlots() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchSlots(widget.turf.id, selectedDate);
      setState(() {
        slots = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String formatTo12Hour(String time) {
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsed);
    } catch (e) {
      return time;
    }
  }

  void selectStart(String time) {
    setState(() {
      selectedStart = time;
      selectedEnd = null;
    });
  }

  void selectEnd(String time) {
    setState(() => selectedEnd = time);
  }

  Duration? getDuration() {
    if (selectedStart == null || selectedEnd == null) return null;
    final start = DateTime.parse("1970-01-01T$selectedStart");
    var end = DateTime.parse("1970-01-01T$selectedEnd");
    if (selectedEnd == "00:00:00") {
      end = end.add(const Duration(days: 1));
    }
    if (end.isBefore(start)) return null;
    return end.difference(start);
  }

  bool isToday(String dateStr) {
    final now = DateTime.now();
    final today = "${now.day}/${now.month}/${now.year}";
    return today == dateStr;
  }

  bool isPastTime(String time) {
    final now = DateTime.now();
    final parsedTime = DateFormat("HH:mm:ss").parse(time);
    return parsedTime.hour < now.hour ||
        (parsedTime.hour == now.hour && parsedTime.minute <= now.minute);
  }

  Future<void> confirmBooking() async {
    if (selectedStart == null || selectedEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select valid slots")),
      );
      return;
    }

    final duration = getDuration();
    if (duration == null || duration.inMinutes < 60) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid duration")));
      return;
    }

    final hours = duration.inHours;
    final totalPrice = hours * widget.turf.pricePerHour;

    final formattedStart = formatTo12Hour(selectedStart!);
    final formattedEnd = formatTo12Hour(selectedEnd!);

    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => ConfirmBooking(
          turf: widget.turf,
          date: selectedDate,
          start: formattedStart,
          end: formattedEnd,
          duration: hours.toString(),
          totalAmount: totalPrice.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book ${widget.turf.name}"),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🗓️ Date Picker
              Text("Select Date",
                style: TextStyle(
                  fontSize: 18,
                  color: BMTTheme.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 120,
                child: DatePicker(
                  DateTime.now(),
                  initialSelectedDate: DateTime.now(),
                  daysCount: 30,
                  dateTextStyle: TextStyle(
                    color: BMTTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  dayTextStyle: TextStyle(color: BMTTheme.white),
                  monthTextStyle: TextStyle(color: BMTTheme.white),
                  selectionColor: BMTTheme.brand,
                  selectedTextColor: BMTTheme.black,
                  onDateChange: (date) {
                    setState(() {
                      selectedDate = "${date.day}/${date.month}/${date.year}";
                      selectedStart = null;
                      selectedEnd = null;
                    });
                    loadSlots();
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ⏰ Slots Section
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Start Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slots.map((slot) {
                        final time = slot['start_time'];
                        final isBooked = slot['is_booked'];
                        // ⏱ Disable past slots for today
                        final shouldDisable =
                            (isToday(selectedDate) && isPastTime(time)) ||
                                isBooked;
                        final isSelected = time == selectedStart;
                        return ChoiceChip(
                          label: Text(
                            formatTo12Hour(time),
                            style: TextStyle(
                              color: shouldDisable
                                  ? Colors.grey.shade600
                                  : isSelected
                                  ? BMTTheme.black
                                  : BMTTheme.white,
                            ),
                          ),
                          checkmarkColor: isSelected ? BMTTheme.black : BMTTheme.white,
                          selected: isSelected,
                          onSelected: shouldDisable ? null : (v) => selectStart(time),
                          selectedColor: BMTTheme.brand,
                          disabledColor: BMTTheme.black50,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Select End Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slots.map((slot) {
                        final time = slot['end_time'];
                        final startSelected = selectedStart != null;
                        bool valid = false;
                        if (startSelected) {
                          final start =
                          DateTime.parse("1970-01-01T$selectedStart");
                          var end = DateTime.parse("1970-01-01T$time");
                          if (time == "00:00:00") {
                            end = end.add(const Duration(days: 1));
                          }
                          valid = end.isAfter(start);
                        }
                        final isSelected = time == selectedEnd;
                        return ChoiceChip(
                          label: Text(
                            formatTo12Hour(time),
                            style: TextStyle(
                              color: isSelected ? BMTTheme.black : BMTTheme.white,
                            ),
                          ),
                          checkmarkColor:
                          isSelected ? BMTTheme.black : BMTTheme.white,
                          selected: isSelected,
                          onSelected: (!valid || slot['is_booked'])
                              ? null
                              : (v) => selectEnd(time),
                          selectedColor: BMTTheme.brand,
                          disabledColor: BMTTheme.black50,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    if (getDuration() != null)
                      Text("Your slot duration: ${getDuration()!.inHours} hour(s)",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    const SizedBox(height: 20),
                    Button(text: "Book", onClick: confirmBooking),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
