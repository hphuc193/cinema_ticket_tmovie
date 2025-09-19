// lib/screens/my_tickets_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart'; // Thêm import này
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../models/ticket_model.dart';
import '../widgets/ticket_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Để sử dụng Timestamp

class MyTicketsScreen extends StatefulWidget {
  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1; // Vé của tôi tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Tải danh sách vé khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketProvider>(context, listen: false).fetchUserTickets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Vé của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.indigo,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'Chưa Thanh Toán'),
                Tab(text: 'Đã Thanh Toán'),
                Tab(text: 'Đã Hủy'),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ticketProvider.refreshTickets(),
        color: Colors.indigo,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTicketList(ticketProvider.getTicketsByStatus('upcoming')),
            _buildTicketList(ticketProvider.getTicketsByStatus('used')),
            _buildTicketList(ticketProvider.getTicketsByStatus('cancelled')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleNavigation(index);
        },
      ),
    );
  }

  Widget _buildTicketList(List<Ticket> tickets) {
    final ticketProvider = Provider.of<TicketProvider>(context);

    if (ticketProvider.isLoading) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
              SizedBox(height: 16),
              Text(
                'Đang tải vé...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (ticketProvider.error != null) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  ticketProvider.error!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ticketProvider.fetchUserTickets(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text('Thử lại'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (tickets.isEmpty) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    size: 48,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Chưa có vé nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hãy đặt vé xem phim để trải nghiệm',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_movies, size: 20),
                      SizedBox(width: 8),
                      Text('Đặt vé ngay'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TicketCard(
                ticket: ticket,
                onTap: () => _showTicketDetail(ticket),
                // Cho phép hủy vé cả khi pending và completed
                onCancel: (ticket.paymentStatus == 'completed' || ticket.paymentStatus == 'pending')
                    ? () => _cancelTicket(ticket)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTicketDetail(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.confirmation_number,
                      color: Colors.indigo,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chi tiết vé',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID Vé với tính năng sao chép
                      _buildCopyableDetailRow(
                        icon: Icons.tag,
                        label: 'ID Vé',
                        value: ticket.id,
                        onCopy: () => _copyToClipboard(ticket.id, 'ID vé đã được sao chép'),
                      ),

                      SizedBox(height: 20),

                      // Mã vạch
                      _buildBarcodeSection(ticket.id),

                      SizedBox(height: 20),

                      // MOVIE TITLE - Ưu tiên từ ticket document
                      _buildDetailRow(
                        icon: Icons.movie,
                        label: 'Phim',
                        value: _getMovieTitle(ticket),
                        isTitle: true,
                      ),
                      SizedBox(height: 12),

                      // CINEMA NAME - Ưu tiên từ ticket document
                      _buildDetailRow(
                        icon: Icons.location_on,
                        label: 'Rạp',
                        value: _getCinemaName(ticket),
                      ),
                      SizedBox(height: 12),

                      // SHOW DATE & TIME - Từ ticket document
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Ngày chiếu',
                        value: _getShowDate(ticket),
                      ),
                      SizedBox(height: 12),

                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Giờ chiếu',
                        value: _getShowTime(ticket),
                      ),
                      SizedBox(height: 12),

                      // SEATS
                      _buildDetailRow(
                        icon: Icons.event_seat,
                        label: 'Ghế',
                        value: ticket.seats.join(', '),
                      ),
                      SizedBox(height: 12),

                      // PRICE
                      _buildDetailRow(
                        icon: Icons.attach_money,
                        label: 'Giá',
                        value: '${NumberFormat('#,###').format(ticket.totalPrice)} VND',
                        valueColor: Colors.green[600],
                      ),
                      SizedBox(height: 12),

                      // PAYMENT METHOD - Fixed
                      _buildDetailRow(
                        icon: Icons.payment,
                        label: 'Phương thức',
                        value: _getPaymentMethodText(ticket.paymentMethod),
                      ),
                      SizedBox(height: 12),

                      // PAYMENT STATUS
                      _buildDetailRow(
                        icon: Icons.info,
                        label: 'Trạng thái',
                        value: _getStatusText(ticket.paymentStatus),
                        valueColor: _getStatusColor(ticket.paymentStatus),
                      ),
                      SizedBox(height: 12),

                      // CREATED DATE
                      _buildDetailRow(
                        icon: Icons.schedule,
                        label: 'Ngày đặt',
                        value: DateFormat('dd/MM/yyyy HH:mm').format(ticket.createdAt),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Đóng',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMovieTitle(Ticket ticket) {
    // Thử dùng movie object trước
    if (ticket.movie != null && ticket.movie!.title.isNotEmpty) {
      return ticket.movie!.title;
    }

    // Fallback: thử lấy từ ticket data nếu có
    try {
      final ticketData = ticket.toJson();
      if (ticketData.containsKey('movieTitle') &&
          ticketData['movieTitle'] != null) {
        final title = ticketData['movieTitle'].toString().trim();
        if (title.isNotEmpty && title != 'null') {
          return title;
        }
      }
    } catch (e) {
      print('Error getting movieTitle: $e');
    }

    return 'Phim không xác định';
  }

  String _getCinemaName(Ticket ticket) {
    // DEBUG: In ra tất cả thông tin ticket
    try {
      final ticketData = ticket.toJson();
      print('=== TICKET DEBUG ===');
      print('Ticket ID: ${ticket.id}');
      print('All ticket fields: $ticketData');
      print('Has cinemaName field: ${ticketData.containsKey('cinemaName')}');
      print('CinemaName value: ${ticketData['cinemaName']}');
      print('Has cinemaId field: ${ticketData.containsKey('cinemaId')}');
      print('CinemaId value: ${ticketData['cinemaId']}');
      print('Cinema object: ${ticket.cinema}');
      print('===================');
    } catch (e) {
      print('Debug error: $e');
    }

    // Thử dùng cinema object trước
    if (ticket.cinema != null && ticket.cinema!.name.isNotEmpty) {
      print('Using cinema object: ${ticket.cinema!.name}');
      return ticket.cinema!.name;
    }

    // Fallback: thử lấy từ ticket data nếu có
    try {
      final ticketData = ticket.toJson();
      if (ticketData.containsKey('cinemaName') &&
          ticketData['cinemaName'] != null) {
        final name = ticketData['cinemaName'].toString().trim();
        if (name.isNotEmpty && name != 'null') {
          print('Using cinemaName from ticket: $name');
          return name;
        }
      }
    } catch (e) {
      print('Error getting cinemaName: $e');
    }

    print('No cinema info found, returning default');
    return 'Rạp không xác định';
  }

  String _getShowDate(Ticket ticket) {
    // Thử lấy từ ticket data trước (cho vé mới)
    try {
      final ticketData = ticket.toJson();
      if (ticketData.containsKey('showDate') &&
          ticketData['showDate'] != null) {
        final date = ticketData['showDate'].toString().trim();
        if (date.isNotEmpty && date != 'null') {
          return date;
        }
      }
    } catch (e) {
      print('Error getting showDate: $e');
    }

    // Fallback: dùng showtimeTime (cho vé cũ)
    try {
      if (ticket.showtimeTime != null) {
        DateTime date;

        // Kiểm tra xem showtimeTime là DateTime hay Timestamp
        if (ticket.showtimeTime is DateTime) {
          date = ticket.showtimeTime as DateTime;
        } else {
          // Nếu là Timestamp, convert sang DateTime
          date = (ticket.showtimeTime as Timestamp).toDate();
        }

        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      print('Error converting showtimeTime to date: $e');
    }

    return 'Ngày không xác định';
  }

  String _getShowTime(Ticket ticket) {
    // Thử lấy từ ticket data trước (cho vé mới)
    try {
      final ticketData = ticket.toJson();
      if (ticketData.containsKey('showTime') &&
          ticketData['showTime'] != null) {
        final time = ticketData['showTime'].toString().trim();
        if (time.isNotEmpty && time != 'null') {
          return time;
        }
      }
    } catch (e) {
      print('Error getting showTime: $e');
    }

    // Fallback: dùng showtimeTime (cho vé cũ)
    try {
      if (ticket.showtimeTime != null) {
        DateTime time;

        // Kiểm tra xem showtimeTime là DateTime hay Timestamp
        if (ticket.showtimeTime is DateTime) {
          time = ticket.showtimeTime as DateTime;
        } else {
          // Nếu là Timestamp, convert sang DateTime
          time = (ticket.showtimeTime as Timestamp).toDate();
        }

        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error converting showtimeTime to time: $e');
    }

    return 'Giờ không xác định';
  }

  // Widget mới để hiển thị mã vạch
  Widget _buildBarcodeSection(String ticketId) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.indigo[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.qr_code,
                  size: 16,
                  color: Colors.indigo[600],
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Mã vạch vé',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Container chứa mã vạch
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                // Mã vạch
                Container(
                  height: 80,
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: ticketId,
                    drawText: false, // Không hiển thị text dưới mã vạch
                    color: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 8),

                // Text ID dưới mã vạch với font monospace
                Text(
                  ticketId,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.grey[700],
                    letterSpacing: 1.0,
                  ),
                ),

                SizedBox(height: 12),

                // Nút sao chép mã vạch
                InkWell(
                  onTap: () => _copyToClipboard(ticketId, 'Mã vạch đã được sao chép'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.indigo[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.indigo[600],
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Sao chép mã',
                          style: TextStyle(
                            color: Colors.indigo[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Hướng dẫn sử dụng
          Text(
            'Vui lòng xuất trình mã vạch này khi vào rạp',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isTitle = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
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
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTitle ? 16 : 14,
                  color: valueColor ?? Colors.grey[800],
                  fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget mới cho hiển thị thông tin có thể sao chép
  Widget _buildCopyableDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
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
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace', // Font monospace để ID dễ đọc hơn
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: onCopy,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.indigo[200]!,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.indigo[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Hàm sao chép vào clipboard
  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _cancelTicket(Ticket ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text(
              'Xác nhận hủy vé',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn hủy vé xem phim "${ticket.movie?.title ?? 'N/A'}"?\n\nLưu ý: Sau khi hủy, bạn sẽ không thể hoàn tác thao tác này.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Không',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Hủy vé'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      final success = await ticketProvider.cancelTicket(ticket.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Đã hủy vé thành công'),
              ],
            ),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Lỗi khi hủy vé'),
              ],
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Đã thanh toán';
      case 'pending':
        return 'Chờ thanh toán';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'Tiền mặt';
      case 'card':
        return 'Thẻ tín dụng';
      case 'bank_transfer':
        return 'Chuyển khoản';
      case 'e_wallet':
        return 'Ví điện tử';
      case 'momo':
        return 'Ví MoMo';
      case 'paypal':
        return 'PayPal';
      default:
        return 'Không xác định';
    }
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
      // Already on tickets screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

}
