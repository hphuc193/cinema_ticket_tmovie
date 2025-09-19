// lib/screens/booking_success_screen.dart
import 'package:flutter/material.dart';
import '../models/ticket_model.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String movieTitle;
  final String cinemaName;
  final String showDate;
  final String showTime;
  final List<String> seats;
  final double totalPrice;
  final String paymentMethod;
  final String? ticketId;

  const BookingSuccessScreen({
    Key? key,
    required this.movieTitle,
    required this.cinemaName,
    required this.showDate,
    required this.showTime,
    required this.seats,
    required this.totalPrice,
    required this.paymentMethod,
    this.ticketId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Đặt vé thành công'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 20),

              // Success Message
              Text(
                'Đặt vé thành công!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10),

              Text(
                'Cảm ơn bạn đã chọn dịch vụ của chúng tôi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              // Ticket Information Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            color: Colors.green,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'THÔNG TIN VÉ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Movie Info
                      _buildInfoRow(
                        icon: Icons.movie,
                        label: 'Phim',
                        value: movieTitle,
                        valueStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'Rạp',
                        value: cinemaName,
                      ),

                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Ngày',
                        value: showDate,
                      ),

                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: 'Giờ',
                        value: showTime,
                      ),

                      _buildInfoRow(
                        icon: Icons.event_seat,
                        label: 'Ghế',
                        value: seats.join(', '),
                        valueStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),

                      _buildInfoRow(
                        icon: Icons.payment,
                        label: 'Thanh toán',
                        value: _getPaymentMethodText(paymentMethod),
                      ),

                      if (ticketId != null)
                        _buildInfoRow(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Mã vé',
                          value: ticketId!.substring(0, 8).toUpperCase(),
                          valueStyle: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      // Divider
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.green, Colors.transparent],
                          ),
                        ),
                      ),

                      // Total Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TỔNG TIỀN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${totalPrice.toStringAsFixed(0)} VND',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Payment Notice
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: paymentMethod == 'cash' ? Colors.orange[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: paymentMethod == 'cash' ? Colors.orange[200]! : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      paymentMethod == 'cash' ? Icons.info : Icons.check_circle,
                      color: paymentMethod == 'cash' ? Colors.orange : Colors.blue,
                      size: 28,
                    ),
                    SizedBox(height: 8),
                    Text(
                      paymentMethod == 'cash'
                          ? 'LƯU Ý QUAN TRỌNG'
                          : 'THANH TOÁN THÀNH CÔNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: paymentMethod == 'cash' ? Colors.orange[800] : Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      paymentMethod == 'cash'
                          ? 'Vui lòng đến rạp trước 15 phút để thanh toán và nhận vé. Vé sẽ bị hủy nếu không thanh toán đúng giờ.'
                          : 'Vé của bạn đã được thanh toán thành công. Vui lòng đến rạp đúng giờ để nhận vé.',
                      style: TextStyle(
                        color: paymentMethod == 'cash' ? Colors.orange[700] : Colors.blue[700],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Action Buttons
              Column(
                children: [
                  // View Tickets Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/tickets',
                              (route) => route.settings.name == '/',
                        );
                      },
                      icon: Icon(Icons.confirmation_number),
                      label: Text('Xem vé của tôi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Home Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                              (route) => false,
                        );
                      },
                      icon: Icon(Icons.home),
                      label: Text('Về trang chủ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Continue Booking Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                              (route) => false,
                        );
                      },
                      icon: Icon(Icons.movie_filter),
                      label: Text('Đặt vé phim khác'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label + ':',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
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