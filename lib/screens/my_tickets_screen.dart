// lib/screens/my_tickets_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/ticket_model.dart';
import '../widgets/ticket_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyTicketsScreen extends StatefulWidget {
  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildModernSliverAppBar(isDarkMode),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  _buildModernTabBar(isDarkMode),
                  Container(
                    height: MediaQuery.of(context).size.height - 250,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTicketList(ticketProvider.getTicketsByStatus('upcoming'), isDarkMode),
                        _buildTicketList(ticketProvider.getTicketsByStatus('used'), isDarkMode),
                        _buildTicketList(ticketProvider.getTicketsByStatus('cancelled'), isDarkMode),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildModernSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [Color(0xFF1E1E1E), Color(0xFF2A2A2A)]
                  : [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.confirmation_number_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vé của tôi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Quản lý vé xem phim',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTabBar(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: isDarkMode ? Color(0xFF3A3A3A) : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(
          //   color: Colors.black,
          //   width: 2.5,
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: isDarkMode
          //         ? Colors.black.withOpacity(0.9)
          //         : Colors.grey.withOpacity(0.9),
          //     blurRadius: 8,
          //     offset: Offset(0, 1),
          //   ),
          // ],
        ),
        labelColor: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
        unselectedLabelColor: isDarkMode ? Colors.grey[500] : Colors.grey[600],
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 18),
                SizedBox(width: 16),
                Text('Pending'),

              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 18),
                SizedBox(width: 16),
                Text('Completed'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, size: 18),
                SizedBox(width: 16),
                Text('Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(List<Ticket> tickets, bool isDarkMode) {
    final ticketProvider = Provider.of<TicketProvider>(context);

    if (ticketProvider.isLoading) {
      return Container(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                  ),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Đang tải vé...',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (ticketProvider.error != null) {
      return Container(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: Colors.red[400],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  ticketProvider.error!,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => ticketProvider.fetchUserTickets(),
                  icon: Icon(Icons.refresh_rounded, size: 20),
                  label: Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    size: 56,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Chưa có vé nào',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Hãy đặt vé xem phim để trải nghiệm\nnhững bộ phim tuyệt vời',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  icon: Icon(Icons.local_movies_rounded, size: 20),
                  label: Text('Đặt vé ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ticketProvider.refreshTickets(),
      color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
      child: Container(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return _buildModernTicketCard(ticket, index, isDarkMode);
          },
        ),
      ),
    );
  }

  Widget _buildModernTicketCard(Ticket ticket, int index, bool isDarkMode) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showTicketDetail(ticket),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ticket.paymentStatus).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(ticket.paymentStatus),
                              size: 14,
                              color: _getStatusColor(ticket.paymentStatus),
                            ),
                            SizedBox(width: 6),
                            Text(
                              _getStatusText(ticket.paymentStatus),
                              style: TextStyle(
                                color: _getStatusColor(ticket.paymentStatus),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      // Ticket ID
                      Text(
                        '#${ticket.id.substring(0, 8)}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Movie title
                  Text(
                    _getMovieTitle(ticket),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  // Info rows
                  _buildTicketInfoRow(
                    Icons.location_on_outlined,
                    _getCinemaName(ticket),
                    isDarkMode,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTicketInfoRow(
                          Icons.calendar_today_outlined,
                          _getShowDate(ticket),
                          isDarkMode,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildTicketInfoRow(
                          Icons.access_time_outlined,
                          _getShowTime(ticket),
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTicketInfoRow(
                          Icons.event_seat_outlined,
                          ticket.seats.join(', '),
                          isDarkMode,
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${NumberFormat('#,###').format(ticket.totalPrice)} ₫',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Action buttons
                  if (ticket.paymentStatus == 'completed' || ticket.paymentStatus == 'pending')
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _cancelTicket(ticket),
                              icon: Icon(Icons.close_rounded, size: 18),
                              label: Text('Hủy vé'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red.withOpacity(0.3)),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showTicketDetail(ticket),
                              icon: Icon(Icons.qr_code_rounded, size: 18),
                              label: Text('Chi tiết'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                                foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfoRow(IconData icon, String text, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _showTicketDetail(Ticket ticket) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.confirmation_number_rounded,
                        color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Chi tiết vé',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 32),
              // Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
                  children: [
                    // Barcode section
                    _buildModernBarcodeSection(ticket.id, isDarkMode),
                    SizedBox(height: 24),

                    // Ticket info
                    _buildDetailSection(
                      'Thông tin phim',
                      [
                        _buildModernDetailRow(
                          Icons.movie_outlined,
                          'Tên phim',
                          _getMovieTitle(ticket),
                          isDarkMode,
                          isTitle: true,
                        ),
                        _buildModernDetailRow(
                          Icons.location_on_outlined,
                          'Rạp chiếu',
                          _getCinemaName(ticket),
                          isDarkMode,
                        ),
                      ],
                      isDarkMode,
                    ),

                    SizedBox(height: 20),

                    _buildDetailSection(
                      'Thời gian & Ghế',
                      [
                        _buildModernDetailRow(
                          Icons.calendar_today_outlined,
                          'Ngày chiếu',
                          _getShowDate(ticket),
                          isDarkMode,
                        ),
                        _buildModernDetailRow(
                          Icons.access_time_outlined,
                          'Giờ chiếu',
                          _getShowTime(ticket),
                          isDarkMode,
                        ),
                        _buildModernDetailRow(
                          Icons.event_seat_outlined,
                          'Ghế ngồi',
                          ticket.seats.join(', '),
                          isDarkMode,
                        ),
                      ],
                      isDarkMode,
                    ),

                    SizedBox(height: 20),

                    _buildDetailSection(
                      'Thanh toán',
                      [
                        _buildModernDetailRow(
                          Icons.attach_money_rounded,
                          'Tổng tiền',
                          '${NumberFormat('#,###').format(ticket.totalPrice)} VND',
                          isDarkMode,
                          valueColor: Colors.green[600],
                        ),
                        _buildModernDetailRow(
                          Icons.payment_rounded,
                          'Phương thức',
                          _getPaymentMethodText(ticket.paymentMethod),
                          isDarkMode,
                        ),
                        _buildModernDetailRow(
                          Icons.info_outline_rounded,
                          'Trạng thái',
                          _getStatusText(ticket.paymentStatus),
                          isDarkMode,
                          valueColor: _getStatusColor(ticket.paymentStatus),
                        ),
                        _buildModernDetailRow(
                          Icons.schedule_rounded,
                          'Ngày đặt',
                          DateFormat('dd/MM/yyyy HH:mm').format(ticket.createdAt),
                          isDarkMode,
                        ),
                      ],
                      isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernBarcodeSection(String ticketId, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
          children: [
      // Barcode
      Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: ticketId,
              drawText: false,
              color: Colors.black,
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            ticketId,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Colors.grey[700],
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    ),
    SizedBox(height: 16),
    // Copy button
    OutlinedButton.icon(
    onPressed: () => _copyToClipboard(ticketId, 'Mã vạch đã được sao chép'),
    icon: Icon(Icons.copy_rounded, size: 18),
    label: Text('Sao chép mã vạch'),
    style: OutlinedButton.styleFrom(foregroundColor: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
      side: BorderSide(
        color: isDarkMode
            ? Colors.grey[700]!
            : Theme.of(context).primaryColor.withOpacity(0.3),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    ),
            SizedBox(height: 12),
            // Instructions
            Text(
              'Vui lòng xuất trình mã vạch này khi vào rạp',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
      ),
    );
  }

  Widget _buildModernDetailRow(
      IconData icon,
      String label,
      String value,
      bool isDarkMode, {
        Color? valueColor,
        bool isTitle = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTitle ? 16 : 15,
                    color: valueColor ?? (isDarkMode ? Colors.white : Colors.grey[800]),
                    fontWeight: isTitle ? FontWeight.bold : FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMovieTitle(Ticket ticket) {
    if (ticket.movie != null && ticket.movie!.title.isNotEmpty) {
      return ticket.movie!.title;
    }

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
    if (ticket.cinema != null && ticket.cinema!.name.isNotEmpty) {
      return ticket.cinema!.name;
    }

    try {
      final ticketData = ticket.toJson();
      if (ticketData.containsKey('cinemaName') &&
          ticketData['cinemaName'] != null) {
        final name = ticketData['cinemaName'].toString().trim();
        if (name.isNotEmpty && name != 'null') {
          return name;
        }
      }
    } catch (e) {
      print('Error getting cinemaName: $e');
    }

    return 'Rạp không xác định';
  }

  String _getShowDate(Ticket ticket) {
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

    try {
      if (ticket.showtimeTime != null) {
        DateTime date;
        if (ticket.showtimeTime is DateTime) {
          date = ticket.showtimeTime as DateTime;
        } else {
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

    try {
      if (ticket.showtimeTime != null) {
        DateTime time;
        if (ticket.showtimeTime is DateTime) {
          time = ticket.showtimeTime as DateTime;
        } else {
          time = (ticket.showtimeTime as Timestamp).toDate();
        }
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error converting showtimeTime to time: $e');
    }

    return 'Giờ không xác định';
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _cancelTicket(Ticket ticket) async {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Xác nhận hủy vé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn hủy vé xem phim "${_getMovieTitle(ticket)}"?\n\nLưu ý: Sau khi hủy, bạn sẽ không thể hoàn tác thao tác này.',
          style: TextStyle(
            height: 1.5,
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Không',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Hủy vé',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Đã hủy vé thành công',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Lỗi khi hủy vé',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
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