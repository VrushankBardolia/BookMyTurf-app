import 'package:book_my_turf/screens/turf_details.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/components/buttons.dart';
import '/util/colors.dart';
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

  @override
  void initState() {
    super.initState();
    _loadTurfs();
  }

  /// Fetch owner ID and load turfs
  Future<void> _loadTurfs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("id");

    if (id == null) {
      setState(() => futureTurfs = Future.error("Owner ID not found"));
      return;
    }

    setState((){
      futureTurfs = getMyTurfs(id);
    });
  }

  /// Refresh turfs when user returns from AddTurf screen
  Future<void> _navigateToAddTurf() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTurf()),
    );
    _loadTurfs(); // reload list after returning
  }

  Future<void> _navigateToTurfDetails(Turf turf) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TurfDetails(turf: turf,)),
    );
    _loadTurfs(); // reload list after returning
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
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Something went wrong.\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }

            final turfs = snapshot.data ?? [];

            // ✅ Empty State
            if (turfs.isEmpty && snapshot.connectionState==ConnectionState.done) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Let’s get started",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    const Text("Add your first turf now!",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Button(
                      text: "Add your first turf",
                      onClick: _navigateToAddTurf,
                    ),
                  ],
                ),
              );
            }

            // ✅ List of Turfs
            return ListView.separated(
              itemCount: turfs.length,
              separatorBuilder: (context, index)=>SizedBox(height: 16,),
              itemBuilder: (context, index){
                return GestureDetector(
                  onTap: ()=> _navigateToTurfDetails(turfs[index]),
                  child: TurfCard(turf: turfs[index]),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FutureBuilder<List<Turf>>(
        future: futureTurfs,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return FloatingActionButton.extended(
              elevation: 0,
              backgroundColor: BMTTheme.brand,
              onPressed: _navigateToAddTurf,
              label: const Text("Add new turf"),
            );
          }
          return const SizedBox.shrink(); // no FAB in empty state
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
