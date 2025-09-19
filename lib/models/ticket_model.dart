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
  final dynamic showtimeTime;

  // THÊM CÁC FIELDS MỚI:
  final String? movieTitle;
  final String? cinemaName;
  final String? showDate;
  final String? showTime;
  final String? cinemaId;

  const Ticket({
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
    // THÊM VÀO CONSTRUCTOR:
    this.movieTitle,
    this.cinemaName,
    this.showDate,
    this.showTime,
    this.cinemaId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      showtimeId: json['showtimeId'] ?? '',
      seats: List<String>.from(json['seats'] ?? []),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      createdAt: _parseDateTime(json['createdAt']),
      movie: json['movie'] != null ? Movie.fromJson(json['movie']) : null,
      cinema: json['cinema'] != null ? Cinema.fromJson(json['cinema']) : null,
      showtimeTime: json['showtimeTime'],
      // THÊM VÀO fromJson:
      movieTitle: json['movieTitle']?.toString(),
      cinemaName: json['cinemaName']?.toString(),
      showDate: json['showDate']?.toString(),
      showTime: json['showTime']?.toString(),
      cinemaId: json['cinemaId']?.toString(),
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
      'createdAt': createdAt.toIso8601String(),
      'movie': movie?.toJson(),
      'cinema': cinema?.toJson(),
      'showtimeTime': showtimeTime,
      // THÊM VÀO toJson:
      'movieTitle': movieTitle,
      'cinemaName': cinemaName,
      'showDate': showDate,
      'showTime': showTime,
      'cinemaId': cinemaId,
    };
  }

  // Helper method để parse DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}