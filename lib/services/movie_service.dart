// lib/services/movie_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Movie>> getMovies() async {
    try {
      final snapshot = await _firestore.collection('movies').get();
      return snapshot.docs.map((doc) => Movie.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách phim: ${e.toString()}');
    }
  }

  Future<Movie?> getMovieById(String id) async {
    try {
      final doc = await _firestore.collection('movies').doc(id).get();
      if (doc.exists) {
        return Movie.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin phim: ${e.toString()}');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get();

      return snapshot.docs.map((doc) => Movie.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm phim: ${e.toString()}');
    }
  }

  Future<void> addMovie(Movie movie) async {
    try {
      await _firestore.collection('movies').add(movie.toJson());
    } catch (e) {
      throw Exception('Lỗi khi thêm phim: ${e.toString()}');
    }
  }

  Future<void> updateMovie(Movie movie) async {
    try {
      await _firestore.collection('movies').doc(movie.id).update(movie.toJson());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật phim: ${e.toString()}');
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      await _firestore.collection('movies').doc(id).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa phim: ${e.toString()}');
    }
  }
}