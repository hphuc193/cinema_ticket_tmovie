// lib/screens/booking_screen.dart - Updated with PayPal integration
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../models/showtime_model.dart';
import '../models/movie_model.dart';
import '../models/cinema_model.dart';
import '../widgets/seat_selector.dart';
import 'paypal_checkout_screen.dart'; // Import PayPal screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
class BookingScreen extends StatefulWidget {
  final String movieId;

  const BookingScreen({
    Key? key,
    required this.movieId,
  }) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Movie? movie;
  List<Cinema> cinemas = [];
  List<DateTime> availableDates = [];
  List<Showtime> showtimes = [];

  String? _createdTicketId;

  DateTime? selectedDate;
  Cinema? selectedCinema;
  Showtime? selectedShowtime;
  String selectedPaymentMethod = 'cash';

  bool isLoading = true;
  bool isCinemasLoading = false;
  bool isShowtimesLoading = false;
  int currentStep = 0;

  bool isBookingInProgress = false;
  bool _isProcessingBooking = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    try {
      setState(() {
        isLoading = true;
      });

      bookingProvider.resetBookingState();
      bookingProvider.clearError();

      movie = await movieProvider.getMovieById(widget.movieId);
      if (movie == null) {
        throw Exception('Không tìm thấy thông tin phim');
      }

      cinemas = await bookingProvider.getCinemasByMovie(widget.movieId);
      availableDates = _generateAvailableDates();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải thông tin: ${e.toString()}')),
        );
      }
    }
  }

  List<DateTime> _generateAvailableDates() {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      dates.add(DateTime(now.year, now.month, now.day + i));
    }
    return dates;
  }

  Future<void> _loadShowtimes() async {
    if (selectedDate == null || selectedCinema == null) return;

    setState(() {
      isShowtimesLoading = true;
      showtimes = [];
      selectedShowtime = null;
    });

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.resetBookingState();

    try {
      final loadedShowtimes = await bookingProvider.getShowtimesByDateAndCinema(
        widget.movieId,
        selectedDate!,
        selectedCinema!.id,
      );

      setState(() {
        showtimes = loadedShowtimes;
        isShowtimesLoading = false;
        if (showtimes.isNotEmpty) {
          currentStep = 1;
        }
      });
    } catch (e) {
      print('Error loading showtimes: $e');
      setState(() {
        isShowtimesLoading = false;
        showtimes = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải suất chiếu: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt vé'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: _buildStepIndicator(),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(bookingProvider.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              bookingProvider.clearError();
            });
          }

          return isLoading
              ? Center(child: CircularProgressIndicator())
              : movie == null
              ? Center(child: Text('Không tìm thấy thông tin phim'))
              : Column(
            children: [
              _buildMovieInfoHeader(),
              Divider(),
              Expanded(
                child: _buildStepContent(),
              ),
              _buildBottomActionButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepItem(0, 'Chọn ngày & rạp', Icons.date_range),
          _buildStepConnector(),
          _buildStepItem(1, 'Suất chiếu', Icons.schedule),
          _buildStepConnector(),
          _buildStepItem(2, 'Chọn ghế', Icons.event_seat),
          _buildStepConnector(),
          _buildStepItem(3, 'Thanh toán', Icons.payment),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon) {
    bool isActive = currentStep >= step;
    bool isCurrent = currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
              border: isCurrent ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.grey[300],
    );
  }

  Widget _buildMovieInfoHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(movie!.posterUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie!.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${movie!.duration} phút',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (selectedDate != null && selectedCinema != null && selectedShowtime != null) ...[
                  SizedBox(height: 4),
                  Text(
                    '${_formatDate(selectedDate!)} - ${selectedCinema!.name}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${_formatTime(selectedShowtime!.startTime)} - ${selectedShowtime!.price.toStringAsFixed(0)} VND/vé',
                    style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildDateAndCinemaSelection();
      case 1:
        return _buildShowtimeSelection();
      case 2:
        return _buildSeatSelection();
      case 3:
        return _buildPaymentSelection();
      default:
        return Container();
    }
  }

  Widget _buildDateAndCinemaSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn ngày chiếu:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableDates.length,
              itemBuilder: (context, index) {
                final date = availableDates[index];
                final isSelected = selectedDate != null &&
                    selectedDate!.day == date.day &&
                    selectedDate!.month == date.month &&
                    selectedDate!.year == date.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      selectedShowtime = null;
                      showtimes = [];
                      if (currentStep > 0) currentStep = 0;
                    });
                    Provider.of<BookingProvider>(context, listen: false).resetBookingState();
                  },
                  child: Container(
                    width: 70,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getShortWeekday(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          '${date.month}/${date.year}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 24),

          Text(
            'Chọn rạp chiếu:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          if (cinemas.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Không có rạp chiếu nào',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Không tìm thấy rạp chiếu cho phim này',
                    style: TextStyle(color: Colors.orange[700], fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: cinemas.length,
              itemBuilder: (context, index) {
                final cinema = cinemas[index];
                final isSelected = selectedCinema?.id == cinema.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCinema = cinema;
                      selectedShowtime = null;
                      showtimes = [];
                      if (currentStep > 0) currentStep = 0;
                    });
                    Provider.of<BookingProvider>(context, listen: false).resetBookingState();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_movies,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cinema.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.black,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                cinema.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (cinema.rooms.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            '${cinema.rooms.length} phòng chiếu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildShowtimeSelection() {
    if (isShowtimesLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải suất chiếu...'),
          ],
        ),
      );
    }

    if (showtimes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Không có suất chiếu',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            Text(
              'Vui lòng chọn ngày và rạp khác',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentStep = 0;
                });
              },
              child: Text('Chọn lại'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn suất chiếu:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: showtimes.length,
            itemBuilder: (context, index) {
              final showtime = showtimes[index];
              final isSelected = selectedShowtime?.id == showtime.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedShowtime = showtime;
                  });
                  Provider.of<BookingProvider>(context, listen: false)
                      .selectShowtime(showtime);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(showtime.startTime),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${showtime.price.toStringAsFixed(0)} VND',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeatSelection() {
    if (selectedShowtime == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_seat, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Vui lòng chọn suất chiếu',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentStep = 1;
                });
              },
              child: Text('Quay lại chọn suất'),
            ),
          ],
        ),
      );
    }

    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Thông tin suất chiếu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rạp: ${selectedCinema?.name ?? ""}'),
                        Text('Phòng: ${selectedShowtime!.roomId}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ngày: ${_formatDate(selectedDate!)}'),
                        Text('Giờ: ${_formatTime(selectedShowtime!.startTime)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Giá vé: ${selectedShowtime!.price.toStringAsFixed(0)} VND'),
                        Text(
                          'Còn ${selectedShowtime!.availableSeats.length} ghế',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[300]!, Colors.grey[100]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'MÀN HÌNH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              SeatSelector(
                showtime: selectedShowtime!,
                onSeatsSelected: (seats) {
                  setState(() {});
                },
              ),

              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSeatLegend(Colors.grey[300]!, 'Trống'),
                    _buildSeatLegend(Colors.red, 'Đã đặt'),
                    _buildSeatLegend(Theme.of(context).primaryColor, 'Đang chọn'),
                  ],
                ),
              ),

              if (bookingProvider.selectedSeats.isNotEmpty)
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tóm tắt đặt vé',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Số ghế đã chọn:'),
                          Text(
                            '${bookingProvider.selectedSeats.length}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ghế:'),
                          Text(
                            bookingProvider.selectedSeats.join(', '),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng tiền:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${bookingProvider.calculateTotalPrice(bookingProvider.selectedSeats, selectedShowtime!.price).toStringAsFixed(0)} VND',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeatLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPaymentSelection() {
    return Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Card(
        child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin đặt vé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoRow('Phim:', movie!.title),
            _buildInfoRow('Rạp:', selectedCinema?.name ?? ''),
            _buildInfoRow('Ngày:', _formatDate(selectedDate!)),
            _buildInfoRow('Suất:', _formatTime(selectedShowtime!.startTime)),
            _buildInfoRow('Ghế:', bookingProvider.selectedSeats.isEmpty
                ? 'Chưa chọn ghế'
                : bookingProvider.selectedSeats.join(', ')),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng tiền:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${bookingProvider.calculateTotalPrice(bookingProvider.selectedSeats, selectedShowtime!.price).toStringAsFixed(0)} VND',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    SizedBox(height: 20),
    Text(
    'Phương thức thanh toán',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 12),
    Card(
    child: Column(
    children: [
    _buildPaymentOption('cash', Icons.money, Colors.green, 'Tiền mặt tại rạp', 'Thanh toán khi nhận vé tại quầy'),Divider(height: 1),
      _buildPaymentOption('momo', Icons.account_balance_wallet, Colors.pink, 'Ví MoMo', 'Thanh toán online qua ví MoMo'),
      Divider(height: 1),
      _buildPaymentOption('paypal', Icons.payment, Colors.blue[700]!, 'PayPal', 'Thanh toán quốc tế qua PayPal (USD)'),
      Divider(height: 1),
      _buildPaymentOption('card', Icons.credit_card, Colors.blue, 'Thẻ ngân hàng', 'Thanh toán qua thẻ ATM/Visa/MasterCard'),
    ],
    ),
    ),
            ],
        ),
      );
        },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, IconData icon, Color iconColor, String title, String subtitle) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle),
      value: value,
      groupValue: selectedPaymentMethod,
      onChanged: (newValue) {
        setState(() {
          selectedPaymentMethod = newValue!;
        });
      },
    );
  }

  Widget _buildBottomActionButton() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: _buildStepButton(bookingProvider),
          ),
        );
      },
    );
  }

  Widget _buildStepButton(BookingProvider bookingProvider) {
    switch (currentStep) {
      case 0:
        return ElevatedButton(
          onPressed: (selectedDate != null && selectedCinema != null && !isShowtimesLoading)
              ? _loadShowtimes
              : null,
          child: isShowtimesLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Text('Đang tải...'),
            ],
          )
              : Text('Tiếp tục'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            minimumSize: Size(double.infinity, 50),
          ),
        );

      case 1:
        return ElevatedButton(
          onPressed: selectedShowtime != null
              ? () {
            setState(() {
              currentStep = 2;
            });
          }
              : null,
          child: Text('Chọn ghế'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            minimumSize: Size(double.infinity, 50),
          ),
        );

      case 2:
        return ElevatedButton(
          onPressed: bookingProvider.selectedSeats.isNotEmpty
              ? () {
            setState(() {
              currentStep = 3;
            });
          }
              : null,
          child: Text('Thanh toán'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            minimumSize: Size(double.infinity, 50),
          ),
        );

      case 3:
        return ElevatedButton(
          onPressed: bookingProvider.selectedSeats.isNotEmpty && !_isProcessingBooking
              ? () => _confirmBooking(context, bookingProvider)
              : null,
          child: _isProcessingBooking
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Text('Đang xử lý...'),
            ],
          )
              : Text('Xác nhận đặt vé'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Colors.red,
          ),
        );

      default:
        return Container();
    }
  }

  void _confirmBooking(BuildContext context, BookingProvider bookingProvider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đăng nhập để đặt vé'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Đăng nhập',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ),
      );
      return;
    }

    // Calculate total price
    final totalPrice = bookingProvider.calculateTotalPrice(
      bookingProvider.selectedSeats,
      selectedShowtime!.price,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận đặt vé',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin đặt vé:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              _buildConfirmRow('Phim:', movie!.title),
              _buildConfirmRow('Rạp:', selectedCinema!.name),
              _buildConfirmRow('Ngày:', _formatDate(selectedDate!)),
              _buildConfirmRow('Suất:', _formatTime(selectedShowtime!.startTime)),
              _buildConfirmRow('Ghế:', bookingProvider.selectedSeats.join(', ')),
              _buildConfirmRow('Thanh toán:', _getPaymentMethodText(selectedPaymentMethod)),

              // Show currency conversion for PayPal
              if (selectedPaymentMethod == 'paypal') ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin PayPal:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text('• Thanh toán qua PayPal (USD)'),
                      Text('• Tỷ giá: 1 USD ≈ 24,000 VND'),
                      Text('• Số tiền quy đổi: \$${(totalPrice / 24000).toStringAsFixed(2)} USD'),
                    ],
                  ),
                ),
              ],

              Divider(thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng tiền:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${totalPrice.toStringAsFixed(0)} VND',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                      if (selectedPaymentMethod == 'paypal')
                        Text(
                          '(\$${(totalPrice / 24000).toStringAsFixed(2)} USD)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Handle different payment methods
              if (selectedPaymentMethod == 'paypal') {
                await _processPayPalPayment(bookingProvider, authProvider, totalPrice);
              } else {
                await _processBooking(bookingProvider, authProvider);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedPaymentMethod == 'paypal' ? Colors.blue[700] : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(selectedPaymentMethod == 'paypal' ? 'Thanh toán PayPal' : 'Xác nhận đặt vé'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayPalPayment(
      BookingProvider bookingProvider,
      AuthProvider authProvider,
      double totalPrice,
      ) async {
    try {
      print('Starting PayPal payment process...');

      // QUAN TRỌNG: Backup tất cả state trước khi navigate
      final backupState = {
        'movieId': widget.movieId,
        'movieTitle': movie?.title,
        'cinemaId': selectedCinema?.id,
        'cinemaName': selectedCinema?.name,
        'selectedDate': selectedDate?.toIso8601String(),
        'showtimeId': selectedShowtime?.id,
        'showtimeStartTime': selectedShowtime?.startTime.toIso8601String(),
        'showtimePrice': selectedShowtime?.price,
        'selectedSeats': List<String>.from(bookingProvider.selectedSeats), // Tạo copy
        'paymentMethod': selectedPaymentMethod,
        'totalPrice': totalPrice,
      };

      print('Backup state: $backupState');

      // Store backup in SharedPreferences hoặc local variable
      await _storeBackupState(backupState);

      final currentContext = context;

      final result = await Navigator.of(currentContext).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => PayPalCheckoutScreen(
            totalAmount: totalPrice,
            description: 'Movie ticket booking - ${movie!.title}',
            onSuccess: (paymentResult) {
              Navigator.of(context).pop(paymentResult);
            },
            onError: (error) {
              Navigator.of(context).pop({'error': error});
            },
            onCancel: () {
              Navigator.of(context).pop({'cancelled': true});
            },
          ),
        ),
      );

      if (!mounted) return;

      // Restore state sau khi navigate back
      await _restoreBackupState(bookingProvider);

      if (result == null) {
        print('PayPal payment cancelled or dismissed');
        return;
      }

      if (result.containsKey('error')) {
        _showSnackBar('Thanh toán PayPal thất bại: ${result['error']}', Colors.red);
        return;
      }

      if (result.containsKey('cancelled')) {
        _showSnackBar('Thanh toán đã bị hủy', Colors.orange);
        return;
      }

      if (result.containsKey('id')) {
        print('Processing booking with restored state...');
        await _processBookingAfterPayment(bookingProvider, authProvider, result);
      }

    } catch (e) {
      print('Error in PayPal payment process: $e');
      if (mounted) {
        _showSnackBar('Không thể khởi tạo thanh toán PayPal: ${e.toString()}', Colors.red);
      }
    }
  }

  // 2. Store backup state
  Future<void> _storeBackupState(Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('booking_backup', jsonEncode(state));
      print('State backed up successfully');
    } catch (e) {
      print('Error storing backup state: $e');
    }
  }

  // 3. Restore backup state
  Future<void> _restoreBackupState(BookingProvider bookingProvider) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString('booking_backup');

      if (backupJson != null) {
        final backupState = jsonDecode(backupJson) as Map<String, dynamic>;

        // Restore BookingProvider state
        if (backupState['selectedSeats'] != null) {
          final seats = List<String>.from(backupState['selectedSeats']);
          bookingProvider.selectedSeats.clear();
          bookingProvider.selectedSeats.addAll(seats);
          print('Restored ${seats.length} seats: $seats');
        }

        // Restore local state nếu cần
        setState(() {
          if (backupState['selectedDate'] != null) {
            selectedDate = DateTime.parse(backupState['selectedDate']);
          }
          selectedPaymentMethod = backupState['paymentMethod'] ?? 'cash';
        });

        // Clear backup sau khi restore
        await prefs.remove('booking_backup');
        print('State restored and backup cleared');
      }
    } catch (e) {
      print('Error restoring backup state: $e');
    }
  }

  // 4. Alternative: Pass seats directly to navigation
  void _navigateToSuccessScreenSafe(
      BookingProvider bookingProvider,
      [Map<String, dynamic>? paymentResult]
      ) {
    if (!mounted) return;

    // Lấy seats trực tiếp từ backup hoặc provider
    List<String> seatsList = [];

    if (bookingProvider.selectedSeats.isNotEmpty) {
      seatsList = List<String>.from(bookingProvider.selectedSeats);
    } else {
      // Fallback: try to get from backup
      _tryRestoreSeatsFromBackup().then((seats) {
        if (seats.isNotEmpty) {
          _performNavigation(seats, bookingProvider, paymentResult);
        } else {
          _showErrorDialog(context, 'Không thể khôi phục thông tin ghế đã chọn');
        }
      });
      return;
    }

    _performNavigation(seatsList, bookingProvider, paymentResult);
  }

  Future<List<String>> _tryRestoreSeatsFromBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString('booking_backup');

      if (backupJson != null) {
        final backupState = jsonDecode(backupJson) as Map<String, dynamic>;
        if (backupState['selectedSeats'] != null) {
          return List<String>.from(backupState['selectedSeats']);
        }
      }
    } catch (e) {
      print('Error restoring seats from backup: $e');
    }
    return [];
  }

  void _performNavigation(
      List<String> seats,
      BookingProvider bookingProvider,
      Map<String, dynamic>? paymentResult
      ) {
    if (!mounted || seats.isEmpty) return;

    try {
      final totalPrice = selectedShowtime != null
          ? bookingProvider.calculateTotalPrice(seats, selectedShowtime!.price)
          : 0.0;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            movieTitle: movie?.title ?? 'Phim không xác định',
            cinemaName: selectedCinema?.name ?? 'Rạp không xác định',
            showDate: selectedDate != null ? _formatDate(selectedDate!) : 'Ngày không xác định',
            showTime: selectedShowtime != null ? _formatTime(selectedShowtime!.startTime) : 'Giờ không xác định',
            seats: seats, // Sử dụng seats đã validate
            totalPrice: totalPrice,
            paymentMethod: selectedPaymentMethod,
            ticketId: _createdTicketId,
          ),
        ),
      );

      print('✅ Navigation completed with ${seats.length} seats');
    } catch (e) {
      print('❌ Navigation error: $e');
      if (mounted) {
        _showErrorDialog(context, 'Có lỗi xảy ra khi chuyển màn hình: ${e.toString()}');
      }
    }
  }

