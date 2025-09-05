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
                await _processPayPalPayment(context, bookingProvider, authProvider, totalPrice);
              } else {
                await _processBooking(context, bookingProvider, authProvider);
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
      BuildContext context,
      BookingProvider bookingProvider,
      AuthProvider authProvider,
      double totalPrice,
      ) async {
    try {
      print('Starting PayPal payment process...');

      // Navigate to PayPal checkout screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayPalCheckoutScreen(
            totalAmount: totalPrice, // Amount in VND will be converted to USD
            description: 'Movie ticket booking - ${movie!.title}',
            onSuccess: (paymentResult) async {
              print('PayPal payment successful: $paymentResult');

              // Close PayPal screen
              Navigator.pop(context);

              // Process the booking with PayPal payment info
              await _processBookingAfterPayment(
                context,
                bookingProvider,
                authProvider,
                paymentResult,
              );
            },
            onError: (error) {
              print('PayPal payment error: $error');
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thanh toán PayPal thất bại: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            onCancel: () {
              print('PayPal payment cancelled');
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thanh toán đã bị hủy'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      print('Error starting PayPal payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể khởi tạo thanh toán PayPal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processBookingAfterPayment(
      BuildContext context,
      BookingProvider bookingProvider,
      AuthProvider authProvider,
      Map<String, dynamic> paymentResult,
      ) async {
    if (_isProcessingBooking) return;

    try {
      setState(() {
        _isProcessingBooking = true;
      });

      print('Processing booking after successful PayPal payment...');

      final success = await bookingProvider.bookTicket(
        userId: authProvider.user!.uid,
        movieId: widget.movieId,
        showtimeId: selectedShowtime!.id,
        seats: bookingProvider.selectedSeats,
        totalPrice: bookingProvider.calculateTotalPrice(
          bookingProvider.selectedSeats,
          selectedShowtime!.price,
        ),
        paymentMethod: 'paypal',
      );

      setState(() {
        _isProcessingBooking = false;
      });

      if (!mounted) return;

      if (success) {
        _showSuccessDialog(context, bookingProvider, paymentResult);
      } else {
        final errorMsg = bookingProvider.errorMessage ?? 'Đặt vé thất bại sau khi thanh toán PayPal thành công. Vui lòng liên hệ hỗ trợ.';
        _showErrorDialog(context, errorMsg);
      }
    } catch (e) {
      print('Exception in _processBookingAfterPayment: $e');

      setState(() {
        _isProcessingBooking = false;
      });

      if (!mounted) return;

      _showErrorDialog(context, 'Có lỗi xảy ra sau khi thanh toán: ${e.toString()}');
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
      BuildContext context,
      BookingProvider bookingProvider,
      AuthProvider authProvider,
      ) async {
    if (_isProcessingBooking) return;

    try {
      setState(() {
        _isProcessingBooking = true;
      });

      print('Starting booking process...');

      final success = await bookingProvider.bookTicket(
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

      print('Booking API call completed. Success: $success');

      setState(() {
        _isProcessingBooking = false;
      });

      if (!mounted) {
        print('Widget is no longer mounted, cannot show dialog');
        return;
      }

      if (success) {
        print('Showing success dialog');
        _showSuccessDialog(context, bookingProvider);
      } else {
        print('Showing error dialog');
        final errorMsg = bookingProvider.errorMessage ?? 'Đặt vé thất bại. Vui lòng thử lại.';
        _showErrorDialog(context, errorMsg);
      }
    } catch (e) {
      print('Exception in _processBooking: $e');

      setState(() {
        _isProcessingBooking = false;
      });

      if (!mounted) {
        print('Widget is no longer mounted, cannot show error dialog');
        return;
      }

      _showErrorDialog(context, 'Có lỗi xảy ra: ${e.toString()}');
    }
  }

  void _showSuccessDialog(BuildContext context, BookingProvider bookingProvider, [Map<String, dynamic>? paymentResult]) {
    print('_showSuccessDialog called');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đặt vé thành công!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin đặt vé:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Phim: ${movie!.title}'),
            Text('• Rạp: ${selectedCinema!.name}'),
            Text('• Ngày: ${_formatDate(selectedDate!)}'),
            Text('• Suất: ${_formatTime(selectedShowtime!.startTime)}'),
            Text('• Ghế: ${bookingProvider.selectedSeats.join(', ')}'),
            Text('• Tổng tiền: ${bookingProvider.calculateTotalPrice(bookingProvider.selectedSeats, selectedShowtime!.price).toStringAsFixed(0)} VND'),

            if (selectedPaymentMethod == 'paypal' && paymentResult != null) ...[
              SizedBox(height: 8),
              Text('• Mã giao dịch PayPal: ${paymentResult['id'] ?? 'N/A'}'),
            ],

            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPaymentMethodColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getPaymentMethodColor().withOpacity(0.3)),
              ),
              child: Text(
                _getSuccessMessage(),
                style: TextStyle(
                  fontSize: 13,
                  color: _getPaymentMethodColor().withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToBookingHistory(context);
            },
            child: Text('Xem lịch sử đặt vé'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToHome(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Về trang chủ'),
          ),
        ],
      ),
    );
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
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
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentStep = 0;
                selectedDate = null;
                selectedCinema = null;
                selectedShowtime = null;
              });
              Provider.of<BookingProvider>(context, listen: false).resetBookingState();
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