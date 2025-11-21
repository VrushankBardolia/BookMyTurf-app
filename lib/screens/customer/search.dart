import 'package:flutter/material.dart';

import '../../components/turf_card.dart';
import '../../model/turf.dart';
import '../../util/api.dart';
import '../../util/colors.dart';
import '../turf_details.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController searchCtrl = TextEditingController();
  List<Turf> results = [];
  bool isSearching = false;
  bool showEmpty = false;

  Future<void> onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        results = [];
        showEmpty = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      showEmpty = false; // reset message while searching
    });

    try {
      final list = await searchTurfs(query);

      setState(() {
        results = list.map<Turf>((json) => Turf.fromJson(json)).toList();
        showEmpty = results.isEmpty; // 👈 show msg only after search AND no results
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        results = [];
        isSearching = false;
        showEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              onChanged: (value) => onSearch(value),
              onTapOutside: (e)=>FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16,),
                filled: true,
                fillColor: BMTTheme.black,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: BMTTheme.brand),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                hintText: "Search by name",
                hintStyle: TextStyle(color: BMTTheme.white50),
              ),
            ),

            const SizedBox(height: 16),

            // 🌀 LOADING INDICATOR
            if (isSearching) Center(child: CircularProgressIndicator()),

            // 📋 RESULTS LIST
            Expanded(
              child: showEmpty
                  ? Center(
                child: Text("No turfs found",
                  style: TextStyle(fontSize: 16, color: BMTTheme.white50),
                ),
              )
                  : ListView.separated(
                itemCount: results.length,
                separatorBuilder: (context, index)=>SizedBox(height: 16,),
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: ()=> Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TurfDetails(turf: results[i])),
                    ),
                    child: TurfCard(turf: results[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
