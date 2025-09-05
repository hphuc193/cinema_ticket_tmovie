// widgets/showtime_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../models/showtime_model.dart';

class ShowtimeSelector extends StatefulWidget {
  final String movieId;
  final Function(String)? onShowtimeSelected;

  const ShowtimeSelector({
    Key? key,
    required this.movieId,
    this.onShowtimeSelected
  }) : super(key: key);

  @override
  _ShowtimeSelectorState createState() => _ShowtimeSelectorState();
}

class _ShowtimeSelectorState extends State<ShowtimeSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.fetchShowtimes(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.errorMessage != null) {
          return Column(
            children: [
              Text('Lỗi: ${bookingProvider.errorMessage}'),
              ElevatedButton(
                onPressed: () {
                  bookingProvider.fetchShowtimes(widget.movieId);
                },
                child: Text('Thử lại'),
              ),
            ],
          );
        }

        if (bookingProvider.showtimes.isEmpty) {
          return Center(
            child: Text(
              'Không có suất chiếu',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        // Group showtimes by date
        Map<String, List<Showtime>> showtimesByDate = {};
        for (var showtime in bookingProvider.showtimes) {
          String dateKey = '${showtime.startTime.day}/${showtime.startTime.month}';
          if (!showtimesByDate.containsKey(dateKey)) {
            showtimesByDate[dateKey] = [];
          }
          showtimesByDate[dateKey]!.add(showtime);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: showtimesByDate.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((showtime) {
                    return ElevatedButton(
                      onPressed: () {
                        if (widget.onShowtimeSelected != null) {
                          widget.onShowtimeSelected!(showtime.id);
                        }
                        Navigator.pushNamed(
                          context,
                          '/booking',
                          arguments: {
                            'movieId': widget.movieId,
                            'showtimeId': showtime.id,
                          },
                        );
                      },
                      child: Text(
                        '${showtime.startTime.hour}:${showtime.startTime.minute.toString().padLeft(2, '0')}',
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}