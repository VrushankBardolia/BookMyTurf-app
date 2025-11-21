import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/components/buttons.dart';

import '/screens/turfowner/edit_turf.dart';
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
    _loadTurfs();
  }

  Future<void> _navigateToTurfEdit(Turf turf) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTurf(turf: turf,)),
    );
    _loadTurfs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
        child: FutureBuilder<List<Turf>>(
          future: futureTurfs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || futureTurfs == null) {
              return Center(child: CircularProgressIndicator(color: BMTTheme.brand));
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

            // -----------------------------------------------------------------
            // ✅ Empty State (Highly Enhanced)
            // -----------------------------------------------------------------
            if (turfs.isEmpty && snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_soccer_outlined, size: 80, color: BMTTheme.brand.withValues(alpha: 0.7)),
                      const SizedBox(height: 24),
                      const Text("No Turfs Listed Yet!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("It looks like you haven't added any properties. Start managing your bookings by listing your first turf.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: BMTTheme.white50),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 250, // Constrain button width
                        child: Button(
                          text: "Add Your First Turf",
                          onClick: _navigateToAddTurf,
                          backColor: BMTTheme.brand,
                          textColor: BMTTheme.black, // Dark text on brand background
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ List of Turfs
            return ListView.separated(
              itemCount: turfs.length,
              padding: const EdgeInsets.only(bottom: 100),
              separatorBuilder: (context, index)=>SizedBox(height: 16,),
              itemBuilder: (context, index){
                return GestureDetector(
                  onTap: ()=> _navigateToTurfEdit(turfs[index]),
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
