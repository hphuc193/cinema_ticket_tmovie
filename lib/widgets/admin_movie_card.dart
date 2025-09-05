// lib/widgets/admin_movie_card.dart
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../utils/date_utils.dart';

class AdminMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AdminMovieCard({
    Key? key,
    required this.movie,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 120,
                  child: movie.posterUrl.isNotEmpty
                      ? Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.movie,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.movie,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),

              // Movie info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          movie.rating.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${movie.duration} phút',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(movie.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(movie.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(movie.status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(movie.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // Release date
                    Text(
                      'Ngày phát hành: ${_formatDate(movie.releaseDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 8),

                    // Genres
                    if (movie.genres.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: movie.genres.take(3).map((genre) =>
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                genre,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                        ).toList(),
                      ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit),
                      iconSize: 20,
                      color: Colors.blue,
                      tooltip: 'Sửa',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: () => _showDeleteDialog(context),
                      icon: Icon(Icons.delete),
                      iconSize: 20,
                      color: Colors.red,
                      tooltip: 'Xóa',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'now_showing':
        return Colors.green;
      case 'coming_soon':
        return Colors.orange;
      case 'ended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'now_showing':
        return 'Đang chiếu';
      case 'coming_soon':
        return 'Sắp chiếu';
      case 'ended':
        return 'Đã kết thúc';
      default:
        return 'Không xác định';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa phim "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onDelete != null) {
                onDelete!();
              }
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Simplified version for list view
class AdminMovieListTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AdminMovieListTile({
    Key? key,
    required this.movie,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 40,
          height: 60,
          child: movie.posterUrl.isNotEmpty
              ? Image.network(
            movie.posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.movie,
                  size: 20,
                  color: Colors.grey[600],
                ),
              );
            },
          )
              : Container(
            color: Colors.grey[300],
            child: Icon(
              Icons.movie,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
      title: Text(
        movie.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${movie.rating}⭐ • ${movie.duration} phút',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(movie.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(movie.status),
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(movie.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit, size: 20),
              color: Colors.blue,
            ),
          if (onDelete != null)
            IconButton(
              onPressed: () => _showDeleteDialog(context),
              icon: Icon(Icons.delete, size: 20),
              color: Colors.red,
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'now_showing':
        return Colors.green;
      case 'coming_soon':
        return Colors.orange;
      case 'ended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'now_showing':
        return 'Đang chiếu';
      case 'coming_soon':
        return 'Sắp chiếu';
      case 'ended':
        return 'Đã kết thúc';
      default:
        return 'Không xác định';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa phim "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onDelete != null) {
                onDelete!();
              }
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}