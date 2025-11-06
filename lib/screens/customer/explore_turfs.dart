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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
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
          return ListView.separated(
            itemCount: turfs.length,
            separatorBuilder: (context, index)=>SizedBox(height: 16,),
            itemBuilder: (context, index){
              return GestureDetector(
                onTap: ()=> Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TurfDetails(turf: turfs[index])),
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
