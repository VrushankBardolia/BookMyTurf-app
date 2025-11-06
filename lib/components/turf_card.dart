import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../util/api.dart';
import '../util/colors.dart';
import '../model/turf.dart';

// class TurfCard extends StatelessWidget {
//   final Turf turf;
//   const TurfCard({super.key, required this.turf});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: BMTTheme.black,
//         borderRadius: BorderRadius.all(Radius.circular(12)),
//       ),
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadiusGeometry.only(
//               topLeft: Radius.circular(12), topRight: Radius.circular(12),
//             ),
//             child:
//             // Image.network(
//             //   "$API/turfImages/${turf.image}",
//             //   height: 200,
//             //   width: MediaQuery.of(context).size.width,
//             //   fit: BoxFit.cover,
//             // ),
//             CachedNetworkImage(imageUrl: "$API/turfImages/${turf.image}",
//               height: 200,
//               width: MediaQuery.of(context).size.width,
//               fit: BoxFit.cover,
//               errorWidget: (context, url, error) => Center(child: Text(error.toString())),
//             ),
//           ),
//           ListTile(
//             title: Text(turf.name,
//               style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
//             ),
//             subtitle: Text(turf.area,
//               style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
//             ),
//             trailing: Text("₹${turf.pricePerHour}/Hr",
//               style: TextStyle(fontSize: 16),
//             ),
//             dense: true,
//             contentPadding: EdgeInsets.symmetric(horizontal: 12),
//             visualDensity: VisualDensity(horizontal: 0, vertical: -4),
//           ),
//         ],
//       ),
//     );
//   }
// }

class TurfCard extends StatelessWidget {
  final Turf turf;
  const TurfCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BMTTheme.white.withValues(alpha: 0.4)
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Turf Image
            CachedNetworkImage(
              imageUrl: "$API/turfImages/${turf.image}",
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              ),
            ),

            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0),
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Turf details
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name and area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(turf.name,
                          style: TextStyle(
                            color: BMTTheme.brand,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(turf.area,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: BMTTheme.brand,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("₹${turf.pricePerHour}/hr",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}