// 5. Cải thiện validation trong _navigateToSuccessScreen
  void _navigateToSuccessScreenImproved(
      BookingProvider bookingProvider,
      [Map<String, dynamic>? paymentResult]
      ) {
    if (!mounted) {
      print('❌ Widget not mounted, cannot navigate');
      return;
    }

    print('🎉 NAVIGATING TO SUCCESS SCREEN');

    // Check seats first and try to restore if empty
    if (bookingProvider.selectedSeats.isEmpty) {
      print('⚠️ Selected seats is empty, trying to restore...');

      _tryRestoreSeatsFromBackup().then((restoredSeats) {
        if (restoredSeats.isNotEmpty) {
          bookingProvider.selectedSeats.addAll(restoredSeats);
          _performStandardNavigation(bookingProvider, paymentResult);
        } else {
          // Last resort: get seats from ticket document
          if (_createdTicketId != null) {
            _getSeatsFromTicket(_createdTicketId!).then((ticketSeats) {
              if (ticketSeats.isNotEmpty) {
                _performNavigation(ticketSeats, bookingProvider, paymentResult);
              } else {
                _showErrorDialog(context, 'Không thể khôi phục thông tin ghế đã chọn');
              }
            });
          } else {
            _showErrorDialog(context, 'Thông tin ghế đã chọn bị mất. Vui lòng thử lại từ đầu');
          }
        }
      });
      return;
    }

    _performStandardNavigation(bookingProvider, paymentResult);
  }

  void _performStandardNavigation(
      BookingProvider bookingProvider,
      Map<String, dynamic>? paymentResult
      ) {
    // Validation checks...
    if (movie == null || selectedCinema == null || selectedDate == null ||
        selectedShowtime == null || bookingProvider.selectedSeats.isEmpty) {
      _showErrorDialog(context, 'Thông tin đặt vé không đầy đủ. Vui lòng thử lại từ đầu.');
      return;
    }

    _performNavigation(bookingProvider.selectedSeats, bookingProvider, paymentResult);
  }

  Future<List<String>> _getSeatsFromTicket(String ticketId) async {
    try {
      final ticketDoc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .get();

      if (ticketDoc.exists) {
        final ticketData = ticketDoc.data()!;
        return List<String>.from(ticketData['seats'] ?? []);
      }
    } catch (e) {
      print('Error getting seats from ticket: $e');
    }
    return [];
  }


  Future<void> _processBookingAfterPayment(
      BookingProvider bookingProvider,
      AuthProvider authProvider,
      Map<String, dynamic> paymentResult,
      ) async {
    if (_isProcessingBooking || !mounted) {
      print('Already processing or widget disposed');
      return;
    }

    final currentContext = context;

    try {
      setState(() {
        _isProcessingBooking = true;
      });

      print('Processing booking after PayPal payment...');

      // Show processing dialog
      if (mounted) {
        showDialog(
          context: currentContext,
          barrierDismissible: false,
          builder: (dialogContext) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang xử lý đặt vé...'),
                  SizedBox(height: 8),
                  Text(
                    'PayPal thanh toán thành công',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Create booking
      final ticketId = await bookingProvider.bookTicket(
        userId: authProvider.user!.uid,
        movieId: widget.movieId,
        showtimeId: selectedShowtime!.id,
        seats: bookingProvider.selectedSeats,
        totalPrice: bookingProvider.calculateTotalPrice(
          bookingProvider.selectedSeats,
          selectedShowtime!.price,
        ),
        paymentMethod: selectedPaymentMethod,
        // THÊM CÁC DÒNG NÀY:
        cinemaId: selectedCinema?.id,
        cinemaName: selectedCinema?.name,
        movieTitle: movie?.title,
      );

      // Close processing dialog
      if (mounted) {
        try {
          Navigator.of(currentContext).pop();
        } catch (e) {
          print('Error closing dialog: $e');
        }
      }

      if (!mounted) {
        print('Widget disposed after booking');
        return;
      }

      if (ticketId != null) {
        _createdTicketId = ticketId;
        print('Ticket created: $ticketId');

        // Update payment status
        await _updatePaymentStatusAfterPayPal(ticketId, paymentResult['id']);

        // QUAN TRỌNG: Navigate bằng ticket data thay vì UI state
        await _navigateWithTicketData(ticketId);

      } else {
        final errorMsg = bookingProvider.errorMessage ??
            'Đặt vé thất bại sau khi thanh toán PayPal thành công. Vui lòng liên hệ hỗ trợ.';
        if (mounted) {
          _showErrorDialog(currentContext, errorMsg);
        }
      }
    } catch (e) {
      print('Exception in _processBookingAfterPayment: $e');

      if (mounted) {
        try {
          Navigator.of(currentContext).pop();
        } catch (_) {}

        _showErrorDialog(currentContext, 'Có lỗi xảy ra sau khi thanh toán: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingBooking = false;
        });
      }
    }
  }
  Future<void> _navigateWithTicketData(String ticketId) async {
    try {
      print('Fetching ticket data for navigation...');

      final ticketDoc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .get();

      if (!ticketDoc.exists) {
        throw Exception('Ticket document not found');
      }

      final ticketData = ticketDoc.data()!;
      print('Ticket data retrieved: $ticketData');

      // Giờ có thể lấy trực tiếp từ ticket data
      final movieTitle = ticketData['movieTitle'] ?? 'Phim không xác định';
      final cinemaName = ticketData['cinemaName'] ?? 'Rạp không xác định';
      final showDate = ticketData['showDate'] ?? 'Ngày không xác định';
      final showTime = ticketData['showTime'] ?? 'Giờ không xác định';

      if (!mounted) return;

      print('Final data for navigation:');
      print('Movie: $movieTitle');
      print('Cinema: $cinemaName');
      print('Date: $showDate');
      print('Time: $showTime');

      // Navigate với data từ ticket
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            movieTitle: movieTitle,
            cinemaName: cinemaName,
            showDate: showDate,
            showTime: showTime,
            seats: List<String>.from(ticketData['seats'] ?? []),
            totalPrice: (ticketData['totalPrice'] ?? 0.0).toDouble(),
            paymentMethod: ticketData['paymentMethod'] ?? 'cash',
            ticketId: ticketId,
          ),
        ),
      );

      print('Navigation completed successfully with ticket data');

    } catch (e) {
      print('Error navigating with ticket data: $e');

      if (mounted) {
        // Fallback: navigate với minimal data
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              movieTitle: movie?.title ?? 'Đặt vé thành công',
              cinemaName: selectedCinema?.name ?? 'Rạp chiếu phim',
              showDate: selectedDate != null ? _formatDate(selectedDate!) : 'Đã đặt',
              showTime: selectedShowtime != null ? _formatTime(selectedShowtime!.startTime) : 'Đã đặt',
              seats: ['Vé đã được đặt thành công'],
              totalPrice: 0.0,
              paymentMethod: 'paypal',
              ticketId: ticketId,
            ),
          ),
        );
      }
    }
  }

  Future<void> _updatePaymentStatusAfterPayPal(String ticketId, String paypalPaymentId) async {
    try {
      print('Updating payment status for ticket: $ticketId');

      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update({
        'paymentStatus': 'completed',
        'paypalPaymentId': paypalPaymentId,
        'updatedAt': Timestamp.now(),
      });

      print('Payment status updated successfully');
    } catch (e) {
      print('Error updating payment status: $e');
      // Don't throw error since booking was successful
    }
  }

  void _navigateToSuccessScreen(
      BookingProvider bookingProvider,
      [Map<String, dynamic>? paymentResult]
      ) {
    if (!mounted) {
      print('❌ Widget not mounted, cannot navigate');
      return;
    }

    print('🎉 NAVIGATING TO SUCCESS SCREEN');
    print('Payment Method: $selectedPaymentMethod');
    print('Created Ticket ID: $_createdTicketId');
    print('Payment Result: $paymentResult');

    // Detailed debugging of required data
    print('=== NAVIGATION DATA DEBUG ===');
    print('Movie: ${movie?.title ?? "NULL"}');
    print('Selected Cinema: ${selectedCinema?.name ?? "NULL"}');
    print('Selected Date: ${selectedDate != null ? _formatDate(selectedDate!) : "NULL"}');
    print('Selected Showtime: ${selectedShowtime != null ? _formatTime(selectedShowtime!.startTime) : "NULL"}');
    print('Selected Seats: ${bookingProvider.selectedSeats}');
    print('Selected Seats Empty: ${bookingProvider.selectedSeats.isEmpty}');
    print('============================');

    // Check each field individually and provide specific error messages
    if (movie == null) {
      print('❌ Movie is null');
      _showErrorDialog(context, 'Thông tin phim bị mất. Vui lòng thử lại từ đầu.');
      return;
    }

    if (selectedCinema == null) {
      print('❌ Selected cinema is null');
      _showErrorDialog(context, 'Thông tin rạp chiếu bị mất. Vui lòng thử lại từ đầu.');
      return;
    }

    if (selectedDate == null) {
      print('❌ Selected date is null');
      _showErrorDialog(context, 'Thông tin ngày chiếu bị mất. Vui lòng thử lại từ đầu.');
      return;
    }

    if (selectedShowtime == null) {
      print('❌ Selected showtime is null');
      _showErrorDialog(context, 'Thông tin suất chiếu bị mất. Vui lòng thử lại từ đầu.');
      return;
    }

    if (bookingProvider.selectedSeats.isEmpty) {
      print('❌ Selected seats is empty');
      _showErrorDialog(context, 'Thông tin ghế đã chọn bị mất. Vui lòng thử lại từ đầu.');
      return;
    }

    print('✅ All required data validated successfully');

    try {
      // Calculate total price again to ensure accuracy
      final totalPrice = bookingProvider.calculateTotalPrice(
        bookingProvider.selectedSeats,
        selectedShowtime!.price,
      );

      print('Total Price: $totalPrice');
      print('Creating success screen with all validated data...');

      // Create a copy of seats to avoid reference issues
      final seatsCopy = List<String>.from(bookingProvider.selectedSeats);

      // Use current context for navigation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            print('Building BookingSuccessScreen...');
            return BookingSuccessScreen(
              movieTitle: movie!.title,
              cinemaName: selectedCinema!.name,
              showDate: _formatDate(selectedDate!),
              showTime: _formatTime(selectedShowtime!.startTime),
              seats: seatsCopy,
              totalPrice: totalPrice,
              paymentMethod: selectedPaymentMethod,
              ticketId: _createdTicketId,
            );
          },
        ),
      ).then((_) {
        print('✅ Navigation completed successfully');
      }).catchError((error) {
        print('❌ Navigation error: $error');
        if (mounted) {
          _showErrorDialog(context, 'Không thể chuyển tới màn hình thành công: ${error.toString()}');
        }
      });

    } catch (e, stackTrace) {
      print('❌ Exception in _navigateToSuccessScreen: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        _showErrorDialog(context, 'Có lỗi xảy ra khi chuyển màn hình: ${e.toString()}');
      }
    }
  }

  // Thêm method để backup và restore state nếu cần
  void _backupBookingState() {
    print('🔄 Backing up booking state...');

    // Get BookingProvider instance
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    // Store critical data in temporary variables or SharedPreferences if needed
    final stateBackup = {
      'movieId': widget.movieId,
      'movieTitle': movie?.title,
      'cinemaId': selectedCinema?.id,
      'cinemaName': selectedCinema?.name,
      'selectedDate': selectedDate?.toIso8601String(),
      'showtimeId': selectedShowtime?.id,
      'showtimeStartTime': selectedShowtime?.startTime.toIso8601String(),
      'showtimePrice': selectedShowtime?.price,
      'selectedSeats': bookingProvider.selectedSeats, // Now bookingProvider is defined
      'paymentMethod': selectedPaymentMethod,
      'ticketId': _createdTicketId,
    };
    print('Backup data: $stateBackup');
  }

