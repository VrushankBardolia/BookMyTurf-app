import 'package:flutter/material.dart';

import '../../components/turf_card.dart';
import '../../util/api.dart';
import '../../model/turf.dart';
import '../turf_details.dart';

class ExploreTurfs extends StatefulWidget {
  const ExploreTurfs({super.key});

  @override
  State<ExploreTurfs> createState() => _ExploreTurfsState();
}

class _ExploreTurfsState extends State<ExploreTurfs> {
  late Future<List<Turf>> futureTurfs;

  @override
  void initState() {
    super.initState();
    futureTurfs = exploreTurfs();
  }

  Future<void> _navigateToTurfDetails(int tid) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TurfDetails(id: tid,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: FutureBuilder<List<Turf>>(
        future: futureTurfs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LinearProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Turfs Found"));
          }

          final turfs = snapshot.data!;
          return ListView.builder(
            itemCount: turfs.length,
            itemBuilder: (context, index){
              return GestureDetector(
                onTap: ()=> Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TurfDetails(id: turfs[index].id,)),
                ),
                child: TurfCard(turf: turfs[index]),
              );
            },
          );
        },
      ),
    );
  }
}
