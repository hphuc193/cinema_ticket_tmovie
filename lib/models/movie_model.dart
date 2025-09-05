// lib/models/movie_model.dart - Fixed version
import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final int duration;
  final double rating;
  final String posterUrl;
  final String trailerUrl;
  final DateTime releaseDate;
  final String status;
  final List<String> genres;
  final String director;
  final List<String> cast;
  final DateTime? createdAt;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.rating,
    required this.posterUrl,
    required this.trailerUrl,
    required this.releaseDate,
    required this.status,
    required this.genres,
    required this.director,
    required this.cast,
    this.createdAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      posterUrl: json['posterUrl'] ?? '',
      trailerUrl: json['trailerUrl'] ?? '',
      releaseDate: _parseDateTime(json['releaseDate']), // Đã sửa
      status: json['status'] ?? 'now_showing', // Đã sửa
      genres: List<String>.from(json['genres'] ?? []),
      director: json['director'] ?? '',
      cast: List<String>.from(json['cast'] ?? []),
      createdAt: json['createdAt'] != null ? _parseDateTime(json['createdAt']) : null, // Đã sửa
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'rating': rating,
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'status': status,
      'genres': genres,
      'director': director,
      'cast': cast,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
    };
  }

  static DateTime _parseDateTime(dynamic dateTime) { // Đã sửa tên method
    if (dateTime is Timestamp) {
      return dateTime.toDate();
    } else if (dateTime is String) {
      return DateTime.parse(dateTime);
    } else {
      return DateTime.now();
    }
  }

  Movie copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
    double? rating,
    String? posterUrl,
    String? trailerUrl,
    DateTime? releaseDate,
    String? status,
    List<String>? genres,
    String? director,
    List<String>? cast,
    DateTime? createdAt,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      posterUrl: posterUrl ?? this.posterUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      status: status ?? this.status,
      genres: genres ?? this.genres,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}