// Method để force navigate với fallback data
  void _forceNavigateToSuccess(BookingProvider bookingProvider, [Map<String, dynamic>? paymentResult]) {
    print('🚨 FORCE NAVIGATE TO SUCCESS - Using fallback data');

    // Try to get ticket info from Firestore if we have ticket ID
    if (_createdTicketId != null) {
      _navigateWithTicketId(_createdTicketId!, bookingProvider, paymentResult);
    } else {
      // Last resort: navigate with minimal info
      _navigateWithMinimalData(bookingProvider, paymentResult);
    }
  }
  Future<void> _navigateWithTicketId(String ticketId, BookingProvider bookingProvider, [Map<String, dynamic>? paymentResult]) async {
    try {
      print('📋 Fetching ticket data from Firestore...');

      final ticketDoc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .get();

      if (ticketDoc.exists && mounted) {
        final ticketData = ticketDoc.data()!;

        print('Retrieved ticket data: $ticketData');

        // Use data from ticket document
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              movieTitle: movie?.title ?? 'Phim không xác định',
              cinemaName: selectedCinema?.name ?? 'Rạp không xác định',
              showDate: selectedDate != null ? _formatDate(selectedDate!) : 'Ngày không xác định',
              showTime: selectedShowtime != null ? _formatTime(selectedShowtime!.startTime) : 'Giờ không xác định',
              seats: List<String>.from(ticketData['seats'] ?? []),
              totalPrice: (ticketData['totalPrice'] ?? 0.0).toDouble(),
              paymentMethod: ticketData['paymentMethod'] ?? 'cash',
              ticketId: ticketId,
            ),
          ),
        );

        print('✅ Navigation with ticket data completed');
      } else {
        print('❌ Ticket document not found or widget disposed');
        _navigateWithMinimalData(bookingProvider, paymentResult);
      }
    } catch (e) {
      print('❌ Error fetching ticket data: $e');
      _navigateWithMinimalData(bookingProvider, paymentResult);
    }
  }

  void _navigateWithMinimalData(BookingProvider bookingProvider, [Map<String, dynamic>? paymentResult]) {
    if (!mounted) return;

    print('🆘 MINIMAL DATA NAVIGATION - Last resort');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(
          movieTitle: movie?.title ?? 'Đặt vé thành công',
          cinemaName: selectedCinema?.name ?? 'Rạp chiếu phim',
          showDate: selectedDate != null ? _formatDate(selectedDate!) : DateTime.now().day.toString() + '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString(),
          showTime: selectedShowtime != null ? _formatTime(selectedShowtime!.startTime) : 'Đã đặt',
          seats: bookingProvider.selectedSeats.isNotEmpty ? bookingProvider.selectedSeats : ['Ghế đã đặt'],
          totalPrice: selectedShowtime != null ? bookingProvider.calculateTotalPrice(bookingProvider.selectedSeats, selectedShowtime!.price) : 0.0,
          paymentMethod: selectedPaymentMethod,
          ticketId: _createdTicketId,
        ),
      ),
    );

    print('✅ Minimal navigation completed');
  }

  // Helper methods remain the same
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
            ),
          );
        }
      });
    }
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking(
      BookingProvider bookingProvider,
      AuthProvider authProvider,
      ) async {
    if (_isProcessingBooking || !mounted) {
      print('Already processing or widget disposed');
      return;
    }

    try {
      setState(() {
        _isProcessingBooking = true;
      });

      print('Starting regular booking process...');

      final ticketId = await bookingProvider.bookTicket(
        userId: authProvider.user!.uid,
        movieId: widget.movieId,
        showtimeId: selectedShowtime!.id,
        seats: bookingProvider.selectedSeats,
        totalPrice: bookingProvider.calculateTotalPrice(
          bookingProvider.selectedSeats,
          selectedShowtime!.price,
        ),
        paymentMethod: selectedPaymentMethod,
      );

      if (!mounted) return;

      if (ticketId != null) {
        _createdTicketId = ticketId;
        print('Ticket created successfully: $ticketId');

        // Sử dụng ticket data thay vì UI state
        await _navigateWithTicketData(ticketId);
      } else {
        final errorMsg = bookingProvider.errorMessage ?? 'Đặt vé thất bại. Vui lòng thử lại.';
        _showErrorDialog(context, errorMsg);
      }
    } catch (e) {
      print('Exception in _processBooking: $e');
      if (mounted) {
        _showErrorDialog(context, 'Có lỗi xảy ra: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingBooking = false;
        });
      }
    }
  }

  // Thêm method check ticket status
  Future<bool> _checkTicketExists(String ticketId) async {
    try {
      final ticketDoc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .get();

      return ticketDoc.exists;
    } catch (e) {
      print('Error checking ticket: $e');
      return false;
    }
  }
  // Debug method để kiểm tra ticket trong database
  Future<void> _debugTicketStatus() async {
    if (_createdTicketId != null) {
      try {
        final ticketDoc = await FirebaseFirestore.instance
            .collection('tickets')
            .doc(_createdTicketId!)
            .get();

        if (ticketDoc.exists) {
          print('✅ TICKET EXISTS IN DATABASE');
          print('Ticket data: ${ticketDoc.data()}');
        } else {
          print('❌ TICKET NOT FOUND IN DATABASE');
        }
      } catch (e) {
        print('Error checking ticket status: $e');
      }
    }
  }

  Color _getPaymentMethodColor() {
    switch (selectedPaymentMethod) {
      case 'cash':
        return Colors.orange;
      case 'paypal':
        return Colors.blue;
      case 'momo':
        return Colors.pink;
      case 'card':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getSuccessMessage() {
    switch (selectedPaymentMethod) {
      case 'cash':
        return '⚠️ Vui lòng đến rạp trước 15 phút để thanh toán và nhận vé.';
      case 'paypal':
        return '✅ Vé của bạn đã được thanh toán qua PayPal. Kiểm tra email để xem chi tiết.';
      case 'momo':
        return '✅ Vé của bạn đã được thanh toán qua MoMo. Kiểm tra ứng dụng MoMo để xem chi tiết.';
      case 'card':
        return '✅ Vé của bạn đã được thanh toán qua thẻ ngân hàng. Kiểm tra SMS/email để xem chi tiết.';
      default:
        return '✅ Vé của bạn đã được đặt thành công.';
    }
  }

  // Updated error dialog method
  void _showErrorDialog(BuildContext dialogContext, String message) {
    if (!mounted) return;

    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text(
              'Đặt vé thất bại',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) Navigator.of(context).pop();
            },
            child: Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                Navigator.of(context).pop();
                setState(() {
                  currentStep = 0;
                  selectedDate = null;
                  selectedCinema = null;
                  selectedShowtime = null;
                  _isProcessingBooking = false;
                });
                Provider.of<BookingProvider>(context, listen: false).resetBookingState();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _debugNavigationState() {
    print('=== DEBUG NAVIGATION STATE ===');
    print('Current context mounted: $mounted');
    print('Navigator canPop: ${Navigator.of(context).canPop()}');
    print('Current route: ${ModalRoute.of(context)?.settings.name}');
    print('Is processing booking: $_isProcessingBooking');
    print('Created ticket ID: $_createdTicketId');
    print('Selected payment method: $selectedPaymentMethod');
    print('Movie: ${movie?.title}');
    print('Cinema: ${selectedCinema?.name}');
    print('Seats: ${Provider.of<BookingProvider>(context, listen: false).selectedSeats}');
    print('==============================');
  }

// Method để clear tất cả state và reset
  void _resetAllBookingState() {
    print('Resetting all booking state...');

    setState(() {
      _isProcessingBooking = false;
      _createdTicketId = null;
      currentStep = 0;
      selectedDate = null;
      selectedCinema = null;
      selectedShowtime = null;
      selectedPaymentMethod = 'cash';
    });

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.resetBookingState();

    print('State reset completed');
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
          (route) => false,
    );
  }

  void _navigateToBookingHistory(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/booking-history',
          (route) => route.settings.name == '/',
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getShortWeekday(DateTime date) {
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return weekdays[date.weekday % 7];
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'Tiền mặt tại rạp';
      case 'momo':
        return 'Ví MoMo';
      case 'card':
        return 'Thẻ ngân hàng';
      case 'paypal':
        return 'PayPal';
      default:
        return 'Không xác định';
    }
  }
}

