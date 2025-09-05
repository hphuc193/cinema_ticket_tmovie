// lib/widgets/seat_selector.dart - Fixed version with matching seat format
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/showtime_model.dart';
import '../providers/booking_provider.dart';

class SeatSelector extends StatefulWidget {
  final Showtime showtime;
  final Function(List<String>) onSeatsSelected;

  const SeatSelector({
    Key? key,
    required this.showtime,
    required this.onSeatsSelected,
  }) : super(key: key);

  @override
  _SeatSelectorState createState() => _SeatSelectorState();
}

class _SeatSelectorState extends State<SeatSelector> {
  late List<List<String>> seatLayout;

  @override
  void initState() {
    super.initState();
    _initializeSeatLayout();
    _debugShowtimeData();
  }

  void _debugShowtimeData() {
    print('=== SHOWTIME DEBUG INFO ===');
    print('Showtime ID: ${widget.showtime.id}');
    print('Available seats: ${widget.showtime.availableSeats}');
    print('Available seats count: ${widget.showtime.availableSeats.length}');
    print('Booked seats: ${widget.showtime.bookedSeats}');
    print('Booked seats count: ${widget.showtime.bookedSeats.length}');

    // Debug first few seats format
    if (widget.showtime.availableSeats.isNotEmpty) {
      print('First few available seats: ${widget.showtime.availableSeats.take(5).join(", ")}');
    }
    if (widget.showtime.bookedSeats.isNotEmpty) {
      print('First few booked seats: ${widget.showtime.bookedSeats.take(5).join(", ")}');
    }
    print('==========================');
  }

  void _initializeSeatLayout() {
    seatLayout = [];
    const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    for (String row in rows) {
      List<String> seatRow = [];
      for (int i = 1; i <= 12; i++) {
        // FIXED: Use format without leading zeros to match Firestore (A1, A2, etc.)
        seatRow.add('$row$i');
      }
      seatLayout.add(seatRow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDebugPanel(),
              _buildSeatLegend(),
              SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: _buildSeatLayout(bookingProvider),
                ),
              ),
              SizedBox(height: 16),
              if (bookingProvider.selectedSeats.isNotEmpty)
                _buildSelectedSeatsInfo(bookingProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEBUG INFO:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
          Text('Available seats: ${widget.showtime.availableSeats.length}'),
          Text('Booked seats: ${widget.showtime.bookedSeats.length}'),
          if (widget.showtime.availableSeats.isEmpty)
            Text(
              'WARNING: No available seats data from Firestore! Using default layout.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          if (widget.showtime.availableSeats.isNotEmpty)
            Text(
              'Sample available: ${widget.showtime.availableSeats.take(10).join(", ")}',
              style: TextStyle(fontSize: 10),
            ),
          if (widget.showtime.bookedSeats.isNotEmpty)
            Text(
              'Sample booked: ${widget.showtime.bookedSeats.take(5).join(", ")}',
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(Colors.grey[300]!, 'Trống', Icons.event_seat),
          _buildLegendItem(Colors.red, 'Đã đặt', Icons.event_seat),
          _buildLegendItem(Theme.of(context).primaryColor, 'Đang chọn', Icons.event_seat),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSeatLayout(BookingProvider bookingProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 30,
            margin: EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[200]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'MÀN HÌNH',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
            ),
          ),
          Column(
            children: seatLayout.asMap().entries.map((entry) {
              int rowIndex = entry.key;
              List<String> seats = entry.value;
              String rowLabel = String.fromCharCode(65 + rowIndex);

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      child: Text(rowLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: seats.asMap().entries.map((seatEntry) {
                            int seatIndex = seatEntry.key;
                            String seatId = seatEntry.value;

                            Widget seatWidget = _buildSeat(seatId, bookingProvider);

                            if (seatIndex == 5) {
                              return Row(children: [seatWidget, SizedBox(width: 16)]);
                            } else if (seatIndex == seats.length - 1) {
                              return seatWidget;
                            } else {
                              return Row(children: [seatWidget, SizedBox(width: 4)]);
                            }
                          }).toList(),
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      child: Text(rowLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(String seatId, BookingProvider bookingProvider) {
    final isBooked = widget.showtime.isSeatBooked(seatId);
    final isSelected = bookingProvider.selectedSeats.contains(seatId);
    final isAvailable = widget.showtime.isSeatAvailable(seatId);

    // Debug logging for each seat
    if (seatId == 'A1' || seatId == 'A2' || seatId == 'B1') {
      print('Seat $seatId: Available=$isAvailable, Booked=$isBooked, Selected=$isSelected');
    }

    Color seatColor;
    bool canSelect = false;

    if (isBooked) {
      seatColor = Colors.red;
      canSelect = false;
    } else if (isSelected) {
      seatColor = Theme.of(context).primaryColor;
      canSelect = true;
    } else if (isAvailable) {
      seatColor = Colors.grey[300]!;
      canSelect = true;
    } else {
      // Ghế không available
      seatColor = Colors.grey[600]!;
      canSelect = false;
    }

    return GestureDetector(
      onTap: () {
        print('Seat $seatId tapped - Available: $isAvailable, Booked: $isBooked, Selected: $isSelected, CanSelect: $canSelect');

        if (canSelect && !isBooked) {
          // Toggle seat selection
          if (isSelected) {
            bookingProvider.selectSeat(seatId); // Remove seat
            print('Removed seat: $seatId');
          } else {
            // Check limit before adding
            if (bookingProvider.selectedSeats.length < 8) {
              bookingProvider.selectSeat(seatId); // Add seat
              print('Added seat: $seatId');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tối đa 8 ghế mỗi lần đặt'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
          }
          widget.onSeatsSelected(bookingProvider.selectedSeats);
        } else {
          // Show detailed error message
          String message;
          if (isBooked) {
            message = 'Ghế $seatId đã được đặt';
          } else if (!isAvailable) {
            message = 'Ghế $seatId không khả dụng (not in availableSeats list)';
          } else {
            message = 'Không thể chọn ghế $seatId';
          }

          print('Seat selection failed: $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: Duration(seconds: 2),
              backgroundColor: isBooked ? Colors.red : Colors.orange,
            ),
          );
        }
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isSelected
              ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.5), spreadRadius: 1, blurRadius: 3)]
              : null,
        ),
        child: Center(
          child: isBooked
              ? Icon(Icons.close, color: Colors.white, size: 12)
              : isSelected
              ? Icon(Icons.check, color: Colors.white, size: 12)
              : Text(
            seatId.length > 2 ? seatId.substring(1) : seatId.substring(1),
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSeatsInfo(BookingProvider bookingProvider) {
    final totalPrice = bookingProvider.calculateTotalPrice(
      bookingProvider.selectedSeats,
      widget.showtime.price,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ghế đã chọn:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: bookingProvider.selectedSeats.map((seat) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(seat, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Số ghế: ${bookingProvider.selectedSeats.length}', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Tổng: ${totalPrice.toStringAsFixed(0)} VND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
            ],
          ),
        ],
      ),
    );
  }
}