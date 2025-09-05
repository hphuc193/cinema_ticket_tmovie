// lib/screens/movie_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie_model.dart';
import '../widgets/rating_display.dart';
import '../widgets/expandable_text.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;

  MovieDetailScreen({required this.movieId});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? movie;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovieDetail();
  }

  _loadMovieDetail() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final loadedMovie = await movieProvider.getMovieById(widget.movieId);

    setState(() {
      movie = loadedMovie;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Phim không tồn tại')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(movie!.posterUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(movie!.posterUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie!.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            RatingDisplay(rating: movie!.rating),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${movie!.duration} phút',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Ngày chiếu: ${_formatReleaseDate(movie!.releaseDate)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _buildStatusChip(movie!.status),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 4,
                              children: movie!.genres.map((genre) =>
                                  Chip(
                                    label: Text(genre),
                                    backgroundColor: Colors.grey[200],
                                    labelStyle: TextStyle(fontSize: 12),
                                  ),
                              ).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Release date section (detailed)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Thông tin chiếu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Ngày khởi chiếu: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(_formatDetailedReleaseDate(movie!.releaseDate)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Trạng thái: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              _buildStatusText(movie!.status),
                            ],
                          ),
                          if (movie!.status == 'coming_soon')
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                _getCountdownText(movie!.releaseDate),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Mô tả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ExpandableText(
                    text: movie!.description,
                    maxLines: 3,
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Đạo diễn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(movie!.director),

                  SizedBox(height: 20),

                  Text(
                    'Diễn viên',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(movie!.cast.join(', ')),

                  SizedBox(height: 80), // Thêm space cho bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: movie!.status == 'now_showing'
            ? ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/booking',
              arguments: movie!.id, // ✅ Chỉ truyền movieId
            );
          },
          child: Text('Đặt vé'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        )
            : movie!.status == 'coming_soon'
            ? ElevatedButton(
          onPressed: null,
          child: Text('Sắp chiếu - ${_formatReleaseDate(movie!.releaseDate)}'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        )
            : ElevatedButton(
          onPressed: null,
          child: Text('Đã ngừng chiếu'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'now_showing':
        color = Colors.green;
        text = 'Đang chiếu';
        icon = Icons.play_circle;
        break;
      case 'coming_soon':
        color = Colors.orange;
        text = 'Sắp chiếu';
        icon = Icons.schedule;
        break;
      case 'ended':
        color = Colors.grey;
        text = 'Đã chiếu';
        icon = Icons.stop_circle;
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(String status) {
    switch (status) {
      case 'now_showing':
        return Text(
          'Đang chiếu',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
        );
      case 'coming_soon':
        return Text(
          'Sắp chiếu',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
        );
      case 'ended':
        return Text(
          'Đã chiếu',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        );
      default:
        return Text('Không xác định');
    }
  }

  String _formatReleaseDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDetailedReleaseDate(DateTime date) {
    final weekdays = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    final weekday = weekdays[date.weekday % 7];
    return '$weekday, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getCountdownText(DateTime releaseDate) {
    final now = DateTime.now();
    final difference = releaseDate.difference(now);

    if (difference.isNegative) {
      return 'Đã ra mắt';
    }

    if (difference.inDays > 0) {
      return 'Còn ${difference.inDays} ngày nữa';
    } else if (difference.inHours > 0) {
      return 'Còn ${difference.inHours} giờ nữa';
    } else {
      return 'Sắp ra mắt';
    }
  }
}