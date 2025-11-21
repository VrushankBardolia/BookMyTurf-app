import 'dart:convert';

import 'turfowner.dart';

int parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  return int.tryParse(value.toString()) ?? defaultValue;
}

class Turf {
  final int id;
  final String name;
  final String slug;
  final String image;
  final String area;
  final String fullAddress;
  final int length;
  final int width;
  final String? mapLink;
  final String openingTime;
  final String closingTime;
  final int pricePerHour;
  final String upi;
  final int phone;
  final List<String> amenities;
  final String createdAt;
  final String updatedAt;
  final TurfOwner? owner;

  Turf({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.area,
    required this.fullAddress,
    required this.length,
    required this.width,
    this.mapLink,
    required this.openingTime,
    required this.closingTime,
    required this.pricePerHour,
    required this.upi,
    required this.phone,
    required this.amenities,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
  });

  factory Turf.fromJson(Map<String, dynamic> json) {
    List<String> parseAmenities(dynamic value) {
      if (value == null) return [];

      // If API returns JSON string → decode it
      if (value is String) {
        try {
          return List<String>.from(jsonDecode(value));
        } catch (_) {
          return [];
        }
      }

      // If already a list → convert
      if (value is List) {
        return List<String>.from(value.map((e) => e.toString()));
      }

      return [];
    }

    return Turf(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      area: json['area'] ?? '',
      fullAddress: json['full_address'] ?? '',
      length: parseInt(json['length']),
      width: parseInt(json['width']),
      mapLink: json['google_map_link']?.toString(), // FIXED
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      pricePerHour: parseInt(json['price_per_hour']),
      upi: json['upi']?.toString() ?? '',
      phone: parseInt(json['phone']),
      amenities: parseAmenities(json['amenities']),   // FIXED
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      owner: json['owner'] != null
          ? TurfOwner.fromJson(json['owner'])
          : null,
    );
  }

}
