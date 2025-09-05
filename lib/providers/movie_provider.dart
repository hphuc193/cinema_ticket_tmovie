import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../services/movie_service.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> _movies = [];
  bool _isLoading = false;
  String _error = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MovieService _movieService = MovieService();

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<Movie> get featuredMovies =>
      _movies.where((movie) => movie.rating >= 8.0).toList();

  List<Movie> getMoviesByStatus(String status) {
    return _movies.where((movie) => movie.status == status).toList();
  }

  // Thêm method để lấy tất cả trạng thái có thể có
  static List<String> get allStatuses => [
    'now_showing',    // Đang chiếu
    'coming_soon',    // Sắp chiếu
    'ended',          // Đã chiếu
  ];

  // Method để lấy tên hiển thị của trạng thái
  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'now_showing':
        return 'Đang chiếu';
      case 'coming_soon':
        return 'Sắp chiếu';
      case 'ended':
        return 'Đã chiếu';
      default:
        return 'Không xác định';
    }
  }

  Future<void> fetchMovies() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _movies = await _movieService.getMovies();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Movie?> getMovieById(String id) async {
    try {
      return await _movieService.getMovieById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      return await _movieService.searchMovies(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// ✅ Method để thêm phim mới
  Future<Movie?> addMovie(Movie movie) async {
    try {
      // Tạo movie mới với ID rỗng và thời gian tạo
      final newMovie = movie.copyWith(
        id: '',
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('movies').add(newMovie.toJson());

      final addedMovie = newMovie.copyWith(id: docRef.id);

      _movies.add(addedMovie);
      notifyListeners();
      return addedMovie;
    } catch (e) {
      print('Lỗi khi thêm phim: $e');
      _error = 'Lỗi khi thêm phim: $e';
      notifyListeners();
      return null;
    }
  }

  /// ✅ Method để cập nhật phim hiện có
  Future<bool> updateMovie(Movie movie) async {
    try {
      // Đảm bảo movie có ID hợp lệ
      if (movie.id.isEmpty) {
        throw Exception('ID phim không hợp lệ');
      }

      await _movieService.updateMovie(movie);

      // Cập nhật movie trong danh sách local
      final index = _movies.indexWhere((m) => m.id == movie.id);
      if (index != -1) {
        _movies[index] = movie;
        notifyListeners();
      } else {
        // Nếu không tìm thấy trong local, fetch lại từ server
        await fetchMovies();
      }

      return true;
    } catch (e) {
      print('Lỗi khi cập nhật phim: $e');
      _error = 'Lỗi khi cập nhật phim: $e';
      notifyListeners();
      return false;
    }
  }

  /// ✅ Method để thêm hoặc cập nhật phim (dùng khi không chắc chắn)
  Future<Movie?> saveMovie(Movie movie) async {
    if (movie.id.isEmpty) {
      // Phim mới - thêm mới
      return await addMovie(movie);
    } else {
      // Phim đã có - cập nhật
      final success = await updateMovie(movie);
      return success ? movie : null;
    }
  }

  Future<bool> deleteMovie(String id) async {
    try {
      await _movieService.deleteMovie(id);

      // Xóa khỏi danh sách local
      _movies.removeWhere((movie) => movie.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      print('Lỗi khi xóa phim: $e');
      _error = 'Lỗi khi xóa phim: $e';
      notifyListeners();
      return false;
    }
  }
}