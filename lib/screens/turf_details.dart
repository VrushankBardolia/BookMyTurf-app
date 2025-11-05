import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';

import '../util/colors.dart';
import '../model/turf.dart';
import '../util/api.dart';
import '../components/slot_selection_widget.dart';

class TurfDetails extends StatefulWidget {
  final int id;
  const TurfDetails({super.key, required this.id});

  @override
  State<TurfDetails> createState() => _TurfDetailsState();
}

class _TurfDetailsState extends State<TurfDetails> {
  late Future<Turf> futureTurf;
  late ScrollController _scrollController;
  bool showTitle = false;
  String turfName = "";
  double _scrollOffset = 0;
  final ValueNotifier<String> selectedDateNotifier = ValueNotifier(
    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
  );


  @override
  void initState() {
    super.initState();
    futureTurf = getTurfById(widget.id);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double opacity = (_scrollOffset / 300).clamp(0, 1);
    if (opacity == 1.0) {
      showTitle = true;
    } else {
      showTitle = false;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: showTitle
            ? Text(turfName,
          style: TextStyle(
            color: BMTTheme.brand,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ) : null,
        backgroundColor: BMTTheme.background.withOpacity(opacity),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: futureTurf,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data found."));
          }

          final turf = snapshot.data!;
          turfName = turf.name;

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        "$API/turfImages/${turf.image}",
                        height: 350,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                BMTTheme.background,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(turf.name,
                          style: TextStyle(
                            color: BMTTheme.brand,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(turf.fullAddress,
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        Text("₹${turf.pricePerHour} per hour",
                          style: TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: BMTTheme.black,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Amenities",
                                style: TextStyle(
                                  color: BMTTheme.brand,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ...turf.amenities.map((amn) => Text("• $amn",
                                style: TextStyle(fontSize: 20),
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text("Book your slot", style: TextStyle(fontSize: 22)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: DatePicker(
                            DateTime.now(),
                            initialSelectedDate: DateTime.now(),
                            daysCount: 30,
                            dateTextStyle: TextStyle(color: BMTTheme.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                            ),
                            dayTextStyle: TextStyle(color: BMTTheme.white),
                            monthTextStyle: TextStyle(color: BMTTheme.white),
                            selectionColor: BMTTheme.brand,
                            selectedTextColor: BMTTheme.black,
                            onDateChange: (date) {
                              selectedDateNotifier.value = "${date.day}/${date.month}/${date.year}";
                            },
                          ),
                        ),

                        SizedBox(height: 8),

                        ValueListenableBuilder<String>(
                          valueListenable: selectedDateNotifier,
                          builder: (context, selectedDate, _) {
                            return SlotSelectionWidget(
                              turf: turf,
                              selectedDate: selectedDate,
                              userId: turf.owner!.id,
                            );
                          },
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
