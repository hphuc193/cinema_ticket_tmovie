// lib/screens/booking_success_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/ticket_model.dart';

class BookingSuccessScreen extends StatefulWidget {
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
  _BookingSuccessScreenState createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Đặt vé thành công',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.grey[900],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Animated Success Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green[400]!,
                        Colors.green[600]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Success Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Đặt vé thành công!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cảm ơn bạn đã chọn dịch vụ của chúng tôi',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Ticket Information Card
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with gradient
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.confirmation_number_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'THÔNG TIN VÉ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Ticket Details
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              context: context,
                              icon: Icons.movie_rounded,
                              label: 'Phim',
                              value: widget.movieTitle,
                              isDarkMode: isDarkMode,
                              isHighlight: true,
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow(
                              context: context,
                              icon: Icons.location_on_rounded,
                              label: 'Rạp',
                              value: widget.cinemaName,
                              isDarkMode: isDarkMode,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoRow(
                                    context: context,
                                    icon: Icons.calendar_today_rounded,
                                    label: 'Ngày',
                                    value: widget.showDate,
                                    isDarkMode: isDarkMode,
                                    compact: true,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoRow(
                                    context: context,
                                    icon: Icons.access_time_rounded,
                                    label: 'Giờ',
                                    value: widget.showTime,
                                    isDarkMode: isDarkMode,
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow(
                              context: context,
                              icon: Icons.event_seat_rounded,
                              label: 'Ghế',
                              value: widget.seats.join(', '),
                              isDarkMode: isDarkMode,
                              isHighlight: true,
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow(
                              context: context,
                              icon: Icons.payment_rounded,
                              label: 'Thanh toán',
                              value: _getPaymentMethodText(widget.paymentMethod),
                              isDarkMode: isDarkMode,
                            ),
                            if (widget.ticketId != null) ...[
                              SizedBox(height: 16),
                              _buildInfoRow(
                                context: context,
                                icon: Icons.qr_code_rounded,
                                label: 'Mã vé',
                                value: widget.ticketId!.substring(0, 8).toUpperCase(),
                                isDarkMode: isDarkMode,
                                isMono: true,
                              ),
                            ],

                            // Divider
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Total Price
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red[50]!,
                                    Colors.orange[50]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TỔNG TIỀN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '${widget.totalPrice.toStringAsFixed(0)} VND',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Payment Notice
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: widget.paymentMethod == 'cash'
                        ? LinearGradient(
                      colors: [Colors.orange[50]!, Colors.orange[100]!],
                    )
                        : LinearGradient(
                      colors: [Colors.green[50]!, Colors.green[100]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.paymentMethod == 'cash'
                          ? Colors.orange[300]!
                          : Colors.green[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.paymentMethod == 'cash'
                              ? Colors.orange
                              : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.paymentMethod == 'cash'
                              ? Icons.info_rounded
                              : Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        widget.paymentMethod == 'cash'
                            ? 'LƯU Ý QUAN TRỌNG'
                            : 'THANH TOÁN THÀNH CÔNG',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.paymentMethod == 'cash'
                              ? Colors.orange[900]
                              : Colors.green[900],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.paymentMethod == 'cash'
                            ? 'Vui lòng đến rạp trước 15 phút để thanh toán và nhận vé. Vé sẽ bị hủy nếu không thanh toán đúng giờ.'
                            : 'Vé của bạn đã được thanh toán thành công. Vui lòng đến rạp đúng giờ để nhận vé.',
                        style: TextStyle(
                          color: widget.paymentMethod == 'cash'
                              ? Colors.orange[800]
                              : Colors.green[800],
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Action Buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // View Tickets Button
                    _buildActionButton(
                      context: context,
                      label: 'Xem vé của tôi',
                      icon: Icons.confirmation_number_rounded,
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[400]!],
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/tickets',
                              (route) => route.settings.name == '/',
                        );
                      },
                    ),

                    SizedBox(height: 12),

                    // Home Button
                    _buildActionButton(
                      context: context,
                      label: 'Về trang chủ',
                      icon: Icons.home_rounded,
                      gradient: LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                              (route) => false,
                        );
                      },
                    ),

                    SizedBox(height: 12),

                    // Continue Booking Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                                (route) => false,
                          );
                        },
                        icon: Icon(Icons.movie_filter_rounded, size: 22),
                        label: Text(
                          'Đặt vé phim khác',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    bool isHighlight = false,
    bool compact = false,
    bool isMono = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: isHighlight
            ? (isDarkMode
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Theme.of(context).primaryColor.withOpacity(0.05))
            : (isDarkMode ? Color(0xFF0A0A0A) : Colors.grey[50]),
        borderRadius: BorderRadius.circular(12),
        border: isHighlight
            ? Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        )
            : null,
      ),
      child: compact
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.grey[900],
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlight
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isHighlight
                  ? Theme.of(context).primaryColor
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                    fontFamily: isMono ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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