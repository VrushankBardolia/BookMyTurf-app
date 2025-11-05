import 'package:book_my_turf/screens/customer/confirm_booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/turf.dart';
import '../util/api.dart';
import '../components/buttons.dart';
import '../util/colors.dart';

class SlotSelectionWidget extends StatefulWidget {
  // final int turfId;
  final String selectedDate;
  // final int pricePerHour;
  final Turf turf;
  final int userId;

  const SlotSelectionWidget({
    super.key,
    // required this.turfId,
    required this.selectedDate,
    // required this.pricePerHour,
    required this.turf,
    required this.userId,
  });

  @override
  State<SlotSelectionWidget> createState() => _SlotSelectionWidgetState();
}

class _SlotSelectionWidgetState extends State<SlotSelectionWidget>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> slots = [];
  String? selectedStart;
  String? selectedEnd;
  bool isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    loadSlots();
  }

  @override
  void didUpdateWidget(covariant SlotSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        selectedStart = null;
        selectedEnd = null;
        isLoading = true;
      });
      loadSlots();
    }
  }

  Future<void> loadSlots() async {
    setState(() => isLoading = true);
    _fadeController.reset();
    try {
      final data = await fetchSlots(widget.turf.id, widget.selectedDate);
      setState(() {
        slots = data;
        isLoading = false;
      });
      _fadeController.forward();
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmBooking(
          turf: widget.turf,
          date: widget.selectedDate,
          start: formattedStart,
          end: formattedEnd,
          duration: hours.toString(),
          totalAmount: totalPrice.toString(),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select Start Time",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: slots.map((slot) {
              final time = slot['start_time'];
              final isBooked = slot['is_booked'];
              final isSelected = time == selectedStart;
              return ChoiceChip(
                label: Text(formatTo12Hour(time),
                  style: TextStyle(color: isSelected ? BMTTheme.black : BMTTheme.white),
                ),
                checkmarkColor: isSelected ? BMTTheme.black : BMTTheme.white,
                selected: isSelected,
                onSelected: isBooked ? null : (v) => selectStart(time),
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
            children: slots.map((slot) {
              final time = slot['end_time'];
              final startSelected = selectedStart != null;
              bool valid = false;
              if (startSelected) {
                final start = DateTime.parse("1970-01-01T$selectedStart");
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
                checkmarkColor: isSelected ? BMTTheme.black : BMTTheme.white,
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
    );
  }
}
