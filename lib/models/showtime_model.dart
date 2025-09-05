// lib/models/showtime_model.dart - Fixed version with correct seat format
import 'package:cloud_firestore/cloud_firestore.dart';

class Showtime {
  final String id;
  final String movieId;
  final String cinemaId;
  final String roomId;
  final DateTime startTime;
  final List<String> availableSeats;
  final List<String> bookedSeats;
  final double price;

  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaId,
    required this.roomId,
    required this.startTime,
    required this.availableSeats,
    required this.bookedSeats,
    required this.price,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    // Parse seat lists với error handling
    List<String> parsedAvailableSeats = [];
    List<String> parsedBookedSeats = [];

    try {
      if (json['availableSeats'] != null) {
        parsedAvailableSeats = List<String>.from(json['availableSeats']);
      }
    } catch (e) {
      print('Error parsing availableSeats: $e');
    }

    try {
      if (json['bookedSeats'] != null) {
        parsedBookedSeats = List<String>.from(json['bookedSeats']);
      }
    } catch (e) {
      print('Error parsing bookedSeats: $e');
    }

    // Nếu availableSeats rỗng, tạo layout mặc định
    if (parsedAvailableSeats.isEmpty && parsedBookedSeats.isEmpty) {
      parsedAvailableSeats = _generateDefaultSeatLayout();
      print('Generated default seat layout: ${parsedAvailableSeats.length} seats');
    }

    return Showtime(
      id: json['id'] ?? '',
      movieId: json['movieId'] ?? '',
      cinemaId: json['cinemaId'] ?? '',
      roomId: json['roomId'] ?? '',
      startTime: _parseDateTime(json['startTime']),
      availableSeats: parsedAvailableSeats,
      bookedSeats: parsedBookedSeats,
      price: _parseDouble(json['price']),
    );
  }

  // Helper method để parse DateTime từ Firestore
  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return DateTime.now();
    }
  }

  // Helper method để parse double
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // FIXED: Seat availability logic with format matching
  bool isSeatAvailable(String seatId) {
    // Normalize seat format - remove leading zeros for comparison
    String normalizedSeatId = _normalizeSeatId(seatId);

    // Nếu ghế đã được book, không available
    if (bookedSeats.any((seat) => _normalizeSeatId(seat) == normalizedSeatId)) {
      return false;
    }

    // Nếu không có dữ liệu availableSeats (rỗng), coi tất cả ghế chưa book là available
    if (availableSeats.isEmpty) {
      return true;
    }

    // Nếu có dữ liệu availableSeats, check xem ghế có trong danh sách không
    return availableSeats.any((seat) => _normalizeSeatId(seat) == normalizedSeatId);
  }

  // FIXED: Booked check with format matching
  bool isSeatBooked(String seatId) {
    String normalizedSeatId = _normalizeSeatId(seatId);
    return bookedSeats.any((seat) => _normalizeSeatId(seat) == normalizedSeatId);
  }

  // Helper method to normalize seat ID format
  // Converts both "A01" and "A1" to "A1" for consistent comparison
  String _normalizeSeatId(String seatId) {
    if (seatId.length < 2) return seatId;

    String row = seatId.substring(0, 1);
    String number = seatId.substring(1);

    // Remove leading zeros from number part
    int seatNumber = int.tryParse(number) ?? 0;

    return '$row$seatNumber';
  }

  // FIXED: Get all selectable seats with format matching
  List<String> getAllSelectableSeats() {
    // Nếu availableSeats rỗng, tạo default layout và loại bỏ booked seats
    if (availableSeats.isEmpty) {
      final defaultSeats = _generateDefaultSeatLayout();
      return defaultSeats.where((seat) => !isSeatBooked(seat)).toList();
    }

    // Nếu có availableSeats, trả về những ghế available và chưa được book
    return availableSeats.where((seat) => !isSeatBooked(seat)).toList();
  }

  // FIXED: Generate default seat layout to match Firestore format (A1, A2, etc.)
  static List<String> _generateDefaultSeatLayout() {
    List<String> seats = [];
    const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    for (String row in rows) {
      for (int i = 1; i <= 12; i++) {
        // FIXED: Use format without leading zeros to match Firestore
        String seatId = '$row$i';
        seats.add(seatId);
      }
    }
    return seats;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'cinemaId': cinemaId,
      'roomId': roomId,
      'startTime': Timestamp.fromDate(startTime),
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'price': price,
    };
  }

  // Copy method để tạo bản sao với dữ liệu mới
  Showtime copyWith({
    String? id,
    String? movieId,
    String? cinemaId,
    String? roomId,
    DateTime? startTime,
    List<String>? availableSeats,
    List<String>? bookedSeats,
    double? price,
  }) {
    return Showtime(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      cinemaId: cinemaId ?? this.cinemaId,
      roomId: roomId ?? this.roomId,
      startTime: startTime ?? this.startTime,
      availableSeats: availableSeats ?? this.availableSeats,
      bookedSeats: bookedSeats ?? this.bookedSeats,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return 'Showtime(id: $id, movieId: $movieId, cinemaId: $cinemaId, roomId: $roomId, '
        'availableSeats: ${availableSeats.length}, bookedSeats: ${bookedSeats.length}, price: $price)';
  }
}