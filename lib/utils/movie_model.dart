// lib/models/movie_model.dart
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
      releaseDate: DateTime.parse(json['releaseDate'] ?? DateTime.now().toString()),
      status: json['status'] ?? 'now_showing',
      genres: List<String>.from(json['genres'] ?? []),
      director: json['director'] ?? '',
      cast: List<String>.from(json['cast'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'rating': rating,
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'releaseDate': releaseDate.toIso8601String(),
      'status': status,
      'genres': genres,
      'director': director,
      'cast': cast,
    };
  }
}