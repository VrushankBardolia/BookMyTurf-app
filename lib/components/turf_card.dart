import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../util/api.dart';
import '../util/colors.dart';
import '../model/turf.dart';

class TurfCard extends StatelessWidget {
  final Turf turf;
  const TurfCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: BMTTheme.black,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12),
            ),
            child: CachedNetworkImage(imageUrl: "$API/turfImages/${turf.image}",
              height: 200,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Center(child: Text(error.toString())),
            ),
          ),
          ListTile(
            title: Text(turf.name,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            subtitle: Text(turf.area,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
            trailing: Text("₹${turf.pricePerHour}/Hr",
              style: TextStyle(fontSize: 16),
            ),
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          ),
        ],
      ),
    );
  }
}
