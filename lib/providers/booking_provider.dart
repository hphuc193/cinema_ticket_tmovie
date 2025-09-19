// lib/providers/booking_provider.dart - Fixed version
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/showtime_model.dart';
import '../models/ticket_model.dart';
import '../models/cinema_model.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Showtime> _showtimes = [];
  List<Cinema> _cinemas = [];
  List<Ticket> _tickets = [];
  List<String> _selectedSeats = [];
  Showtime? _selectedShowtime;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Showtime> get showtimes => _showtimes;
  List<Cinema> get cinemas => _cinemas;
  List<Ticket> get tickets => _tickets;
  List<String> get selectedSeats => _selectedSeats;
  Showtime? get selectedShowtime => _selectedShowtime;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchShowtimes(String movieId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('showtimes')
          .where('movieId', isEqualTo: movieId)
          .where('startTime', isGreaterThan: Timestamp.now())
          .orderBy('startTime')
          .get();

      _showtimes = snapshot.docs.map((doc) {
        final data = doc.data();
        return Showtime.fromJson({...data, 'id': doc.id});
      }).toList();

    } catch (e) {
      print('Error fetching showtimes: $e');
      _errorMessage = 'Không thể tải suất chiếu. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Cinema>> getCinemasByMovie(String movieId) async {
    try {
      print('Loading cinemas for movieId: $movieId');

      // FIXED: Truy vấn movie_cinemas collection bằng movieId
      final movieCinemasDoc = await _firestore
          .collection('movie_cinemas')
          .doc(movieId) // Sử dụng movieId làm document ID
          .get();

      if (!movieCinemasDoc.exists) {
        print('No cinema data found for movie: $movieId');
        _cinemas = [];
        notifyListeners();
        return [];
      }

      final movieCinemasData = movieCinemasDoc.data();
      if (movieCinemasData == null || movieCinemasData['cinemas'] == null) {
        print('No cinemas field found in movie_cinemas document');
        _cinemas = [];
        notifyListeners();
        return [];
      }

      // Lấy danh sách cinema names từ field 'cinemas'
      final cinemaNames = List<String>.from(movieCinemasData['cinemas']);
      print('Found cinema names: $cinemaNames');

      if (cinemaNames.isEmpty) {
        print('Cinema names list is empty');
        _cinemas = [];
        notifyListeners();
        return [];
      }

      // Tạo danh sách Cinema objects
      final List<Cinema> cinemaList = [];

      for (int i = 0; i < cinemaNames.length; i++) {
        final cinemaName = cinemaNames[i];

        // Tạo cinema ID từ tên (hoặc sử dụng index)
        final cinemaId = cinemaName
            .toLowerCase()
            .replaceAll(' ', '_')
            .replaceAll(RegExp(r'[^a-z0-9_]'), '');

        final cinema = Cinema.fromJson({
          'id': cinemaId,
          'name': cinemaName,
          'location': 'Vị trí ${cinemaName}', // Có thể thêm location thực tế sau
          'rooms': _generateDefaultRooms(), // Tạo rooms mặc định
          'movieId': movieId,
        });

        cinemaList.add(cinema);
        print('Created cinema: ${cinema.name} with ID: ${cinema.id}');
      }

      print('Total cinemas loaded: ${cinemaList.length}');
      _cinemas = cinemaList;
      notifyListeners();

      return cinemaList;
    } catch (e) {
      print('Error fetching cinemas by movie: $e');
      _errorMessage = 'Không thể tải danh sách rạp: $e';
      _cinemas = [];
      notifyListeners();
      throw Exception('Không thể tải danh sách rạp cho phim này: $e');
    }
  }

  // Helper method để tạo rooms mặc định
  List<Map<String, dynamic>> _generateDefaultRooms() {
    return [
      {
        'roomId': 'room_1',
        'name': 'Phòng 1',
        'seatMap': [
          ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8'],
          ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8'],
          ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8'],
        ],
      },
      {
        'roomId': 'room_2',
        'name': 'Phòng 2',
        'seatMap': [
          ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8'],
          ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8'],
          ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8'],
        ],
      }
    ];
  }

  Future<List<Showtime>> getShowtimesByDateAndCinema(
      String movieId,
      DateTime date,
      String cinemaId,
      ) async {
    try {
      print('Loading showtimes for movie: $movieId, cinema: $cinemaId, date: $date');

      // Đầu tiên lấy tất cả showtimes của movie
      final snapshot = await _firestore
          .collection('showtimes')
          .where('movieId', isEqualTo: movieId)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No showtimes found for movie: $movieId');
        return [];
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final showtimes = <Showtime>[];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final showtime = Showtime.fromJson({...data, 'id': doc.id});

          // Filter theo ngày
          if (showtime.startTime.isAfter(startOfDay) &&
              showtime.startTime.isBefore(endOfDay)) {

            // FIXED: So sánh cinemaId
            // Nếu cinemaId từ Firestore là tên cinema, chuyển thành ID format
            String showtimeCinemaId = data['cinemaId']?.toString() ?? '';
            String normalizedShowtimeCinemaId = showtimeCinemaId
                .toLowerCase()
                .replaceAll(' ', '_')
                .replaceAll(RegExp(r'[^a-z0-9_]'), '');

            print('Comparing cinema IDs:');
            print('  Selected cinemaId: $cinemaId');
            print('  Showtime cinemaId: $showtimeCinemaId');
            print('  Normalized showtime cinemaId: $normalizedShowtimeCinemaId');

            // So sánh cả tên gốc và tên đã normalize
            if (showtimeCinemaId == cinemaId ||
                normalizedShowtimeCinemaId == cinemaId ||
                showtimeCinemaId.toLowerCase() == cinemaId.toLowerCase()) {
              showtimes.add(showtime);
              print('✓ Added showtime: ${showtime.id} at ${showtime.startTime}');
            }
          }
        } catch (e) {
          print('Error processing showtime document ${doc.id}: $e');
          continue;
        }
      }

      showtimes.sort((a, b) => a.startTime.compareTo(b.startTime));

      print('Found ${showtimes.length} showtimes for cinema $cinemaId on ${date.day}/${date.month}');
      return showtimes;

    } catch (e) {
      print('Error fetching showtimes: $e');
      throw Exception('Không thể tải suất chiếu: $e');
    }
  }

  Future<void> fetchUserTickets(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _tickets = snapshot.docs.map((doc) =>
          Ticket.fromJson({...doc.data(), 'id': doc.id})
      ).toList();

    } catch (e) {
      print('Error fetching user tickets: $e');
      _errorMessage = 'Không thể tải lịch sử vé. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectShowtime(Showtime showtime) {
    print('Selecting showtime: ${showtime.id}');
    _selectedShowtime = showtime;
    clearSelectedSeats();
    notifyListeners();
  }

  void selectSeat(String seatId) {
    if (_selectedSeats.contains(seatId)) {
      _selectedSeats.remove(seatId);
      print('Removed seat: $seatId');
    } else {
      _selectedSeats.add(seatId);
      print('Added seat: $seatId');
    }
    print('Currently selected seats: $_selectedSeats');
    notifyListeners();
  }

  void clearSelectedSeats() {
    _selectedSeats.clear();
    print('Cleared selected seats');
    notifyListeners();
  }

  bool isSeatAvailable(String seatId) {
    if (_selectedShowtime == null) return false;
    return _selectedShowtime!.isSeatAvailable(seatId);
  }

  bool isSeatBooked(String seatId) {
    if (_selectedShowtime == null) return false;
    return _selectedShowtime!.isSeatBooked(seatId);
  }

  List<String> getAllSelectableSeats() {
    if (_selectedShowtime == null) return [];
    return _selectedShowtime!.getAllSelectableSeats();
  }

  // FIXED: Simplified booking method with proper error handling
  Future<String?> bookTicket({
    required String userId,
    required String movieId,
    required String showtimeId,
    required List<String> seats,
    required double totalPrice,
    required String paymentMethod,
    // THÊM CÁC PARAMETERS MỚI:
    String? cinemaId,
    String? cinemaName,
    String? movieTitle,
  }) async {
    print('=== BOOKING PROCESS STARTED ===');
    print('User ID: $userId');
    print('Movie ID: $movieId');
    print('Showtime ID: $showtimeId');
    print('Cinema ID: $cinemaId');
    print('Cinema Name: $cinemaName');
    print('Movie Title: $movieTitle');
    print('Seats: $seats');
    print('Total Price: $totalPrice');
    print('Payment Method: $paymentMethod');

    try {
      // Clear any previous errors
      _errorMessage = null;
      notifyListeners();

      // Input validation
      if (!_validateBookingInput(userId, movieId, showtimeId, seats)) {
        print('Input validation failed');
        return null;
      }

      // Get fresh showtime data
      final currentShowtime = await _getLatestShowtimeData(showtimeId);
      if (currentShowtime == null) {
        _setError('Suất chiếu không tồn tại hoặc đã bị hủy');
        return null;
      }

      print('Current showtime data loaded successfully');

      // Verify seat availability
      if (!_validateSeatAvailability(seats, currentShowtime)) {
        return null;
      }

      // LẤY THÔNG TIN SHOWTIME ĐỂ TẠO showDate và showTime
      final startTime = currentShowtime.startTime;
      final showDate = '${startTime.day}/${startTime.month}/${startTime.year}';
      final showTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

      // Execute booking transaction and RETURN ticket ID
      final ticketId = await _executeBookingTransactionUpdated(
        userId: userId,
        movieId: movieId,
        showtimeId: showtimeId,
        seats: seats,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        currentShowtime: currentShowtime,
        // THÊM CÁC PARAMETERS MỚI:
        cinemaId: cinemaId,
        cinemaName: cinemaName,
        movieTitle: movieTitle,
        showDate: showDate,
        showTime: showTime,
      );

      if (ticketId != null) {
        print('=== BOOKING COMPLETED SUCCESSFULLY ===');
        print('Created ticket ID: $ticketId');
        // Clear selected seats after successful booking
        _selectedSeats.clear();
        notifyListeners();
        return ticketId;
      } else {
        print('=== BOOKING FAILED ===');
        return null;
      }

    } catch (e) {
      print('=== BOOKING ERROR ===');
      print('Error: $e');
      _setError('Có lỗi xảy ra trong quá trình đặt vé: ${e.toString()}');
      return null;
    }
  }

  bool _validateBookingInput(String userId, String movieId, String showtimeId, List<String> seats) {
    if (userId.isEmpty) {
      _setError('Thông tin người dùng không hợp lệ');
      return false;
    }

    if (movieId.isEmpty) {
      _setError('Thông tin phim không hợp lệ');
      return false;
    }

    if (showtimeId.isEmpty) {
      _setError('Thông tin suất chiếu không hợp lệ');
      return false;
    }

    if (seats.isEmpty) {
      _setError('Vui lòng chọn ít nhất một ghế');
      return false;
    }

    if (seats.length > 8) {
      _setError('Không thể đặt quá 8 ghế trong một lần');
      return false;
    }

    print('Input validation passed');
    return true;
  }

  Future<Showtime?> _getLatestShowtimeData(String showtimeId) async {
    try {
      print('Fetching latest showtime data for: $showtimeId');

      final doc = await _firestore.collection('showtimes').doc(showtimeId).get();

      if (!doc.exists) {
        print('Showtime document does not exist');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        print('Showtime document has no data');
        return null;
      }

      final showtime = Showtime.fromJson({...data, 'id': doc.id});
      print('Successfully loaded showtime: ${showtime.id}');

      return showtime;
    } catch (e) {
      print('Error fetching latest showtime data: $e');
      return null;
    }
  }

  bool _validateSeatAvailability(List<String> seats, Showtime showtime) {
    print('Validating seat availability...');

    for (String seat in seats) {
      if (!showtime.isSeatAvailable(seat)) {
        print('Seat $seat is not available');
        print('Available seats: ${showtime.availableSeats}');
        print('Booked seats: ${showtime.bookedSeats}');
        _setError('Ghế $seat đã được đặt bởi người khác. Vui lòng chọn ghế khác.');
        return false;
      }
    }

    print('All seats are available');
    return true;
  }

  Future<String?> _executeBookingTransactionUpdated({
    required String userId,
    required String movieId,
    required String showtimeId,
    required List<String> seats,
    required double totalPrice,
    required String paymentMethod,
    required Showtime currentShowtime,
    String? cinemaId,
    String? cinemaName,
    String? movieTitle,
    String? showDate,
    String? showTime,
  }) async {
    try {
      print('Starting Firestore transaction...');

      final result = await _firestore.runTransaction<String?>((transaction) async {
        print('Inside transaction - re-checking showtime...');

        final showtimeRef = _firestore.collection('showtimes').doc(showtimeId);
        final showtimeSnapshot = await transaction.get(showtimeRef);

        if (!showtimeSnapshot.exists) {
          throw Exception('Suất chiếu không tồn tại');
        }

        final transactionShowtime = Showtime.fromJson({
          ...showtimeSnapshot.data()!,
          'id': showtimeSnapshot.id
        });

        // Final seat availability check within transaction
        for (String seat in seats) {
          if (!transactionShowtime.isSeatAvailable(seat)) {
            throw Exception('Ghế $seat đã được đặt trong lúc bạn đang thực hiện giao dịch');
          }
        }

        print('Transaction - All seats still available, proceeding...');

        // Create ticket document với đầy đủ thông tin
        final ticketRef = _firestore.collection('tickets').doc();
        final ticketData = {
          'id': ticketRef.id,
          'userId': userId,
          'movieId': movieId,
          'movieTitle': movieTitle, // THÊM
          'showtimeId': showtimeId,
          'cinemaId': cinemaId,     // THÊM
          'cinemaName': cinemaName, // THÊM
          'showDate': showDate,     // THÊM
          'showTime': showTime,     // THÊM
          'seats': seats,
          'totalPrice': totalPrice,
          'paymentStatus': paymentMethod == 'cash' ? 'pending' : 'completed',
          'paymentMethod': paymentMethod,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'status': 'active',
        };

        print('Creating ticket with enhanced data: $ticketData');

        transaction.set(ticketRef, ticketData);

        // Update showtime seats
        final updatedBooked = List<String>.from(transactionShowtime.bookedSeats)..addAll(seats);
        final updatedAvailable = List<String>.from(transactionShowtime.availableSeats);

        for (String seat in seats) {
          updatedAvailable.remove(seat);
        }

        transaction.update(showtimeRef, {
          'bookedSeats': updatedBooked,
          'availableSeats': updatedAvailable,
          'updatedAt': Timestamp.now(),
        });

        print('Transaction completed successfully');
        return ticketRef.id;
      });

      print('Transaction result: $result');
      return result;

    } catch (e) {
      print('Transaction failed: $e');
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  Future<String?> _executeBookingTransaction({
    required String userId,
    required String movieId,
    required String showtimeId,
    required List<String> seats,
    required double totalPrice,
    required String paymentMethod,
    required Showtime currentShowtime,
  }) async {
    try {
      print('Starting Firestore transaction...');

      final result = await _firestore.runTransaction<String?>((transaction) async {
        print('Inside transaction - re-checking showtime...');

        final showtimeRef = _firestore.collection('showtimes').doc(showtimeId);
        final showtimeSnapshot = await transaction.get(showtimeRef);

        if (!showtimeSnapshot.exists) {
          throw Exception('Suất chiếu không tồn tại');
        }

        final transactionShowtime = Showtime.fromJson({
          ...showtimeSnapshot.data()!,
          'id': showtimeSnapshot.id
        });

        print('Transaction - Current available seats: ${transactionShowtime.availableSeats}');
        print('Transaction - Current booked seats: ${transactionShowtime.bookedSeats}');

        // Final seat availability check within transaction
        for (String seat in seats) {
          if (!transactionShowtime.isSeatAvailable(seat)) {
            throw Exception('Ghế $seat đã được đặt trong lúc bạn đang thực hiện giao dịch');
          }
        }

        print('Transaction - All seats still available, proceeding...');

        // Create ticket document
        final ticketRef = _firestore.collection('tickets').doc();
        final ticketData = {
          'id': ticketRef.id,
          'userId': userId,
          'movieId': movieId,
          'showtimeId': showtimeId,
          'seats': seats,
          'totalPrice': totalPrice,
          'paymentStatus': 'pending',
          'paymentMethod': paymentMethod,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'status': 'active',
        };

        print('Creating ticket with ID: ${ticketRef.id}');
        print('Ticket data: $ticketData');

        transaction.set(ticketRef, ticketData);

        // Update showtime seats
        final updatedBooked = List<String>.from(transactionShowtime.bookedSeats)..addAll(seats);
        final updatedAvailable = List<String>.from(transactionShowtime.availableSeats);

        for (String seat in seats) {
          updatedAvailable.remove(seat);
        }

        print('Updating showtime - New booked seats: $updatedBooked');
        print('Updating showtime - New available seats: $updatedAvailable');

        transaction.update(showtimeRef, {
          'bookedSeats': updatedBooked,
          'availableSeats': updatedAvailable,
          'updatedAt': Timestamp.now(),
        });

        print('Transaction completed successfully');
        return ticketRef.id; // RETURN ticket ID instead of bool
      });

      print('Transaction result: $result');
      return result;

    } catch (e) {
      print('Transaction failed: $e');

      // More specific error messages
      if (e.toString().contains('already-exists')) {
        _setError('Vé đã tồn tại. Vui lòng thử lại.');
      } else if (e.toString().contains('permission-denied')) {
        _setError('Không có quyền thực hiện thao tác này.');
      } else if (e.toString().contains('unavailable')) {
        _setError('Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.');
      } else {
        _setError(e.toString().replaceAll('Exception: ', ''));
      }

      return null;
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    print('Error set: $error');
    notifyListeners();
  }

  Future<bool> updatePaymentStatus(String ticketId, String status) async {
    try {
      print('Updating payment status for ticket: $ticketId to $status');

      await _firestore.collection('tickets').doc(ticketId).update({
        'paymentStatus': status,
        'updatedAt': Timestamp.now(),
      });

      print('Payment status updated successfully');
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      _errorMessage = 'Không thể cập nhật trạng thái thanh toán.';
      notifyListeners();
      return false;
    }
  }

  double calculateTotalPrice(List<String> seats, double pricePerSeat) {
    return seats.length * pricePerSeat;
  }

  Future<Showtime?> getShowtimeById(String showtimeId) async {
    try {
      final doc = await _firestore
          .collection('showtimes')
          .doc(showtimeId)
          .get();

      if (doc.exists) {
        return Showtime.fromJson({...doc.data()!, 'id': doc.id});
      }
    } catch (e) {
      print('Error fetching showtime: $e');
      _errorMessage = 'Không thể tải thông tin suất chiếu';
      notifyListeners();
    }
    return null;
  }

  Cinema? getCinemaById(String cinemaId) {
    try {
      return _cinemas.firstWhere((cinema) => cinema.id == cinemaId);
    } catch (e) {
      print('Cinema not found: $cinemaId');
      return null;
    }
  }

  List<Showtime> getShowtimesByCinema(String cinemaId) {
    return _showtimes.where((showtime) => showtime.cinemaId == cinemaId).toList();
  }

  List<Showtime> getShowtimesByDate(DateTime date) {
    return _showtimes.where((showtime) {
      final showtimeDate = showtime.startTime;
      return showtimeDate.year == date.year &&
          showtimeDate.month == date.month &&
          showtimeDate.day == date.day;
    }).toList();
  }

  void resetBookingState() {
    _selectedSeats.clear();
    _selectedShowtime = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshShowtime(String showtimeId) async {
    try {
      final updatedShowtime = await getShowtimeById(showtimeId);
      if (updatedShowtime != null && _selectedShowtime?.id == showtimeId) {
        _selectedShowtime = updatedShowtime;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing showtime: $e');
    }
  }

  bool canSelectSeat(String seatId) {
    if (_selectedShowtime == null) return false;

    if (!_selectedShowtime!.isSeatAvailable(seatId)) return false;

    if (_selectedSeats.contains(seatId)) return true;

    const maxSeatsPerBooking = 8;
    if (_selectedSeats.length >= maxSeatsPerBooking) {
      _errorMessage = 'Tối đa $maxSeatsPerBooking ghế mỗi lần đặt';
      notifyListeners();
      return false;
    }

    return true;
  }

  SeatStatus getSeatStatus(String seatId) {
    if (_selectedShowtime == null) return SeatStatus.unavailable;

    if (_selectedSeats.contains(seatId)) return SeatStatus.selected;
    if (_selectedShowtime!.isSeatBooked(seatId)) return SeatStatus.booked;
    if (_selectedShowtime!.isSeatAvailable(seatId)) return SeatStatus.available;

    return SeatStatus.unavailable;
  }
}

enum SeatStatus {
  available,
  booked,
  selected,
  unavailable,
}