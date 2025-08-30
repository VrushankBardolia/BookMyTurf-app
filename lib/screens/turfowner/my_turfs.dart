import 'package:book_my_turf/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/screens/turfowner/add_turf.dart';
import '/util/api.dart';
import '/components/turf_card.dart';
import '/model/turf.dart';

class MyTurfs extends StatefulWidget {
  const MyTurfs({super.key});

  @override
  State<MyTurfs> createState() => _MyTurfsState();
}

class _MyTurfsState extends State<MyTurfs> {
  Future<List<Turf>>? futureTurfs;

  Future<void> getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("id");
    print(id);
    setState(() {
      futureTurfs = getMyTurfs(id!);
    });
  }

  @override
  void initState() {
    super.initState();
    getId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: FutureBuilder<List<Turf>>(
          future: futureTurfs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final turfs = snapshot.data ?? [];

            if (turfs.isEmpty) {
              return Center(child: Text("No Turfs Found"));
            }

            return ListView.builder(
              itemCount: turfs.length,
              itemBuilder: (context, index) => TurfCard(turf: turfs[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 0,
        backgroundColor: BMTTheme.brand,
        onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTurf())),
        label: Text("Add new turf"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
