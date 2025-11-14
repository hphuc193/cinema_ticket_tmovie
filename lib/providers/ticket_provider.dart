import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ticket_model.dart';
import '../models/movie_model.dart';
import '../models/cinema_model.dart';

class TicketProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _error;

  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchUserTickets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _error = 'Vui lòng đăng nhập để xem vé';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .get();

      _tickets = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic>? data;
        try {
          data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          String movieId = data['movieId']?.toString() ?? '';
          String cinemaId = data['cinemaId']?.toString() ?? '';
          String showtimeId = data['showtimeId']?.toString() ?? '';

          Movie? movie;
          if (movieId.isNotEmpty) {
            final movieDoc = await _firestore.collection('movies').doc(movieId).get();
            if (movieDoc.exists) {
              final movieData = movieDoc.data()!;
              movieData['id'] = movieDoc.id;
              movie = Movie.fromJson(movieData);
            }
          }

          Cinema? cinema;
          Timestamp? showtimeTime;

          if (showtimeId.isNotEmpty) {
            final showtimeDoc = await _firestore.collection('showtimes').doc(showtimeId).get();
            if (showtimeDoc.exists) {
              final showtimeData = showtimeDoc.data()!;
              showtimeTime = showtimeData['startTime'];
              if (cinemaId.isEmpty && showtimeData['cinemaId'] != null) {
                cinemaId = showtimeData['cinemaId'].toString();
              }
            }
          }

          if (cinemaId.isNotEmpty) {
            final cinemaDoc = await _firestore.collection('cinemas').doc(cinemaId).get();
            if (cinemaDoc.exists) {
              final cinemaData = cinemaDoc.data()!;
              cinemaData['id'] = cinemaDoc.id;
              cinema = Cinema.fromJson(cinemaData);
            }
          }

          final ticket = Ticket.fromJson({
            ...data,
            'movie': movie?.toJson(),
            'cinema': cinema?.toJson(),
            'showtimeTime': showtimeTime,
            // THÊM CÁC DÒNG NÀY để preserve data từ ticket document:
            'movieTitle': data['movieTitle'], 
            'cinemaName': data['cinemaName'], 
            'showDate': data['showDate'],   
            'showTime': data['showTime'],    
          });

          _tickets.add(ticket);
        } catch (e) {
          if (data != null) {
            try {
              final ticket = Ticket.fromJson(data);
              _tickets.add(ticket);
            } catch (_) {}
          }
        }
      }

      _tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tải danh sách vé: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật lại logic lọc vé theo trạng thái
  List<Ticket> getTicketsByStatus(String status) {
    switch (status) {
      case 'upcoming':
      // Tab "Chưa Thanh Toán" - chỉ hiển thị vé có trạng thái pending
        return _tickets.where((ticket) {
          return ticket.paymentStatus == 'pending';
        }).toList();
      case 'used':
      // Tab "Đã Thanh Toán" - chỉ hiển thị vé có trạng thái completed
        return _tickets.where((ticket) {
          return ticket.paymentStatus == 'completed';
        }).toList();
      case 'cancelled':
      // Tab "Đã Hủy" - chỉ hiển thị vé có trạng thái cancelled
        return _tickets.where((ticket) => ticket.paymentStatus == 'cancelled').toList();
      default:
        return _tickets;
    }
  }

  Future<bool> cancelTicket(String ticketId) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'paymentStatus': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        final t = _tickets[index];
        _tickets[index] = Ticket(
          id: t.id,
          userId: t.userId,
          showtimeId: t.showtimeId,
          seats: t.seats,
          totalPrice: t.totalPrice,
          paymentStatus: 'cancelled',
          paymentMethod: t.paymentMethod,
          createdAt: t.createdAt,
          movie: t.movie,
          cinema: t.cinema,
          showtimeTime: t.showtimeTime,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Lỗi khi hủy vé: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshTickets() async {
    await fetchUserTickets();
  }

  Future<void> testFirestoreConnection() async {
    try {
      final user = _auth.currentUser;
      final allTickets = await _firestore.collection('tickets').get();
      print('Total tickets: ${allTickets.docs.length}');

      if (user != null) {
        final userTickets = await _firestore
            .collection('tickets')
            .where('userId', isEqualTo: user.uid)
            .get();

        print('User tickets: ${userTickets.docs.length}');
        for (var doc in userTickets.docs) {
          print('Ticket ${doc.id}: ${doc.data()}');
        }
      }
    } catch (e) {
      print('Test error: $e');
    }
  }

}
