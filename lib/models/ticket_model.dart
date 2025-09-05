// lib/models/ticket_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';
import '../models/cinema_model.dart';

class Ticket {
  final String id;
  final String userId;
  final String showtimeId;
  final List<String> seats;
  final double totalPrice;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime createdAt;
  final Movie? movie;
  final Cinema? cinema;
  final DateTime? showtimeTime;

  Ticket({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.seats,
    required this.totalPrice,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
    this.movie,
    this.cinema,
    this.showtimeTime,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;

    try {
      if (json['createdAt'] is Timestamp) {
        createdAt = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String && json['createdAt'].toString().isNotEmpty) {
        createdAt = DateTime.parse(json['createdAt']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      print('Lỗi parse createdAt: $e');
      createdAt = DateTime.now();
    }

    return Ticket(
      id: json['id'],
      userId: json['userId'],
      showtimeId: json['showtimeId'],
      seats: List<String>.from(json['seats'] ?? []),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      createdAt: createdAt, // <-- Sử dụng createdAt ở trên
      movie: json['movie'] != null ? Movie.fromJson(json['movie']) : null,
      cinema: json['cinema'] != null ? Cinema.fromJson(json['cinema']) : null,
      showtimeTime: (json['showtimeTime'] is Timestamp)
          ? (json['showtimeTime'] as Timestamp).toDate()
          : DateTime.tryParse(json['showtimeTime'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'showtimeId': showtimeId,
      'seats': seats,
      'totalPrice': totalPrice,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt), // Sử dụng Timestamp
      'movie': movie?.toJson(),
      'cinema': cinema?.toJson(),
      'showtimeTime': showtimeTime?.toIso8601String(),
    };
  }
}