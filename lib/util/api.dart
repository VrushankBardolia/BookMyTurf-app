import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/turf.dart';

final API = "http://10.138.64.58/bmt-api";

// CUSTOMER LOGIN
Future<Map<String, dynamic>> customerLogin(
  String email,
  String password,
) async {
  final url = Uri.parse("$API/auth/customer_login.php");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {
      'status': 'error',
      'message': 'Server error: ${response.statusCode}',
    };
  }
}

// CUSTOMER SIGNUP
Future<Map<String, dynamic>> customerSignup(
  String fullname,
  String email,
  String phone,
  String password,
) async {
  final url = Uri.parse("$API/auth/customer_signup.php");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {
      'status': 'error',
      'message': 'Server error: ${response.statusCode}',
    };
  }
}

// TURFOWNER LOGIN
Future<Map<String, dynamic>> turfownerLogin(
  String email,
  String password,
) async {
  final url = Uri.parse("$API/auth/turfowner_login.php");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {
      'status': 'error',
      'message': 'Server error: ${response.statusCode}',
    };
  }
}

// CUSTOMER SIGNUP
Future<Map<String, dynamic>> turfownerSignup(
  String name,
  String email,
  String phone,
  String password,
) async {
  final url = Uri.parse("$API/auth/turfowner_signup.php");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {
      'status': 'error',
      'message': 'Server error: ${response.statusCode}',
    };
  }
}

// EXPLORE TURFS
Future<List<Turf>> exploreTurfs() async {
  print("API calling start");
  final url = Uri.parse("$API/turfs/explore_turfs.php");
  final response = await http.get(url);
  print(response.body);
  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    print(body);
    if (body['status'] == 'success' && body['data'] != null) {
      return (body['data'] as List).map((t) => Turf.fromJson(t)).toList();
    } else {
      return [];
    }
  } else {
    throw Exception('Failed to load turfs');
  }
}

// MY TURFS
Future<List<Turf>> getMyTurfs(int id) async {
  print("API calling start");
  final url = Uri.parse("$API/turfs/my_turfs.php?id=$id");
  final response = await http.get(url);
  print(response.body);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    print(body);

    final status = body['status'];

    if (status == 'success') {
      final data = body['data'];
      if (data is List) {
        return data.map((t) => Turf.fromJson(t)).toList();
      } else {
        return [];
      }
    } else if (status == 'empty') {
      // When no turfs found
      print("No turfs found for this owner.");
      return [];
    } else {
      // Unexpected response
      print("Unexpected status: $status");
      return [];
    }
  } else {
    throw Exception('Failed to load turfs');
  }
}

// ADD TURF
Future<Map<String, dynamic>> addTurf({
  required int turfOwnerId,
  required String name,
  File? imageFile,
  required String area,
  required String fullAddress,
  required int length,
  required int width,
  required String googleMapLink,
  required String openingTime,
  required String closingTime,
  required int pricePerHour,
  required String upi,
  required String phone,
  required List<String> amenities,
}) async {
  final url = Uri.parse("$API/turfs/add_turf.php");

  try {
    var request = http.MultipartRequest('POST', url);

    // Add text fields
    request.fields['turf_owner_id'] = turfOwnerId.toString();
    request.fields['name'] = name;
    request.fields['area'] = area;
    request.fields['full_address'] = fullAddress;
    request.fields['length'] = length.toString();
    request.fields['width'] = width.toString();
    request.fields['google_map_link'] = googleMapLink;
    request.fields['opening_time'] = openingTime;
    request.fields['closing_time'] = closingTime;
    request.fields['price_per_hour'] = pricePerHour.toString();
    request.fields['upi'] = upi;
    request.fields['phone'] = phone;
    request.fields['amenities'] = jsonEncode(amenities);

    // Attach image if provided
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    // Debug: print what we’re sending
    print("=== Sending Turf Data ===");
    request.fields.forEach((key, value) {
      print("$key: $value");
    });
    if (imageFile != null) {
      print("Image path: ${imageFile.path}");
    } else {
      print("No image selected.");
    }
    print("=========================");

    // Send request
    var streamedResponse = await request.send();

    // Debug: raw server response
    print("Status Code: ${streamedResponse.statusCode}");
    var responseBody = await streamedResponse.stream.bytesToString();
    print("Raw Response: $responseBody");

    // Decode JSON safely
    try {
      var jsonResponse = jsonDecode(responseBody);
      return jsonResponse;
    } catch (e) {
      print("JSON Decode Error: $e");
      return {'status': 'error', 'message': 'Invalid JSON from server'};
    }
  } catch (e) {
    print("Request Error: $e");
    return {'status': 'error', 'message': e.toString()};
  }
}

// GET TURF BY ID
Future<Turf> getTurfById(int id) async {
  final url = Uri.parse("$API/turfs/get_turf_details.php?id=$id");
  final response = await http.get(url);
  print(response.body);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    if (body['status'] == 'success') {
      return Turf.fromJson(body['data']);
    } else {
      throw Exception(body['message']);
    }
  } else {
    throw Exception("Failed to find turf");
  }
}

Future<List<Map<String, dynamic>>> fetchSlots(int turfId, String selectedDate) async {
  final formattedDate = DateFormat('yyyy-MM-dd').format(
    DateFormat('d/M/yyyy').parse(selectedDate),
  );

  final response = await http.get(
    Uri.parse('$API/turfs/get_slots.php?turf_id=$turfId&date=$formattedDate'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return List<Map<String, dynamic>>.from(data['slots']);
    } else {
      throw Exception('No slots found');
    }
  } else {
    throw Exception('Failed to fetch slots');
  }
}

Future<Map<String, dynamic>> bookSlot({
  required int turfId,
  required String email,
  required String date,
  required String startTime,
  required String endTime,
  required int duration,
  required int totalAmount,
  required int advanceAmount,
}) async {
  final url = Uri.parse("$API/customer/booking.php");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "turf_id": turfId,
      "email": email,
      "date": date,
      "start_time": startTime,
      "end_time": endTime,
      "duration": duration,
      "total_amount": totalAmount,
      "advance_amount": advanceAmount,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to book slot");
  }
}

// FETCH BOOKINGS (CUSTOMER SIDE)
Future<List<Map<String, dynamic>>> fetchCustomerBookings(String email) async {
  final url = Uri.parse('$API/customer/get_bookings.php?email=$email');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final body = response.body.trim();

    if (!body.startsWith('{') && !body.startsWith('[')) {
      throw Exception("Invalid JSON response: $body");
    }

    final data = jsonDecode(body);

    if (data['status'] == 'success') {
      return List<Map<String, dynamic>>.from(data['bookings']);
    } else {
      return [];
    }
  } else {
    throw Exception("Failed to fetch bookings: ${response.statusCode}");
  }
}

// FETCH BOOKINGS (TURFOWNER SIDE)
Future<List<Map<String, dynamic>>> fetchTurfBookings(String email) async {
  final url = Uri.parse('$API/turfs/get_bookings.php?email=$email');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final body = response.body.trim();

    if (!body.startsWith('{') && !body.startsWith('[')) {
      throw Exception("Invalid JSON response: $body");
    }

    final data = jsonDecode(body);

    if (data['status'] == 'success') {
      return List<Map<String, dynamic>>.from(data['bookings']);
    } else {
      return [];
    }
  } else {
    throw Exception("Failed to fetch bookings: ${response.statusCode}");
  }
}