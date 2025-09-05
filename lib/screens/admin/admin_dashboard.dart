// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/movie_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/admin_movie_card.dart';
import '../../models/ticket_model.dart';
import 'add_movie_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _ticketIdController = TextEditingController();
  Ticket? _foundTicket;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchMovies();
    });
  }

  @override
  void dispose() {
    _ticketIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản trị viên'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          return RefreshIndicator(
            onRefresh: () => movieProvider.fetchMovies(),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats cards - 3 cards in a column layout
                    Column(
                      children: [
                        // Row 1: Tổng phim và Đang chiếu
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Tổng phim',
                                movieProvider.movies.length.toString(),
                                Icons.movie,
                                Colors.blue,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Đang chiếu',
                                movieProvider.getMoviesByStatus('now_showing').length.toString(),
                                Icons.play_circle,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Row 2: Sắp chiếu và Đã chiếu
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Sắp chiếu',
                                movieProvider.getMoviesByStatus('coming_soon').length.toString(),
                                Icons.schedule,
                                Colors.orange,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Đã chiếu',
                                movieProvider.getMoviesByStatus('ended').length.toString(),
                                Icons.history,
                                Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Ticket Management Section
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quản lý vé',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _ticketIdController,
                                    decoration: InputDecoration(
                                      labelText: 'Nhập ID vé',
                                      hintText: 'Ví dụ: GKR6zOZBnAcKToA8PosM',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _isSearching ? null : _searchTicket,
                                  child: _isSearching
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                      : Text('Tìm'),
                                ),
                              ],
                            ),
                            if (_foundTicket != null) ...[
                              SizedBox(height: 16),
                              _buildTicketInfo(_foundTicket!),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quản lý phim',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMovieScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.add),
                          label: Text('Thêm phim'),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    if (movieProvider.isLoading)
                      Center(child: CircularProgressIndicator())
                    else if (movieProvider.movies.isEmpty)
                      Center(
                        child: Text(
                          'Chưa có phim nào',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: movieProvider.movies.length,
                        itemBuilder: (context, index) {
                          final movie = movieProvider.movies[index];
                          return AdminMovieCard(
                            movie: movie,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMovieScreen(movie: movie),
                                ),
                              );
                            },
                            onDelete: () {
                              _showDeleteDialog(context, movie.id, movieProvider);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo(Ticket ticket) {
    bool isPending = ticket.paymentStatus.toLowerCase() == 'pending';

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thông tin vé',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPending ? 'Chưa thanh toán' : 'Đã thanh toán',
                    style: TextStyle(
                      color: isPending ? Colors.orange[700] : Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow('ID vé:', ticket.id),
            _buildInfoRow('User ID:', ticket.userId),
            _buildInfoRow('Showtime ID:', ticket.showtimeId),
            _buildInfoRow('Ghế:', ticket.seats.join(', ')),
            _buildInfoRow('Tổng tiền:', '${ticket.totalPrice.toStringAsFixed(0)} VNĐ'),
            _buildInfoRow('Phương thức thanh toán:', ticket.paymentMethod),
            _buildInfoRow('Ngày tạo:', '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year} ${ticket.createdAt.hour}:${ticket.createdAt.minute.toString().padLeft(2, '0')}'),

            if (isPending) ...[
              SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmPayment(ticket.id),
                  icon: Icon(Icons.check_circle, color: Colors.white),
                  label: Text('Xác nhận thanh toán'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchTicket() async {
    if (_ticketIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập ID vé')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _foundTicket = null;
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(_ticketIdController.text.trim())
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        setState(() {
          _foundTicket = Ticket.fromJson(data);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy vé với ID này')),
        );
      }
    } catch (e) {
      print('Lỗi tìm vé: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi tìm vé')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _confirmPayment(String ticketId) async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận thanh toán'),
        content: Text('Bạn có chắc chắn muốn chuyển vé này sang trạng thái đã thanh toán?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update({
        'paymentStatus': 'completed',
      });

      // Update local state
      if (_foundTicket != null) {
        setState(() {
          _foundTicket = Ticket(
            id: _foundTicket!.id,
            userId: _foundTicket!.userId,
            showtimeId: _foundTicket!.showtimeId,
            seats: _foundTicket!.seats,
            totalPrice: _foundTicket!.totalPrice,
            paymentStatus: 'completed',
            paymentMethod: _foundTicket!.paymentMethod,
            createdAt: _foundTicket!.createdAt,
            movie: _foundTicket!.movie,
            cinema: _foundTicket!.cinema,
            showtimeTime: _foundTicket!.showtimeTime,
          );
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật trạng thái thanh toán thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Lỗi cập nhật trạng thái thanh toán: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi cập nhật trạng thái thanh toán'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, String movieId, MovieProvider movieProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa phim'),
        content: Text('Bạn có chắc chắn muốn xóa phim này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await movieProvider.deleteMovie(movieId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa phim thành công')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa phim thất bại')),
                );
              }
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}